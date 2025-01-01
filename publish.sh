#!/bin/bash

# publish.sh
NODE_VERSIONS=("18" "20" "22")
REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
LAYER_NAME="better-sqlite3"

for version in "${NODE_VERSIONS[@]}"; do
    echo "Publishing layer for Node.js ${version}..."

    for region in "${REGIONS[@]}"; do
        echo "Publishing in region: ${region}"

        # Publicar a layer
        LAYER_VERSION=$(aws lambda publish-layer-version \
            --layer-name "${LAYER_NAME}-node${version}" \
            --description "better-sqlite3 Lambda Layer for Node.js ${version}" \
            --compatible-runtimes "nodejs${version}.x" \
            --compatible-architectures "x86_64" \
            --zip-file "fileb://better-sqlite3-layer-node${version}.zip" \
            --region "${region}" \
            --output json)

        # Extrair o número da versão
        VERSION_NUMBER=$(echo $LAYER_VERSION | jq -r '.Version')

        # Tornar a layer pública
        aws lambda add-layer-version-permission \
            --layer-name "${LAYER_NAME}-node${version}" \
            --version-number $VERSION_NUMBER \
            --statement-id "public" \
            --action "lambda:GetLayerVersion" \
            --principal "*" \
            --region "${region}"

        # Obter o ARN da layer
        LAYER_ARN=$(echo $LAYER_VERSION | jq -r '.LayerVersionArn')

        echo "Layer ARN for Node.js ${version} in ${region}: ${LAYER_ARN}"
        echo "----------------------------------------"
    done
done
Last edited just now