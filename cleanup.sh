#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

NODE_VERSIONS=("18" "20" "22")
REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
LAYER_NAME="better-sqlite3"

echo "============================================"
echo "🧹 Starting cleanup process..."
echo "============================================"

for region in "${REGIONS[@]}"; do
    echo "🌎 Processing region: ${region}"

    for version in "${NODE_VERSIONS[@]}"; do
        layer_full_name="${LAYER_NAME}-nodejs${version}"
        echo "  📦 Cleaning layer: ${layer_full_name}"

        # Get all versions of the layer
        versions=$(aws lambda list-layer-versions \
            --layer-name "$layer_full_name" \
            --region "$region" \
            --query 'LayerVersions[*].Version' \
            --output text)

        if [ -z "$versions" ]; then
            echo "    ⏭️  No versions found"
            continue
        fi

        # Delete each version
        for ver in $versions; do
            echo "    🗑️  Deleting version $ver"
            aws lambda delete-layer-version \
                --layer-name "$layer_full_name" \
                --version-number "$ver" \
                --region "$region"
        done
    done
done

# Clean up the versions file if it exists
if [ -f "layer_versions.json" ]; then
    echo "🧹 Cleaning layer_versions.json"
    echo "{}" > layer_versions.json
fi

echo "============================================"
echo "✅ Cleanup completed!"
echo "============================================"