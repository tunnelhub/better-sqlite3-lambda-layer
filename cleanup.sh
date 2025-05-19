#!/bin/bash

# Disable AWS CLI pager
export AWS_PAGER=""

NODE_VERSIONS=("18" "20" "22")
REGIONS=("us-east-1" "us-east-2" "us-west-1" "us-west-2")
LAYER_NAME="better-sqlite3"

echo "============================================"
echo "🧹 Starting cleanup process..."
echo "============================================"

# Clean local build artifacts
echo "🧹 Cleaning local build artifacts..."
rm -rf dist/*.zip

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

# Clean Docker images if any exist
echo "🧹 Cleaning Docker images..."
for version in "${NODE_VERSIONS[@]}"; do
    # Check for x86_64 images
    if docker images | grep -q "better-sqlite3-builder:nodejs${version}-x86_64"; then
        echo "  🗑️  Removing image: better-sqlite3-builder:nodejs${version}-x86_64"
        docker rmi "better-sqlite3-builder:nodejs${version}-x86_64"
    fi
    
    # Check for arm64 images
    if docker images | grep -q "better-sqlite3-builder:nodejs${version}-arm64"; then
        echo "  🗑️  Removing image: better-sqlite3-builder:nodejs${version}-arm64"
        docker rmi "better-sqlite3-builder:nodejs${version}-arm64"
    fi
done

echo "============================================"
echo "✅ Cleanup completed!"
echo "============================================"