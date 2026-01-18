# Инструкция по настройке llama.cpp для АКА

## Обзор

Для работы локального LLM требуется:
1. Скомпилировать llama.cpp для Android/iOS
2. Разместить библиотеки в проекте
3. Скачать модель Llama 3.2 3B Q4_K_M
4. Настроить FFI binding

## Шаг 1: Компиляция llama.cpp для Android

### Требования
- Android NDK (r25c или новее)
- CMake 3.18+
- Git

### Процесс

1. **Установите Android NDK:**
   ```bash
   # Через Android Studio SDK Manager или вручную
   export ANDROID_NDK_HOME=/path/to/android-ndk
   ```

2. **Запустите скрипт сборки:**
   ```bash
   chmod +x scripts/build_llama_android.sh
   ./scripts/build_llama_android.sh
   ```

3. **Проверьте результат:**
   Библиотеки должны быть в:
   ```
   android/app/src/main/jniLibs/
   ├── arm64-v8a/
   │   └── libllama.so
   └── x86_64/
       └── libllama.so
   ```

### Ручная сборка (если скрипт не работает)

```bash
# Клонируем llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
git submodule update --init --recursive

# Создаем директорию сборки
mkdir build-android && cd build-android

# Конфигурируем для arm64-v8a
cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-23 \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON

# Собираем
cmake --build . --config Release -j$(nproc)

# Копируем библиотеку
cp libllama.so ../../../android/app/src/main/jniLibs/arm64-v8a/
```

## Шаг 2: Компиляция llama.cpp для iOS

### Требования
- Xcode Command Line Tools
- CMake 3.18+
- Git

### Процесс

1. **Запустите скрипт сборки:**
   ```bash
   chmod +x scripts/build_llama_ios.sh
   ./scripts/build_llama_ios.sh
   ```

2. **Проверьте результат:**
   Framework должен быть в:
   ```
   ios/Frameworks/llama.framework/
   └── llama (универсальный binary)
   ```

### Ручная сборка

```bash
# Клонируем llama.cpp
git clone https://github.com/ggerganov/llama.cpp.git
cd llama.cpp
git submodule update --init --recursive

# Собираем для устройства
mkdir build-device && cd build-device
cmake .. \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DGGML_METAL=ON
cmake --build . --config Release

# Собираем для симулятора
cd .. && mkdir build-simulator && cd build-simulator
cmake .. \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release

# Создаем универсальный framework
lipo -create ../build-device/libllama.dylib ../build-simulator/libllama.dylib \
  -output ../../ios/Frameworks/llama.framework/llama
```

## Шаг 3: Скачивание модели

### Автоматически

```bash
chmod +x scripts/download_model.sh
./scripts/download_model.sh
```

### Вручную

1. **Скачайте модель с Hugging Face:**
   - URL: https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF
   - Файл: `Llama-3.2-3B-Instruct-Q4_K_M.gguf` (~2GB)

2. **Разместите в проекте:**
   ```bash
   # Переименуйте и скопируйте
   cp Llama-3.2-3B-Instruct-Q4_K_M.gguf assets/aka/models/model_v1.bin
   ```

3. **Проверьте размер:**
   ```bash
   ls -lh assets/aka/models/model_v1.bin
   # Должно быть ~2GB
   ```

## Шаг 4: Настройка FFI binding

FFI binding уже реализован в `lib/bari_smart/aca/local_llm/llama_ffi_binding.dart`.

**ВАЖНО:** После компиляции библиотеки может потребоваться корректировка FFI типов в зависимости от реальных сигнатур функций llama.cpp.

### Проверка сигнатур функций

Используйте `nm` или `objdump` для проверки экспортируемых символов:

```bash
# Android
nm -D android/app/src/main/jniLibs/arm64-v8a/libllama.so | grep llama

# iOS
nm ios/Frameworks/llama.framework/llama | grep llama
```

## Шаг 5: Обновление build.gradle.kts (Android)

Убедитесь, что библиотеки включены в APK:

```kotlin
android {
    // ...
    sourceSets {
        getByName("main") {
            jniLibs.srcDirs("src/main/jniLibs")
        }
    }
}
```

## Шаг 6: Обновление Xcode проекта (iOS)

1. Откройте `ios/Runner.xcworkspace` в Xcode
2. Добавьте `llama.framework` в "Frameworks, Libraries, and Embedded Content"
3. Убедитесь, что framework включен в "Embed Frameworks"

## Тестирование

После настройки проверьте работу:

```dart
final loader = ModelLoader();
final modelPath = await loader.loadModel(akaVersion: 1);

final engine = LlamaFFIBinding();
final initialized = await engine.initialize(modelPath, 'You are Bari...');

if (initialized) {
  final response = await engine.generate('Hello!');
  print('Response: $response');
}
```

## Устранение проблем

### Ошибка загрузки библиотеки

- Проверьте, что библиотека находится в правильной директории
- Проверьте архитектуру устройства (arm64-v8a для большинства Android устройств)
- Убедитесь, что библиотека скомпилирована как shared library (`BUILD_SHARED_LIBS=ON`)

### Ошибка загрузки модели

- Проверьте путь к модели
- Убедитесь, что файл модели существует и не поврежден
- Проверьте права доступа к файлу

### Низкая производительность

- Используйте Metal для iOS (`GGML_METAL=ON`)
- Уменьшите размер контекста (`n_ctx`)
- Используйте меньше потоков на слабых устройствах

## Дополнительные ресурсы

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [llama.cpp Documentation](https://github.com/ggerganov/llama.cpp/blob/master/README.md)
- [Hugging Face Model](https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF)
