# better-sqlite3 Lambda Layer

This repository contains the source code and scripts to build and publish AWS Lambda Layers for [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) across different Node.js versions.

## Available Versions

| Node.js Version | better-sqlite3 Version | Region | Architecture | ARN |
|----------------|----------------------|---------|--------------|-----|
| v18 | ^11.7.0 | us-east-1 | x86_64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs18:2` |
| v18 | ^11.7.0 | us-east-2 | x86_64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs18:2` |
| v18 | ^11.7.0 | us-west-1 | x86_64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs18:2` |
| v18 | ^11.7.0 | us-west-2 | x86_64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs18:2` |
| v18 | ^11.7.0 | us-east-1 | arm64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs18:3` |
| v18 | ^11.7.0 | us-east-2 | arm64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs18:3` |
| v18 | ^11.7.0 | us-west-1 | arm64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs18:3` |
| v18 | ^11.7.0 | us-west-2 | arm64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs18:3` |
| v20 | ^11.7.0 | us-east-1 | x86_64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs20:2` |
| v20 | ^11.7.0 | us-east-2 | x86_64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs20:2` |
| v20 | ^11.7.0 | us-west-1 | x86_64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs20:2` |
| v20 | ^11.7.0 | us-west-2 | x86_64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs20:2` |
| v20 | ^11.7.0 | us-east-1 | arm64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs20:3` |
| v20 | ^11.7.0 | us-east-2 | arm64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs20:3` |
| v20 | ^11.7.0 | us-west-1 | arm64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs20:3` |
| v20 | ^11.7.0 | us-west-2 | arm64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs20:3` |
| v22 | ^11.7.0 | us-east-1 | x86_64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs22:2` |
| v22 | ^11.7.0 | us-east-2 | x86_64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs22:2` |
| v22 | ^11.7.0 | us-west-1 | x86_64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs22:2` |
| v22 | ^11.7.0 | us-west-2 | x86_64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs22:2` |
| v22 | ^11.7.0 | us-east-1 | arm64 | `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-nodejs22:3` |
| v22 | ^11.7.0 | us-east-2 | arm64 | `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-nodejs22:3` |
| v22 | ^11.7.0 | us-west-1 | arm64 | `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-nodejs22:3` |
| v22 | ^11.7.0 | us-west-2 | arm64 | `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-nodejs22:3` |

## Usage

1. Select the layer ARN that matches your Node.js version, AWS region, and architecture
2. Add the layer to your Lambda function
3. Import better-sqlite3 in your code as usual:

```javascript
const Database = require('better-sqlite3');
const db = new Database('/tmp/db.sqlite');
```

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
├── 📄 build.sh
├── 📄 publish.sh
├── 📄 deploy.sh
└── 📁 dockerfiles/
    ├── 📄 Dockerfile.nodejs18
    ├── 📄 Dockerfile.nodejs20
    └── 📄 Dockerfile.nodejs22
```

## Contributing

Contributions are welcome! Feel free to submit pull requests.

## License

[MIT](LICENSE)
