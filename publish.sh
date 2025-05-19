#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

NODE_VERSIONS=("18" "20" "22")
ARCHITECTURES=("x86_64" "arm64")
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
    local arch="$4"

    local stored_hash
    # Use the new layer name format that includes architecture
    local layer_name="nodejs${node_version}-${arch}"
    stored_hash=$(jq -r --arg layer "${layer_name}" --arg region "${region}" '.[$layer][$region].hash | select(. != null)' "$VERSIONS_FILE")

    if [ "$stored_hash" = "$hash" ]; then
        return 0 # true
    else
        return 1 # false
    fi
}

for version in "${NODE_VERSIONS[@]}"; do
    for arch in "${ARCHITECTURES[@]}"; do
        echo "Processing layer for Node.js ${version} on ${arch} architecture..."

        # Calculate hash of the ZIP file
        zip_file="dist/better-sqlite3-layer-nodejs${version}-${arch}.zip"
        if [ ! -f "$zip_file" ]; then
            echo "Error: $zip_file not found!"
            continue
        fi

        current_hash=$(calculate_hash "$zip_file")
        echo "Hash for ${zip_file}: ${current_hash}"

        for region in "${REGIONS[@]}"; do
            echo "Checking region: ${region} for architecture: ${arch}"

            # Create layer name with architecture
            layer_name="nodejs${version}-${arch}"
            
            # Check if this hash was already published
            if hash_exists "$version" "$region" "$current_hash" "$arch"; then
                stored_arn=$(jq -r --arg layer "${layer_name}" --arg region "${region}" '.[$layer][$region].arn' "$VERSIONS_FILE")
                echo "Layer with same hash already exists in $region for $arch. Skipping..."
                echo "Existing Layer ARN: $stored_arn"
                continue
            fi

            echo "Publishing new version in ${region} for ${arch}..."

            # Publish the layer with architecture-specific name
            LAYER_VERSION=$(aws lambda publish-layer-version \
                --layer-name "${LAYER_NAME}-nodejs${version}-${arch}" \
                --description "better-sqlite3 Lambda Layer for Node.js ${version} (${arch})" \
                --compatible-runtimes "nodejs${version}.x" \
                --compatible-architectures "${arch}" \
                --zip-file "fileb://${zip_file}" \
                --region "${region}" \
                --output json)

            # Extract version number
            VERSION_NUMBER=$(echo $LAYER_VERSION | jq -r '.Version')

            # Make the layer public
            aws lambda add-layer-version-permission \
                --layer-name "${LAYER_NAME}-nodejs${version}-${arch}" \
                --version-number $VERSION_NUMBER \
                --statement-id "public" \
                --action "lambda:GetLayerVersion" \
                --principal "*" \
                --region "${region}"

            # Get the layer ARN
            LAYER_ARN=$(echo $LAYER_VERSION | jq -r '.LayerVersionArn')

            # Update the versions file
            CURRENT_JSON=$(cat "$VERSIONS_FILE")

            # Create layer name with architecture
            layer_name="nodejs${version}-${arch}"

            # Update JSON with the new information, including the hash
            NEW_JSON=$(echo "$CURRENT_JSON" | jq \
                --arg layer "${layer_name}" \
                --arg region "$region" \
                --arg arn "$LAYER_ARN" \
                --arg version "$VERSION_NUMBER" \
                --arg hash "$current_hash" \
                --arg arch "${arch}" \
                --arg node_version "${version}" \
                'if has($layer) then
                    if .[$layer] | has($region) then
                        .[$layer][$region] = {
                            "version": $version,
                            "arn": $arn,
                            "hash": $hash,
                            "architecture": $arch,
                            "node_version": $node_version,
                            "last_updated": (now | strftime("%Y-%m-%d %H:%M:%S"))
                        }
                    else
                        .[$layer][$region] = {
                            "version": $version,
                            "arn": $arn,
                            "hash": $hash,
                            "architecture": $arch,
                            "node_version": $node_version,
                            "last_updated": (now | strftime("%Y-%m-%d %H:%M:%S"))
                        }
                    end
                 else
                    . + {($layer): {($region): {
                        "version": $version,
                        "arn": $arn,
                        "hash": $hash,
                        "architecture": $arch,
                        "node_version": $node_version,
                        "last_updated": (now | strftime("%Y-%m-%d %H:%M:%S"))
                    }}}
                 end')

            echo "$NEW_JSON" > "$VERSIONS_FILE"

            echo "Layer ARN for Node.js ${version} (${arch}) in ${region}: ${LAYER_ARN}"
            echo "----------------------------------------"
        done
    done
done