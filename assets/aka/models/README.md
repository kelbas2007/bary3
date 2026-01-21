# AKA Model Files

This directory contains the local LLM model files (compressed with xz).

## Model v1

- File: `model_v1.bin.xz` (compressed)
- Model: Llama 3.2 3B Q3_K_S
- Compressed size: ~350MB (xz)
- Uncompressed size: ~1.1GB
- Format: GGUF (compressed with xz)
- Compression: xz (for smaller APK size)
- **Note**: Q3_K_S provides good balance between quality and size

## Download and Compression

Run the automated script:
```powershell
.\scripts\download_model.ps1
```

The script will:
1. Download `Llama-3.2-3B-Instruct-Q3_K_S.gguf` (~1.1GB)
2. Compress it with xz to `model_v1.bin.xz` (~350MB)
3. Place the compressed file in this directory

### Manual Download

1. Download from Hugging Face:
   - URL: https://huggingface.co/bartowski/Llama-3.2-3B-Instruct-GGUF
   - File: `Llama-3.2-3B-Instruct-Q3_K_S.gguf`

2. Compress with xz (maximum compression):
   ```bash
   xz -z -k -9 Llama-3.2-3B-Instruct-Q3_K_S.gguf
   ```

3. Rename and place:
   ```bash
   mv Llama-3.2-3B-Instruct-Q3_K_S.gguf.xz model_v1.bin.xz
   cp model_v1.bin.xz assets/aka/models/
   ```

## Decompression

The model is automatically decompressed on first launch by `ModelLoader`.
The decompressed file is stored in the app's documents directory:
- Android: `/data/data/com.example.bary3/files/aka_models/model_v1.bin`
- iOS: `Documents/aka_models/model_v1.bin`

## Requirements

- **xz utility** for compression (Windows: https://tukaani.org/xz/ or use 7-Zip)
- **Decompression**: Handled automatically by the app on first launch

## Note

- Compressed model files (`.xz`) are included in git/assets
- Uncompressed models are NOT included in git (too large)
- The app decompresses the model on first use
