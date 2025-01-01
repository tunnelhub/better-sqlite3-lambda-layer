# better-sqlite3 Lambda Layer

This repository contains the source code and scripts to build and publish AWS Lambda Layers for [better-sqlite3](https://github.com/WiseLibs/better-sqlite3) across different Node.js versions.

## Available Layers

### Node.js 18.x
Available in these regions:
- us-east-1: `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-node18:1`
- us-east-2: `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-node18:1`
- us-west-1: `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-node18:1`
- us-west-2: `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-node18:1`

### Node.js 20.x
Available in these regions:
- us-east-1: `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-node20:1`
- us-east-2: `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-node20:1`
- us-west-1: `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-node20:1`
- us-west-2: `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-node20:1`

### Node.js 22.x
Available in these regions:
- us-east-1: `arn:aws:lambda:us-east-1:521944920347:layer:better-sqlite3-node22:1`
- us-east-2: `arn:aws:lambda:us-east-2:521944920347:layer:better-sqlite3-node22:1`
- us-west-1: `arn:aws:lambda:us-west-1:521944920347:layer:better-sqlite3-node22:1`
- us-west-2: `arn:aws:lambda:us-west-2:521944920347:layer:better-sqlite3-node22:1`

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

## Versions

- better-sqlite3: ^11.7.0

## Building Locally

To build the layers locally:

1. Clone this repository:
```bash
git clone https://github.com/tunnelhub/better-sqlite3-lambda-layer
```

2. Ensure Docker is installed

3. Run the build script:
```bash
./build.sh
```

This will generate ZIP files for each Node.js version:
- `better-sqlite3-layer-node18.zip`
- `better-sqlite3-layer-node20.zip`
- `better-sqlite3-layer-node22.zip`

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
    ├── 📄 Dockerfile.node18
    ├── 📄 Dockerfile.node20
    └── 📄 Dockerfile.node22
```

## Contributing

Contributions are welcome! Feel free to submit pull requests.

## License

[MIT](LICENSE)