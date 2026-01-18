#!/usr/bin/env python3
"""
Скрипт для скачивания модели Llama 3.2 3B Q4_K_M через huggingface_hub

Требования:
    pip install huggingface_hub

Использование:
    python scripts/download_model_python.py
"""

import os
import shutil
from pathlib import Path

try:
    from huggingface_hub import hf_hub_download
except ImportError:
    print("ERROR: huggingface_hub not installed")
    print("Install with: pip install huggingface_hub")
    exit(1)

# Настройки
REPO_ID = "bartowski/Llama-3.2-3B-Instruct-GGUF"
FILENAME = "Llama-3.2-3B-Instruct-Q4_K_M.gguf"
TARGET_DIR = "assets/aka/models"
TARGET_FILE = "model_v1.bin"

print("=== Downloading Llama 3.2 3B Q4_K_M model ===")
print(f"Repository: {REPO_ID}")
print(f"File: {FILENAME}")
print(f"Target: {TARGET_DIR}/{TARGET_FILE}")
print("")

# Создаем директорию если не существует
os.makedirs(TARGET_DIR, exist_ok=True)

# Проверяем, существует ли уже модель
target_path = os.path.join(TARGET_DIR, TARGET_FILE)
if os.path.exists(target_path):
    file_size = os.path.getsize(target_path) / (1024 * 1024 * 1024)  # GB
    print(f"Model already exists: {target_path} ({file_size:.2f} GB)")
    response = input("Do you want to re-download? (y/N): ")
    if response.lower() != 'y':
        print("Skipping download")
        exit(0)
    os.remove(target_path)

try:
    print("Downloading model (this may take a while, ~2GB)...")
    print("")
    
    # Скачиваем модель
    downloaded_path = hf_hub_download(
        repo_id=REPO_ID,
        filename=FILENAME,
        local_dir=TARGET_DIR,
        local_dir_use_symlinks=False,
    )
    
    print(f"Downloaded to: {downloaded_path}")
    
    # Переименовываем в model_v1.bin
    if downloaded_path != target_path:
        if os.path.exists(target_path):
            os.remove(target_path)
        shutil.move(downloaded_path, target_path)
        print(f"Renamed to: {target_path}")
    
    # Проверяем размер
    file_size = os.path.getsize(target_path)
    file_size_gb = file_size / (1024 * 1024 * 1024)
    print(f"")
    print("=== Download complete ===")
    print(f"Model saved to: {target_path}")
    print(f"File size: {file_size_gb:.2f} GB")
    
    if file_size < 1_500_000_000:  # Меньше 1.5GB
        print("")
        print("WARNING: File size is less than expected (~2GB)")
        print("The download might be incomplete. Please check the file.")
    else:
        print("")
        print("Model downloaded successfully!")
        
except Exception as e:
    print("")
    print(f"ERROR: Download failed: {e}")
    print("")
    print("Alternative: Download manually from:")
    print(f"https://huggingface.co/{REPO_ID}/tree/main")
    print("")
    print(f"Then copy the file to: {target_path}")
    exit(1)
