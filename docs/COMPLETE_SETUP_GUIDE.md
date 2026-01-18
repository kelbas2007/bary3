# Полное руководство по настройке llama.cpp для АКА

## Что уже сделано автоматически

✅ **Структура проекта:**
- Созданы все необходимые директории
- Настроен `build.gradle.kts` для jniLibs
- Добавлены README файлы с инструкциями

✅ **Код:**
- FFI binding реализован (работает в stub mode)
- Менеджер версий моделей
- Загрузчик моделей с кэшированием
- Построитель промптов

✅ **Скрипты:**
- PowerShell скрипты для Windows
- Bash скрипты для Linux/WSL
- GitHub Actions workflow

## Что нужно сделать вручную

### Шаг 1: Скачивание модели (~2GB)

**Вариант A: Автоматически (PowerShell)**
```powershell
.\scripts\download_model.ps1
```

**Вариант B: Вручную**
1. Откройте в браузере:
   https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF
2. Скачайте файл `Llama-3.2-3B-Instruct-Q4_K_M.gguf`
3. Переименуйте в `model_v1.bin`
4. Разместите в `assets/aka/models/model_v1.bin`

**Вариант C: Через Git LFS (если настроен)**
```bash
git lfs install
git lfs pull
```

### Шаг 2: Компиляция llama.cpp

#### Для Android

**Требования:**
- Android NDK (r25c или новее)
- CMake 3.18+
- WSL2 или Linux машина

**Способ 1: WSL2 (рекомендуется для Windows)**
```bash
# В WSL
cd /mnt/c/flutter_projects/bary3
export ANDROID_NDK_HOME=/mnt/c/Users/YourName/AppData/Local/Android/Sdk/ndk/25.2.9519653
bash scripts/build_llama_android.sh
```

**Способ 2: GitHub Actions (автоматически)**
1. Создайте `.github/workflows/build_llama.yml`
2. Скопируйте содержимое из `scripts/setup_llama_github_actions.yml`
3. Запустите workflow через GitHub Actions UI
4. Скачайте артефакты после завершения
5. Разместите библиотеки в `android/app/src/main/jniLibs/`

**Способ 3: Готовые библиотеки**
Если доступны pre-compiled библиотеки:
- Скачайте с GitHub releases llama.cpp
- Извлеките `libllama.so` для нужной архитектуры
- Разместите в `android/app/src/main/jniLibs/<arch>/`

#### Для iOS

**Требования:**
- Xcode Command Line Tools
- CMake 3.18+
- macOS

```bash
chmod +x scripts/build_llama_ios.sh
./scripts/build_llama_ios.sh
```

### Шаг 3: Обновление FFI типов

После компиляции библиотеки:

1. **Генерировать шаблон типов:**
   ```powershell
   .\scripts\update_ffi_types.ps1 -GenerateTemplate
   ```

2. **Проверить сигнатуры функций:**
   ```powershell
   .\scripts\check_ffi_signatures.ps1 -LibraryPath "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
   ```

3. **Обновить типы в коде:**
   - Откройте `lib/bari_smart/aca/local_llm/ffi_types_template.dart`
   - Сравните с реальными сигнатурами из `llama.h`
   - Обновите типы в `llama_ffi_binding.dart`
   - Раскомментируйте и реализуйте функции

## Проверка установки

### Проверить структуру
```powershell
# Android библиотеки
Get-ChildItem -Recurse android\app\src\main\jniLibs\

# iOS framework
Test-Path ios\Frameworks\llama.framework\llama

# Модель
Test-Path assets\aka\models\model_v1.bin
(Get-Item assets\aka\models\model_v1.bin).Length / 1GB  # Должно быть ~2GB
```

### Протестировать загрузку
```dart
final loader = ModelLoader();
final modelPath = await loader.loadModel(akaVersion: 1);
print('Model path: $modelPath');

final engine = LlamaFFIBinding();
final initialized = await engine.initialize(modelPath, 'You are Bari...');
print('Initialized: $initialized');
```

## Режим разработки (Stub Mode)

**Важно:** FFI binding работает в режиме заглушки без реальной библиотеки!

Это означает:
- ✅ Можно разрабатывать остальные компоненты АКА
- ✅ Приложение компилируется и запускается
- ✅ Можно тестировать интеграцию кода
- ⏳ Реальная генерация требует скомпилированной библиотеки

## Альтернативные решения

### Если компиляция невозможна

1. **Использовать готовый пакет** (если доступен):
   ```yaml
   dependencies:
     llama_cpp_dart: ^0.1.0
   ```

2. **Использовать облачный API** (временно):
   - OpenAI API (но это не локально)
   - Hugging Face Inference API

3. **Отложить до production:**
   - Разрабатывать остальные компоненты АКА
   - Компилировать библиотеки позже

### Если модель не скачивается

1. **Скачать вручную через браузер**
2. **Использовать другой источник:**
   - Прямая ссылка на файл
   - Torrent (если доступен)
   - Другая модель меньшего размера для тестирования

## Устранение проблем

### Ошибка загрузки библиотеки

```
Error loading library: DynamicLibrary.open failed
```

**Решение:**
- Проверьте путь к библиотеке
- Убедитесь, что библиотека скомпилирована как shared library
- Проверьте архитектуру устройства

### Ошибка загрузки модели

```
Error loading model: File not found
```

**Решение:**
- Проверьте путь: `assets/aka/models/model_v1.bin`
- Убедитесь, что файл добавлен в `pubspec.yaml`
- Проверьте размер файла (~2GB)

### FFI типы не совпадают

**Решение:**
1. Проверьте версию llama.cpp
2. Используйте `nm` для проверки символов
3. Сверьтесь с `llama.h` header файлом
4. Обновите типы в `llama_ffi_binding.dart`

## Следующие шаги

После полной настройки:
1. ✅ Протестировать загрузку модели
2. ✅ Протестировать генерацию текста
3. ✅ Интегрировать в `BariSmart`
4. ✅ Перейти к Фазе 1.2 (Бинарный векторный индекс)

## Полезные ссылки

- [llama.cpp GitHub](https://github.com/ggerganov/llama.cpp)
- [llama.cpp Documentation](https://github.com/ggerganov/llama.cpp/blob/master/README.md)
- [Hugging Face Model](https://huggingface.co/hugging-quants/Llama-3.2-3B-Instruct-Q4_K_M-GGUF)
- [Dart FFI Guide](https://dart.dev/guides/libraries/c-interop)
