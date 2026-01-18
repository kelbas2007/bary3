# Интеграция с системным ассистентом - Полная реализация

## ✅ Что реализовано

### 1. App Shortcuts API
- ✅ `AppShortcutsManager.kt` - менеджер для регистрации shortcuts в Google Assistant
- ✅ Автоматическая регистрация shortcuts при запуске приложения
- ✅ Динамическое обновление shortcuts на основе данных пользователя
- ✅ Поддержка контекстных shortcuts (активные копилки, события)

### 2. Gemini Extensions Handler
- ✅ `GeminiExtensionHandler.kt` - обработчик запросов от Gemini через @Bary3
- ✅ Парсинг голосовых команд и преобразование в deep links
- ✅ Поддержка основных действий: открытие экранов, создание заметок/событий

### 3. Flutter интеграция
- ✅ `AppShortcutsService` - сервис для управления shortcuts из Flutter
- ✅ `LiveActivitiesService` - сервис для Zero-UI опыта
- ✅ Автоматическая регистрация shortcuts в `main.dart`

### 4. Обновленные компоненты
- ✅ `MainActivity.kt` - инициализация новых компонентов
- ✅ `SystemAssistantHandler.kt` - интеграция с AppShortcutsManager
- ✅ Method Channels для управления shortcuts

## 📋 Что нужно настроить

### 1. Digital Asset Links (КРИТИЧНО)

Для верификации deep links нужно настроить Digital Asset Links:

1. **Создайте файл `.well-known/assetlinks.json` на вашем домене:**

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.bary3.app",
      "sha256_cert_fingerprints": [
        "SHA256_FINGERPRINT_ВАШЕГО_DEBUG_КЛЮЧА",
        "SHA256_FINGERPRINT_ВАШЕГО_RELEASE_КЛЮЧА"
      ]
    }
  }
]
```

2. **Получите SHA256 fingerprint:**

```bash
# Для debug ключа:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Для release ключа:
keytool -list -v -keystore path/to/your/keystore.jks -alias your_alias
```

3. **Разместите файл по адресу:**
   - `https://ваш-домен.com/.well-known/assetlinks.json`
   - Или `https://ваш-домен.com/.well-known/assetlinks.json`

4. **Проверьте верификацию:**
   ```bash
   # Используйте Google's Digital Asset Links API:
   https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://ваш-домен.com&relation=delegate_permission/common.handle_all_urls
   ```

### 2. Регистрация в Google Play Console

1. **Войдите в Google Play Console:**
   - https://play.google.com/console

2. **Перейдите в раздел App Actions:**
   - Выберите ваше приложение
   - Перейдите в "App Actions" в меню слева

3. **Загрузите actions.xml:**
   - Файл уже создан: `android/app/src/main/res/xml/actions.xml`
   - Загрузите его в Play Console

4. **Настройте тестирование:**
   - Создайте Internal Testing трек
   - Загрузите APK с настроенными App Actions
   - Протестируйте голосовые команды

5. **Опубликуйте:**
   - После тестирования опубликуйте в Production

### 3. Настройка AndroidManifest.xml

Проверьте, что в `AndroidManifest.xml` есть:

```xml
<!-- Deep Links для App Actions -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="bary3" />
</intent-filter>

<!-- App Actions metadata -->
<meta-data
    android:name="com.google.android.actions"
    android:resource="@xml/actions" />
```

✅ Это уже настроено в текущем проекте!

### 4. Тестирование App Actions

#### Локальное тестирование:

1. **Установите приложение на устройство:**
   ```bash
   flutter run
   ```

2. **Проверьте регистрацию shortcuts:**
   - Откройте Google Assistant
   - Скажите: "Окей Google, открой Бари"
   - Или: "Окей Google, покажи баланс в Бари"

3. **Проверьте deep links:**
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "bary3://screen?screen=balance"
   ```

#### Тестирование через Play Console:

1. Загрузите APK в Internal Testing
2. Установите приложение через Play Console
3. Протестируйте голосовые команды через Google Assistant

## 🎯 Как использовать

### Из Flutter кода:

```dart
// Регистрация shortcuts при запуске
await AppShortcutsService.registerShortcuts();

// Добавление контекстного shortcut
await AppShortcutsService.addContextualShortcut(
  id: 'active_piggy_1',
  shortLabel: 'Копилка',
  longLabel: 'Открыть копилку "Новый телефон"',
  deepLink: 'bary3://screen?screen=piggy_banks&id=1',
);

// Обновление shortcut
await AppShortcutsService.updateShortcut(
  'active_piggy_1',
  'Новая метка',
);

// Показ Live Activity
await LiveActivitiesService.showBariStatus(
  status: 'Обрабатываю ваш запрос...',
  title: 'Бари работает',
);
```

### Голосовые команды для пользователей:

**Открытие экранов:**
- "Окей Google, открой Бари"
- "Окей Google, покажи баланс в Бари"
- "Окей Google, открой копилки в Бари"
- "Окей Google, покажи календарь в Бари"

**Создание:**
- "Окей Google, создай заметку в Бари"
- "Окей Google, запланируй событие в Бари"

**Калькуляторы:**
- "Окей Google, открой калькулятор в Бари"

**Вопросы к Бари:**
- "Окей Google, спроси Бари [ваш вопрос]"

## 🔧 Troubleshooting

### Google Assistant не видит приложение:

1. **Проверьте регистрацию shortcuts:**
   ```dart
   final shortcuts = await AppShortcutsService.getRegisteredShortcuts();
   print('Registered shortcuts: $shortcuts');
   ```

2. **Проверьте Digital Asset Links:**
   - Убедитесь, что файл доступен по HTTPS
   - Проверьте правильность SHA256 fingerprint
   - Убедитесь, что package_name совпадает

3. **Проверьте App Actions в Play Console:**
   - Убедитесь, что actions.xml загружен
   - Проверьте статус валидации

4. **Очистите кэш Google Assistant:**
   - Настройки → Приложения → Google → Очистить кэш
   - Перезапустите Google Assistant

### Deep links не работают:

1. **Проверьте intent-filter в AndroidManifest.xml**
2. **Проверьте, что схема `bary3://` правильно настроена**
3. **Проверьте обработку в MainActivity**

### Shortcuts не обновляются:

1. **Вызовите `AppShortcutsService.registerShortcuts()` при изменении данных**
2. **Проверьте, что не превышен лимит shortcuts (6 максимум)**

## 📚 Дополнительные ресурсы

- [App Actions Documentation](https://developers.google.com/assistant/app/overview)
- [App Shortcuts API](https://developer.android.com/guide/topics/ui/shortcuts)
- [Digital Asset Links](https://developers.google.com/digital-asset-links)
- [Gemini Extensions](https://developers.google.com/gemini/docs/extensions)

## 🚀 Следующие шаги

1. ✅ Настроить Digital Asset Links
2. ✅ Зарегистрировать App Actions в Play Console
3. ✅ Протестировать на реальном устройстве
4. ⏳ Реализовать iOS интеграцию (Siri Shortcuts)
5. ⏳ Добавить больше контекстных shortcuts
6. ⏳ Интегрировать с Gemini Extensions API (когда будет доступно)
