# Автоматизированная настройка llama.cpp для АКА

## Быстрый старт (Windows)

### 1. Быстрая настройка структуры

```powershell
.\scripts\quick_setup.ps1
```

Это создаст все необходимые директории и README файлы.

### 2. Скачивание модели

```powershell
.\scripts\download_model.ps1
```

**Примечание:** Модель весит ~2GB, скачивание может занять время.

### 3. Компиляция llama.cpp

#### Вариант A: Использование WSL (рекомендуется)

1. Установите WSL2:
   ```powershell
   wsl --install
   ```

2. В WSL выполните:
   ```bash
   cd /mnt/c/flutter_projects/bary3
   export ANDROID_NDK_HOME=/mnt/c/path/to/android-ndk
   bash scripts/build_llama_android.sh
   ```

#### Вариант B: GitHub Actions (автоматически)

1. Создайте файл `.github/workflows/build_llama.yml`:
   ```yaml
   # Скопируйте содержимое из scripts/setup_llama_github_actions.yml
   ```

2. Запустите workflow вручную через GitHub Actions UI

3. Скачайте артефакты (библиотеки и модель)

4. Разместите в проекте:
   - `android/app/src/main/jniLibs/` - библиотеки
   - `assets/aka/models/model_v1.bin` - модель

#### Вариант C: Использование готовых библиотек

Если доступны pre-compiled библиотеки:
1. Скачайте с GitHub releases llama.cpp
2. Извлеките `libllama.so` для нужной архитектуры
3. Разместите в `android/app/src/main/jniLibs/<arch>/`

### 4. Обновление FFI типов

После компиляции библиотеки:

```powershell
# Генерировать шаблон типов
.\scripts\update_ffi_types.ps1 -GenerateTemplate

# Проверить сигнатуры функций
.\scripts\check_ffi_signatures.ps1 -LibraryPath "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
```

Затем обновите типы в `llama_ffi_binding.dart` согласно реальным сигнатурам.

## Альтернативный подход: Использование готового пакета

Если компиляция вызывает сложности, можно использовать готовый пакет (если доступен):

```yaml
dependencies:
  llama_cpp_dart: ^0.1.0  # Проверьте доступность на pub.dev
```

Однако для полного контроля рекомендуется собственная компиляция.

## Режим разработки (Stub Mode)

**Хорошая новость:** FFI binding работает в режиме заглушки!

Это означает, что вы можете:
- ✅ Разрабатывать и тестировать интеграцию
- ✅ Работать над остальными компонентами АКА
- ✅ Компилировать и запускать приложение

Реальная библиотека нужна только для финального тестирования и production.

## Проверка статуса

```powershell
# Проверить структуру
Get-ChildItem -Recurse android\app\src\main\jniLibs\
Get-ChildItem -Recurse assets\aka\models\

# Проверить размер модели (если скачана)
(Get-Item assets\aka\models\model_v1.bin).Length / 1GB
```

## Устранение проблем

### Модель не скачивается

- Проверьте интернет-соединение
- Попробуйте скачать вручную с Hugging Face
- Используйте браузер для скачивания, затем скопируйте файл

### Компиляция не работает

- Убедитесь, что установлен Android NDK
- Проверьте, что CMake в PATH
- Используйте GitHub Actions как альтернативу

### FFI типы не совпадают

- Проверьте версию llama.cpp (API может отличаться)
- Используйте `nm` или `objdump` для проверки символов
- Сверьтесь с `llama.h` header файлом

## Следующие шаги

После настройки:
1. Протестируйте загрузку модели
2. Протестируйте генерацию текста
3. Интегрируйте в `BariSmart`
4. Переходите к Фазе 1.2 (Бинарный векторный индекс)
