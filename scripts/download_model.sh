#!/bin/bash
# Скрипт для скачивания модели Llama 3.2 3B Q4_K_M
# 
# Требования:
# - wget или curl
# - Git LFS (для больших файлов)

set -e

echo "=== Downloading Llama 3.2 3B Q4_K_M model ==="

MODEL_DIR="assets/aka/models"
MODEL_NAME="llama-3.2-3b-q4_k_m.gguf"
MODEL_URL="https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"

# Создаем директорию если не существует
mkdir -p "$MODEL_DIR"

# Проверяем, существует ли уже модель
if [ -f "$MODEL_DIR/$MODEL_NAME" ]; then
    echo "Model already exists: $MODEL_DIR/$MODEL_NAME"
    read -p "Do you want to re-download? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping download"
        exit 0
    fi
    rm "$MODEL_DIR/$MODEL_NAME"
fi

echo "Downloading model from Hugging Face..."
echo "URL: $MODEL_URL"
echo "Destination: $MODEL_DIR/$MODEL_NAME"

# Используем wget или curl
if command -v wget &> /dev/null; then
    wget -O "$MODEL_DIR/$MODEL_NAME" "$MODEL_URL"
elif command -v curl &> /dev/null; then
    curl -L -o "$MODEL_DIR/$MODEL_NAME" "$MODEL_URL"
else
    echo "ERROR: Neither wget nor curl found. Please install one of them."
    exit 1
fi

# Проверяем размер файла
FILE_SIZE=$(stat -f%z "$MODEL_DIR/$MODEL_NAME" 2>/dev/null || stat -c%s "$MODEL_DIR/$MODEL_NAME" 2>/dev/null)
EXPECTED_SIZE=2000000000 # ~2GB

if [ "$FILE_SIZE" -lt "$EXPECTED_SIZE" ]; then
    echo "WARNING: File size ($FILE_SIZE) is less than expected ($EXPECTED_SIZE)"
    echo "The download might be incomplete. Please check the file."
fi

echo ""
echo "=== Download complete ==="
echo "Model saved to: $MODEL_DIR/$MODEL_NAME"
echo "File size: $(du -h "$MODEL_DIR/$MODEL_NAME" | cut -f1)"

# Переименовываем для соответствия версии 1
if [ ! -f "$MODEL_DIR/model_v1.bin" ]; then
    cp "$MODEL_DIR/$MODEL_NAME" "$MODEL_DIR/model_v1.bin"
    echo "Also copied to: $MODEL_DIR/model_v1.bin"
fi
