# Быстрый старт: Запуск GitHub Actions

## Текущий статус

✅ **GitHub CLI установлен**  
✅ **Git репозиторий инициализирован**  
⏳ **Требуется авторизация GitHub CLI**

## Шаги для запуска workflow

### Шаг 1: Авторизация GitHub CLI

1. **Откройте PowerShell** в директории проекта
2. **Запустите:**
   ```powershell
   gh auth login
   ```
3. **Следуйте инструкциям:**
   - Выберите "GitHub.com"
   - Выберите "HTTPS"
   - Нажмите "Y" для авторизации Git
   - Скопируйте код из терминала
   - Откройте ссылку в браузере
   - Введите код на странице GitHub
   - Нажмите "Authorize"

### Шаг 2: Создание GitHub репозитория

Если репозиторий еще не создан:

```powershell
# Добавьте все файлы
git add .

# Создайте коммит
git commit -m "Initial commit with AKA setup"

# Создайте GitHub репозиторий и запушьте код
gh repo create bary3 --public --source=. --remote=origin --push
```

### Шаг 3: Запуск workflow

**Автоматически:**
```powershell
.\scripts\trigger_github_actions.ps1
```

**Или вручную:**
1. Откройте https://github.com/your-username/bary3/actions
2. Найдите "Build llama.cpp for AKA"
3. Нажмите "Run workflow" → "Run workflow"

### Шаг 4: Ожидание и скачивание

1. **Дождитесь завершения** (~15-20 минут)
2. **Скачайте артефакты:**
   - `llama-android-libs` - для Android
   - `llama-ios-framework` - для iOS
3. **Разместите библиотеки:**
   - Android: `android/app/src/main/jniLibs/arm64-v8a/libllama.so`
   - iOS: `ios/Frameworks/llama.framework/`

## Альтернатива: Ручной запуск

Если автоматизация не работает:

1. **Создайте GitHub репозиторий вручную:**
   - Перейдите на https://github.com/new
   - Создайте репозиторий "bary3"
   - НЕ инициализируйте с README

2. **Запушьте код:**
   ```powershell
   git remote add origin https://github.com/your-username/bary3.git
   git branch -M main
   git push -u origin main
   ```

3. **Запустите workflow:**
   - Откройте Actions в GitHub
   - Найдите "Build llama.cpp for AKA"
   - Нажмите "Run workflow"

## Проверка результата

После скачивания артефактов:

```powershell
# Android
Test-Path "android\app\src\main\jniLibs\arm64-v8a\libllama.so"
(Get-Item "android\app\src\main\jniLibs\arm64-v8a\libllama.so").Length / 1MB

# iOS
Test-Path "ios\Frameworks\llama.framework\llama"
```

## Примечания

- Workflow также запускается автоматически при push в main
- Артефакты хранятся 30 дней
- Рекомендуется скачать и сохранить библиотеки локально
