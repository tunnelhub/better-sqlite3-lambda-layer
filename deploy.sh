#!/bin/bash

# Stop on first error
set -e

echo "============================================"
echo "Starting deployment process..."
echo "============================================"

# Get better-sqlite3 version from package.json
SQLITE_VERSION=$(jq -r '.dependencies["better-sqlite3"]' package.json)

# 1. Build the layers
echo "📦 Building layers..."
echo "--------------------------------------------"
./build.sh

# 2. Publish to AWS
echo "============================================"
echo "🚀 Publishing to AWS..."
echo "--------------------------------------------"
TEMP_DIR=$(mktemp -d)
./publish.sh | tee "$TEMP_DIR/publish_output.txt"

# 3. Update README.md
echo "============================================"
echo "📝 Updating README.md with latest ARNs..."
echo "--------------------------------------------"

# Create initial README content
cat > README.md << EOL
# better-sqlite3 Lambda Layer

This repository contains the source code and scripts to build and publish AWS Lambda Layers for [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) across different Node.js versions and architectures.

## Available Versions

Each layer is provided in architecture-specific variants to ensure optimal compatibility and performance.

### x86_64 Architecture Layers

| Node.js Version | better-sqlite3 Version | Region | ARN |
|----------------|----------------------|---------|-----|
EOL

# Process output for x86_64 architecture
while IFS= read -r line; do
    if [[ $line =~ "Layer ARN for Node.js" && $line =~ "(x86_64)" ]]; then
        # Extract only the values we need
        node_version=$(echo "$line" | grep -o "Node.js [0-9]\+" | cut -d' ' -f2)
        region=$(echo "$line" | grep -o "in [^:]\+" | cut -d' ' -f2)
        arn=$(echo "$line" | grep -o "arn:[^[:space:]]\+")

        # Generate a clean table row
        echo "| v${node_version} | ${SQLITE_VERSION} | ${region} | \`${arn}\` |" >> README.md
    fi
done < "$TEMP_DIR/publish_output.txt"

# Add ARM64 section
cat >> README.md << EOL

### ARM64 Architecture Layers

| Node.js Version | better-sqlite3 Version | Region | ARN |
|----------------|----------------------|---------|-----|
EOL

# Process output for arm64 architecture
while IFS= read -r line; do
    if [[ $line =~ "Layer ARN for Node.js" && $line =~ "(arm64)" ]]; then
        # Extract only the values we need
        node_version=$(echo "$line" | grep -o "Node.js [0-9]\+" | cut -d' ' -f2)
        region=$(echo "$line" | grep -o "in [^:]\+" | cut -d' ' -f2)
        arn=$(echo "$line" | grep -o "arn:[^[:space:]]\+")

        # Generate a clean table row
        echo "| v${node_version} | ${SQLITE_VERSION} | ${region} | \`${arn}\` |" >> README.md
    fi
done < "$TEMP_DIR/publish_output.txt"

# Add the rest of the README content
cat >> README.md << 'EOL'

## Usage

1. **Choose the appropriate layer** based on your Lambda function's architecture:
   - Use an **x86_64** layer if your Lambda is running on the standard x86 architecture
   - Use an **ARM64** layer if your Lambda is running on AWS Graviton2 processors

2. Select the layer ARN that matches your:
   - Node.js version
   - AWS region
   - CPU architecture (from the appropriate section above)

3. Add the selected layer to your Lambda function

4. Import better-sqlite3 in your code as usual:

```javascript
const Database = require('better-sqlite3');
const db = new Database('/tmp/db.sqlite');
```

> **Note:** Each layer is now clearly named with its architecture for easier identification. For example: `better-sqlite3-nodejs18-x86_64` and `better-sqlite3-nodejs18-arm64`.

## Supported Architectures

- x86_64 (AMD64)
- arm64 (ARM, Graviton)

## Building Locally

To build the layers locally:

1. Clone this repository:
```bash
git clone https://github.com/tunnelhub/better-sqlite3-lambda-layer.git
```

2. Ensure Docker is installed with multi-architecture support

3. Run the build script:
```bash
./build.sh
```

This will generate ZIP files in the `dist` directory for each Node.js version and architecture:
- `better-sqlite3-layer-nodejs18-x86_64.zip`
- `better-sqlite3-layer-nodejs18-arm64.zip`
- `better-sqlite3-layer-nodejs20-x86_64.zip`
- `better-sqlite3-layer-nodejs20-arm64.zip`
- `better-sqlite3-layer-nodejs22-x86_64.zip`
- `better-sqlite3-layer-nodejs22-arm64.zip`

## Publishing to AWS

To publish the layers to AWS:

1. Configure your AWS credentials

2. Run the publish script:
```bash
./publish.sh
```

## Project Structure

```
📁 better-sqlite3-layer/
├── 📄 package.json
├── 📄 build.sh         # Builds layers for multiple Node.js versions and architectures
├── 📄 publish.sh       # Publishes layers to AWS Lambda with architecture-specific names
├── 📄 deploy.sh        # Full deployment workflow (build + publish + update README)
├── 📄 cleanup.sh       # Cleanup utility for removing temporary files
├── 📄 layer_versions.json  # Tracks published layer versions and metadata
└── 📁 dockerfiles/
    ├── 📄 Dockerfile.nodejs18
    ├── 📄 Dockerfile.nodejs20
    └── 📄 Dockerfile.nodejs22
```

## Architecture-Specific Layers

This project creates separate Lambda Layers for each architecture, clearly identifiable by their names:

- `better-sqlite3-nodejs18-x86_64` - For x86_64/AMD64 architecture
- `better-sqlite3-nodejs18-arm64` - For ARM64/Graviton architecture

This approach ensures:
1. Clear identification of architecture compatibility
2. Independent versioning for each architecture
3. Simplified selection during Lambda function configuration

## Contributing

Contributions are welcome! Feel free to submit pull requests.

## License

[MIT](LICENSE)
EOL

# Clean up
rm -rf "$TEMP_DIR"

echo "============================================"
echo "✅ Deployment completed successfully!"
echo "--------------------------------------------"
echo "📄 Check layer_versions.json for detailed version history"
echo "📄 Check README.md for updated ARNs"
echo "============================================"