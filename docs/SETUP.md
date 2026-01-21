# Настройка проекта

Полное руководство по настройке окружения разработки, установке модели LLM и компиляции библиотек.

## Требования

### Базовые требования
- Flutter SDK 3.x или выше
- Dart 3.x или выше
- Git
- Android Studio / VS Code с расширениями Flutter и Dart

### Для Android разработки
- Android SDK
- Android NDK (r25c или новее) - для компиляции llama.cpp
- Java JDK 11 или выше

### Для iOS разработки (только macOS)
- Xcode 14 или выше
- CocoaPods
- macOS 12.0 или выше

## Установка окружения

### 1. Установка Flutter

```bash
# Скачайте Flutter SDK
# https://docs.flutter.dev/get-started/install

# Добавьте в PATH
export PATH="$PATH:/path/to/flutter/bin"

# Проверьте установку
flutter doctor
```

### 2. Установка зависимостей проекта

```bash
cd bary3
flutter pub get
flutter gen-l10n
```

### 3. Настройка Android

```bash
# Установите Android Studio
# Настройте Android SDK через SDK Manager
# Установите Android NDK (для компиляции llama.cpp)
```

## Установка модели LLM

### Текущая модель: Llama 3.2 3B Q3_K_S

**Параметры:**
- **Источник:** `unsloth/Llama-3.2-3B-Instruct-GGUF`
- **Квантование:** Q3_K_S (компромисс между качеством и размером)
- **Несжатый размер:** ~1.47 GB
- **Сжатый размер (xz):** ~350 MB
- **Формат:** GGUF

### Автоматическая установка

```powershell
# Windows
.\scripts\download_model.ps1

# Linux/macOS
bash scripts/download_model.sh
```

Скрипт автоматически:
1. Скачает модель с HuggingFace
2. Сожмет модель в формат xz
3. Сохранит в `assets/aka/models/model_v1.bin.xz`

### Ручная установка

1. **Скачайте модель:**
   ```
   https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q3_K_S.gguf
   ```

2. **Сохраните как** `assets/aka/models/model_v1_temp.gguf`

3. **Сожмите с помощью 7-Zip:**
   ```powershell
   "C:\Program Files\7-Zip\7z.exe" a -txz -mx=9 -mmt=on assets\aka\models\model_v1.bin.xz assets\aka\models\model_v1_temp.gguf
   ```

4. **Удалите временный файл**

### Проверка установки

```powershell
.\scripts\check_model_status.ps1
```

Ожидаемый размер: ~350 MB

## Компиляция llama.cpp библиотек

### Способ 1: GitHub Actions (рекомендуется)

1. **Запустите workflow:**
   - Откройте GitHub репозиторий
   - Перейдите в "Actions" → "Build llama.cpp for AKA"
   - Нажмите "Run workflow"

2. **Дождитесь завершения:**
   - Android сборка: ~15-20 минут
   - iOS сборка: ~15-20 минут

3. **Скачайте артефакты:**
   - `llama-android-libs` - библиотеки для Android
   - `llama-ios-framework` - framework для iOS

4. **Разместите в проекте:**
   ```powershell
   # Android: android/app/src/main/jniLibs/
   # iOS: ios/Frameworks/llama.framework/
   ```

### Способ 2: WSL (для Windows)

```bash
# В WSL
cd /mnt/c/flutter_projects/bary3
export ANDROID_NDK_HOME=/mnt/c/path/to/android-ndk
bash scripts/build_llama_android.sh
```

### Способ 3: Локальная компиляция

**Android:**
```bash
export ANDROID_NDK_HOME=/path/to/android-ndk
chmod +x scripts/build_llama_android.sh
./scripts/build_llama_android.sh
```

**iOS (только macOS):**
```bash
chmod +x scripts/build_llama_ios.sh
./scripts/build_llama_ios.sh
```

## Структура после настройки

```
bary3/
├── assets/
│   └── aka/
│       └── models/
│           └── model_v1.bin.xz  # ~350 MB
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── jniLibs/      # llama.cpp библиотеки
│                   ├── arm64-v8a/
│                   │   └── libllama.so
│                   └── x86_64/
│                       └── libllama.so
└── ios/
    └── Frameworks/
        └── llama.framework/      # iOS framework
```

## Проверка готовности

```bash
# Проверка модели
Test-Path "assets\aka\models\model_v1.bin.xz"

# Проверка библиотек Android
Test-Path "android\app\src\main\jniLibs\arm64-v8a\libllama.so"

# Проверка кода
flutter analyze
```

## Версионирование моделей

Модели версионируются через `ModelVersionManager`:
- `model_v1.bin.xz` - версия 1 (Llama 3.2 3B Q3_K_S)
- `model_v2.bin.xz` - версия 2 (запланировано: Llama 4 3B Q3_K_S)

## Сравнение версий моделей

| Версия | Размер (сжатый) | Качество | Скорость |
|--------|----------------|----------|----------|
| Q2_K | ~200-300 MB | Базовое | Быстро |
| **Q3_K_S** | **~350 MB** | **Хорошее** | **Средне** |
| Q4_K_S | ~450 MB | Отличное | Медленно |

**Текущий выбор:** Q3_K_S - оптимальный баланс между качеством и размером.

## Решение проблем

### Модель не загружается
- Проверьте наличие файла `model_v1.bin.xz`
- Проверьте размер файла (~350 MB)
- Проверьте права доступа

### Библиотеки не найдены
- Убедитесь, что библиотеки размещены в правильных директориях
- Проверьте архитектуру устройства (arm64-v8a для большинства Android устройств)
- Пересоберите приложение: `flutter clean && flutter pub get`

### Ошибки компиляции
- Проверьте версию Android NDK (r25c или новее)
- Убедитесь, что все зависимости установлены
- Проверьте логи компиляции

## Дополнительные ресурсы

- [Flutter документация](https://docs.flutter.dev/)
- [llama.cpp репозиторий](https://github.com/ggerganov/llama.cpp)
- [HuggingFace модели](https://huggingface.co/unsloth/Llama-3.2-3B-Instruct-GGUF)

---

*Последнее обновление: Январь 2025*
