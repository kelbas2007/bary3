# Компиляция llama.cpp через GitHub Actions

## Быстрый старт

### Шаг 1: Запуск workflow

1. **Откройте GitHub репозиторий** в браузере
2. Перейдите в раздел **"Actions"**
3. Найдите workflow **"Build llama.cpp for AKA"**
4. Нажмите **"Run workflow"** → **"Run workflow"**

### Шаг 2: Ожидание завершения

- **Android сборка:** ~15-20 минут
- **iOS сборка:** ~15-20 минут

Вы можете следить за прогрессом в реальном времени.

### Шаг 3: Скачивание артефактов

После завершения:

1. Нажмите на завершенный workflow run
2. Прокрутите вниз до секции **"Artifacts"**
3. Скачайте:
   - `llama-android-libs` - для Android
   - `llama-ios-framework` - для iOS

### Шаг 4: Размещение библиотек

#### Для Android:

1. Распакуйте `llama-android-libs.zip`
2. Скопируйте содержимое в:
   ```
   android/app/src/main/jniLibs/
   ```
3. Структура должна быть:
   ```
   android/app/src/main/jniLibs/
   ├── arm64-v8a/
   │   └── libllama.so
   └── x86_64/
       └── libllama.so
   ```

#### Для iOS:

1. Распакуйте `llama-ios-framework.zip`
2. Скопируйте `llama.framework` в:
   ```
   ios/Frameworks/
   ```

### Шаг 5: Проверка

```powershell
# Android
Test-Path "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
(Get-Item "android\app\src\main\jniLibs\arm64-v8a\libllama.so").Length / 1MB

# iOS
Test-Path "ios\Frameworks\llama.framework\llama"
```

## Автоматический запуск

Workflow также запускается автоматически при:
- Push в `main` или `master` ветку
- Изменении файлов `scripts/build_llama_*.sh`
- Изменении `.github/workflows/build_llama.yml`

## Устранение проблем

### Workflow не запускается

- Убедитесь, что файл `.github/workflows/build_llama.yml` существует
- Проверьте, что у вас есть права на запуск workflows

### Сборка не удалась

- Проверьте логи в разделе "Actions"
- Убедитесь, что скрипты `build_llama_*.sh` имеют права на выполнение
- Проверьте, что NDK версия корректна

### Артефакты не найдены

- Убедитесь, что сборка завершилась успешно
- Проверьте, что библиотеки были созданы в правильных директориях
- Артефакты хранятся 30 дней

## Альтернативные методы

Если GitHub Actions недоступен:

1. **WSL** (после установки дистрибутива):
   ```powershell
   .\scripts\compile_via_wsl.ps1
   ```

2. **Локальная Linux машина**:
   ```bash
   bash scripts/build_llama_android.sh
   ```

3. **Docker** (если доступен):
   ```bash
   docker run -it --rm -v $(pwd):/workspace android-ndk-builder bash scripts/build_llama_android.sh
   ```

## Примечания

- Артефакты GitHub Actions хранятся 30 дней
- Рекомендуется скачать и сохранить библиотеки локально
- После скачивания библиотеки можно добавить в git (если размер приемлем)
