#!/bin/bash -x

# Disable AWS CLI pager
export AWS_PAGER=""

# Create dist directory if it doesn't exist
mkdir -p dist

NODE_VERSIONS=("18" "20" "22")

for version in "${NODE_VERSIONS[@]}"; do
    echo "Building for Node.js ${version}..."

    # Build the image
    docker build -t better-sqlite3-builder:nodejs${version} \
        --file dockerfiles/Dockerfile.nodejs${version} .

    # Copy the ZIP file
    docker run --rm -v $(pwd)/dist:/output \
        better-sqlite3-builder:nodejs${version} \
        cp /layer/better-sqlite3-layer-nodejs${version}.zip /output/

    # Remove the image
    docker rmi better-sqlite3-builder:nodejs${version}

    # List the generated file
    ls -lh dist/better-sqlite3-layer-nodejs${version}.zip
done