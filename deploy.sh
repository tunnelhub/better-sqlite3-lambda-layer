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

This repository contains the source code and scripts to build and publish AWS Lambda Layers for [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) across different Node.js versions.

## Available Versions

| Node.js Version | better-sqlite3 Version | Region | ARN |
|----------------|----------------------|---------|-----|
EOL

# Process output for all Node.js versions
while IFS= read -r line; do
    if [[ $line =~ "Layer ARN for Node.js" ]]; then
        # Extrair apenas os valores que precisamos
        node_version=$(echo "$line" | grep -o "Node.js [0-9]\+" | cut -d' ' -f2)
        region=$(echo "$line" | grep -o "in [^:]\+" | cut -d' ' -f2)
        arn=$(echo "$line" | grep -o "arn:[^[:space:]]\+")

        # Gerar linha da tabela com formato limpo
        echo "| v${node_version} | ${SQLITE_VERSION} | ${region} | \`${arn}\` |" >> README.md
    fi
done < "$TEMP_DIR/publish_output.txt"

# Add the rest of the README content
cat >> README.md << 'EOL'

## Usage

1. Select the layer ARN that matches your Node.js version and AWS region
2. Add the layer to your Lambda function
3. Import better-sqlite3 in your code as usual:

```javascript
const Database = require('better-sqlite3');
const db = new Database('/tmp/db.sqlite');
```

## Supported Architecture

- x86_64 (AMD64)

## Building Locally

To build the layers locally:

1. Clone this repository:
```bash
git clone https://github.com/tunnelhub/better-sqlite3-lambda-layer.git
```

2. Ensure Docker is installed

3. Run the build script:
```bash
./build.sh
```

This will generate ZIP files in the `dist` directory for each Node.js version:
- `better-sqlite3-layer-nodejs18.zip`
- `better-sqlite3-layer-nodejs20.zip`
- `better-sqlite3-layer-nodejs22.zip`

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
├── 📄 build.sh
├── 📄 publish.sh
├── 📄 .nvmrc
└── 📁 dockerfiles/
    ├── 📄 Dockerfile.nodejs18
    ├── 📄 Dockerfile.nodejs20
    └── 📄 Dockerfile.nodejs22
```

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