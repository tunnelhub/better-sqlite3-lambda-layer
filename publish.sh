#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

NODE_VERSIONS=("18" "20" "22")
REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
LAYER_NAME="better-sqlite3"
VERSIONS_FILE="layer_versions.json"

# Ensure dist directory exists
if [ ! -d "dist" ]; then
    echo "Error: dist directory not found! Run build.sh first."
    exit 1
fi

# Create versions file if it doesn't exist
if [ ! -f "$VERSIONS_FILE" ]; then
    echo "{}" > "$VERSIONS_FILE"
fi

# Function to calculate SHA256 hash of a file
calculate_hash() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        shasum -a 256 "$file" | cut -d ' ' -f 1
    else
        # Linux
        sha256sum "$file" | cut -d ' ' -f 1
    fi
}

# Function to check if hash exists in version history
hash_exists() {
    local node_version="$1"
    local region="$2"
    local hash="$3"

    local stored_hash
    stored_hash=$(jq -r --arg node "nodejs${node_version}" --arg region "${region}" '.[$node][$region].hash | select(. != null)' "$VERSIONS_FILE")

    if [ "$stored_hash" = "$hash" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

for version in "${NODE_VERSIONS[@]}"; do
    echo "Processing layer for Node.js ${version}..."

    # Calculate hash of the ZIP file
    zip_file="dist/better-sqlite3-layer-nodejs${version}.zip"
    if [ ! -f "$zip_file" ]; then
        echo "Error: $zip_file not found!"
        continue
    fi

    current_hash=$(calculate_hash "$zip_file")
    echo "Hash for ${zip_file}: ${current_hash}"

    for region in "${REGIONS[@]}"; do
        echo "Checking region: ${region}"

        # Check if this hash was already published
        if hash_exists "$version" "$region" "$current_hash"; then
            stored_arn=$(jq -r --arg node "nodejs${version}" --arg region "${region}" '.[$node][$region].arn' "$VERSIONS_FILE")
            echo "Layer with same hash already exists in $region. Skipping..."
            echo "Existing Layer ARN: $stored_arn"
            continue
        fi

        echo "Publishing new version in ${region}..."

        # Publicar a layer
        LAYER_VERSION=$(aws lambda publish-layer-version \
            --layer-name "${LAYER_NAME}-nodejs${version}" \
            --description "better-sqlite3 Lambda Layer for Node.js ${version}" \
            --compatible-runtimes "nodejs${version}.x" \
            --compatible-architectures "x86_64" \
            --zip-file "fileb://${zip_file}" \
            --region "${region}" \
            --output json)

        # Extrair o número da versão
        VERSION_NUMBER=$(echo $LAYER_VERSION | jq -r '.Version')

        # Tornar a layer pública
        aws lambda add-layer-version-permission \
            --layer-name "${LAYER_NAME}-nodejs${version}" \
            --version-number $VERSION_NUMBER \
            --statement-id "public" \
            --action "lambda:GetLayerVersion" \
            --principal "*" \
            --region "${region}"

        # Obter o ARN da layer
        LAYER_ARN=$(echo $LAYER_VERSION | jq -r '.LayerVersionArn')

        # Atualizar o arquivo de versões
        CURRENT_JSON=$(cat "$VERSIONS_FILE")

        # Atualizar o JSON com a nova informação, incluindo o hash
        NEW_JSON=$(echo "$CURRENT_JSON" | jq \
            --arg node "nodejs${version}" \
            --arg region "$region" \
            --arg arn "$LAYER_ARN" \
            --arg version "$VERSION_NUMBER" \
            --arg hash "$current_hash" \
            'if has($node) then
                .[$node][$region] = {
                    "version": $version,
                    "arn": $arn,
                    "hash": $hash,
                    "last_updated": (now | strftime("%Y-%m-%d %H:%M:%S"))
                }
             else
                . + {($node): {($region): {
                    "version": $version,
                    "arn": $arn,
                    "hash": $hash,
                    "last_updated": (now | strftime("%Y-%m-%d %H:%M:%S"))
                }}}
             end')

        echo "$NEW_JSON" > "$VERSIONS_FILE"

        echo "Layer ARN for Node.js ${version} in ${region}: ${LAYER_ARN}"
        echo "----------------------------------------"
    done
done