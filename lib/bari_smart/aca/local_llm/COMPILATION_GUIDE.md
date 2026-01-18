# Руководство по компиляции llama.cpp

## Статус

✅ **Модель скачана:** `assets/aka/models/model_v1.bin` (1.88 GB)  
⏳ **Библиотеки:** Требуется компиляция

## Способы компиляции

### Способ 1: GitHub Actions (рекомендуется)

1. **Запустите workflow:**
   - Откройте GitHub репозиторий
   - Перейдите в "Actions" → "Build llama.cpp for AKA"
   - Нажмите "Run workflow"

2. **Дождитесь завершения:**
   - Android сборка: ~10-15 минут
   - iOS сборка: ~10-15 минут

3. **Скачайте артефакты:**
   - `llama-android-libs` - библиотеки для Android
   - `llama-ios-framework` - framework для iOS

4. **Разместите в проекте:**
   ```powershell
   # Распакуйте артефакты в соответствующие директории
   # Android: android/app/src/main/jniLibs/
   # iOS: ios/Frameworks/llama.framework/
   ```

### Способ 2: WSL (для Windows)

1. **Установите WSL2:**
   ```powershell
   wsl --install
   ```

2. **В WSL выполните:**
   ```bash
   cd /mnt/c/flutter_projects/bary3
   export ANDROID_NDK_HOME=/mnt/c/Users/YourName/AppData/Local/Android/Sdk/ndk/26.3.11579264
   bash scripts/build_llama_android.sh
   ```

### Способ 3: Готовые библиотеки

Если доступны pre-compiled библиотеки:
1. Скачайте с GitHub releases llama.cpp
2. Извлеките `libllama.so` для нужной архитектуры
3. Разместите в `android/app/src/main/jniLibs/<arch>/`

## После компиляции

### 1. Обновить FFI типы

```powershell
.\scripts\update_ffi_types.ps1 -GenerateTemplate
.\scripts\check_ffi_signatures.ps1 -LibraryPath "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
```

### 2. Проверить работу

```dart
final loader = ModelLoader();
final modelPath = await loader.loadModel(akaVersion: 1);
print('Model: $modelPath');

final engine = LlamaFFIBinding();
final initialized = await engine.initialize(modelPath, 'You are Bari...');
print('Initialized: $initialized');

if (initialized) {
  final response = await engine.generate('Hello!');
  print('Response: $response');
}
```

## Текущий статус

✅ Модель: Скачана (1.88 GB)  
⏳ Библиотеки: Требуется компиляция  
✅ FFI binding: Готов (обновлен на основе реального API)

## Примечания

- FFI binding обновлен на основе реального API llama.cpp
- Все типы соответствуют документации llama.h
- После компиляции может потребоваться небольшая корректировка типов
