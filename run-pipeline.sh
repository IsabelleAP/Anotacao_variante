#!/bin/bash

set -e

IMAGE_NAME="ngs_variant_pipeline"
CONTAINER_NAME="ngs_variant_pipeline"

echo "Construindo imagem Docker..."

docker build -f docker/Dockerfile -t $IMAGE_NAME .

echo "Verificando container..."

if ! docker container inspect $CONTAINER_NAME >/dev/null 2>&1; then

    docker run -dit \
        --name $CONTAINER_NAME \
        -v "$(pwd)":/workspace \
        -w /workspace \
        $IMAGE_NAME

else

    docker start $CONTAINER_NAME >/dev/null

fi

docker exec $CONTAINER_NAME bash -c '

echo "Pipeline de Anotação de Variante (NGS)"

echo "[1/6] Provisionando ambiente..."
bash 01_provisionamento_ambiente/provisionamento_ambiente.sh

echo "[2/6] Controle de qualidade..."
bash 03_amostra/3_1_qc.sh

echo "[3/6] Alinhamento..."
bash 03_amostra/3_2_mapeamento_montagem.sh

echo "[4/6] Chamada de variantes..."
bash 04_chamada_variante/4_1_chamada_variante.sh

echo "[5/6] Anotação..."
bash 05_anotacao_variante/05_anotacao_variante.sh

echo "[6/6] Análise dos resultados..."
python3 06_analise_dados/analise.py

echo "Pipeline finalizado com sucesso!"

'