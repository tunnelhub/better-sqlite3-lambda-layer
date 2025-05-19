#!/bin/bash -x

# Disable AWS CLI pager
export AWS_PAGER=""

# Create dist directory if it doesn't exist
mkdir -p dist

NODE_VERSIONS=("18" "20" "22")
ARCHITECTURES=("x86_64" "arm64")

for version in "${NODE_VERSIONS[@]}"; do
    for arch in "${ARCHITECTURES[@]}"; do
        echo "Building for Node.js ${version} on ${arch} architecture..."
        
        # Set platform flag for Docker
        if [ "$arch" == "x86_64" ]; then
            platform="linux/amd64"
        else
            platform="linux/arm64"
        fi

        # Build the image with platform
        docker build --platform=${platform} -t better-sqlite3-builder:nodejs${version}-${arch} \
            --file dockerfiles/Dockerfile.nodejs${version} .

        # Copy the ZIP file
        docker run --rm -v $(pwd)/dist:/output \
            better-sqlite3-builder:nodejs${version}-${arch} \
            cp /layer/better-sqlite3-layer-nodejs${version}-${arch}.zip /output/

        # Remove the image
        docker rmi better-sqlite3-builder:nodejs${version}-${arch}

        # List the generated file
        ls -lh dist/better-sqlite3-layer-nodejs${version}-${arch}.zip
    done
done