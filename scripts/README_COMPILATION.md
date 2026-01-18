# Инструкции по компиляции llama.cpp

## ✅ Рекомендуемый способ: GitHub Actions

**Самый простой способ** - использовать GitHub Actions:

1. Откройте `.github/workflows/build_llama.yml`
2. Запустите workflow вручную через GitHub UI
3. Скачайте артефакты после завершения
4. Разместите библиотеки в проекте

**Подробные инструкции:** `docs/GITHUB_ACTIONS_COMPILATION.md`

## Альтернативные способы

### Способ 1: WSL (требует установки дистрибутива)

После установки WSL и дистрибутива:

```powershell
.\scripts\compile_via_wsl.ps1
```

Или вручную в WSL:

```bash
cd /mnt/c/flutter_projects/bary3
export ANDROID_NDK_HOME=/mnt/c/path/to/android-ndk
bash scripts/build_llama_android.sh
```

### Способ 2: Локальная Linux машина

```bash
export ANDROID_NDK_HOME=/path/to/android-ndk
bash scripts/build_llama_android.sh
```

### Способ 3: Docker

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -e ANDROID_NDK_HOME=/path/to/ndk \
  android-ndk-builder \
  bash scripts/build_llama_android.sh
```

## Текущий статус

✅ **Модель:** Скачана (1.88 GB)  
✅ **FFI Binding:** Готов  
⏳ **Библиотеки:** Требуется компиляция

## После компиляции

1. Проверьте наличие библиотек:
   ```powershell
   Test-Path "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
   ```

2. Обновите FFI типы при необходимости:
   ```powershell
   .\scripts\check_ffi_signatures.ps1 -LibraryPath "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
   ```

3. Протестируйте загрузку:
   ```dart
   final engine = LlamaFFIBinding();
   final initialized = await engine.initialize('assets/aka/models/model_v1.bin', 'You are Bari...');
   ```
