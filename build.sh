#!/bin/bash -x

# Versões do Node.js a serem construídas
NODE_VERSIONS=("18" "20" "22")

# Construir para cada versão
for version in "${NODE_VERSIONS[@]}"; do
    echo "Building for Node.js ${version}..."

    # Construir a imagem Docker
    docker build -t better-sqlite3-builder:node${version} \
        --file dockerfiles/Dockerfile.node${version} .

    # Extrair o arquivo ZIP
    docker run --rm -v $(pwd):/output \
        better-sqlite3-builder:node${version} \
        cp /layer/better-sqlite3-layer-node${version}.zip /output/

    # Remover a imagem
    docker rmi better-sqlite3-builder:node${version}

    # Listar o arquivo gerado
    ls -lh better-sqlite3-layer-node${version}.zip
done