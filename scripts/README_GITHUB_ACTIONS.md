# Запуск GitHub Actions Workflow

## Автоматический запуск

### Способ 1: GitHub CLI (рекомендуется)

1. **Установите GitHub CLI:**
   ```powershell
   winget install --id GitHub.cli
   ```

2. **Авторизуйтесь:**
   ```powershell
   gh auth login
   ```

3. **Запустите workflow:**
   ```powershell
   .\scripts\trigger_github_actions.ps1
   ```

### Способ 2: GitHub API

1. **Создайте Personal Access Token:**
   - Перейдите: https://github.com/settings/tokens
   - Нажмите "Generate new token (classic)"
   - Выберите scope: `workflow`
   - Скопируйте токен

2. **Установите токен:**
   ```powershell
   $env:GITHUB_TOKEN = "your_token_here"
   ```

3. **Запустите workflow:**
   ```powershell
   .\scripts\trigger_github_actions_api.ps1 -RepoOwner <owner> -RepoName <repo>
   ```

### Способ 3: Ручной запуск (самый простой)

1. Откройте GitHub репозиторий в браузере
2. Перейдите в раздел **"Actions"**
3. Найдите workflow **"Build llama.cpp for AKA"**
4. Нажмите **"Run workflow"** → **"Run workflow"**

## После запуска

1. **Следите за прогрессом:**
   - В разделе Actions GitHub
   - Или через: `gh run watch`

2. **Дождитесь завершения:**
   - Android: ~15-20 минут
   - iOS: ~15-20 минут

3. **Скачайте артефакты:**
   - `llama-android-libs` - для Android
   - `llama-ios-framework` - для iOS

4. **Разместите библиотеки:**
   - Android: `android/app/src/main/jniLibs/arm64-v8a/libllama.so`
   - iOS: `ios/Frameworks/llama.framework/`

## Примечания

- Workflow также запускается автоматически при push в main/master
- Артефакты хранятся 30 дней
- Рекомендуется скачать и сохранить библиотеки локально
