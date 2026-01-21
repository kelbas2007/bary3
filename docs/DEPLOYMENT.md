# Руководство по развертыванию

Руководство по подготовке к релизу, настройке подписи и публикации приложения.

## TODO перед релизом

### 🔴 КРИТИЧНО - Исправить перед релизом

#### 1. Application ID (Package Name)

**Файл:** `android/app/build.gradle.kts:24-25`

**Проблема:** Используется стандартный `com.example.bary3`, который нельзя использовать в продакшене.

**Решение:**
```kotlin
applicationId = "com.yourcompany.bary3"  // Замените на свой уникальный ID
```

⚠️ **ВАЖНО:** После первой публикации в Play Store изменить нельзя!

#### 2. Release Signing Config

**Файл:** `android/app/build.gradle.kts:36-38`

**Проблема:** Release-сборка подписывается debug-ключом.

**Решение:**

1. **Создать release-ключ:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Создать `android/key.properties`:**
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=/path/to/upload-keystore.jks
   ```

3. **Настроить signing config в `build.gradle.kts`:**
   ```kotlin
   signingConfigs {
       create("release") {
           val keystorePropertiesFile = rootProject.file("key.properties")
           val keystoreProperties = Properties()
           keystoreProperties.load(FileInputStream(keystorePropertiesFile))
           
           keyAlias = keystoreProperties["keyAlias"] as String
           keyPassword = keystoreProperties["keyPassword"] as String
           storeFile = file(keystoreProperties["storeFile"] as String)
           storePassword = keystoreProperties["storePassword"] as String
       }
   }
   
   buildTypes {
       getByName("release") {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

### 🟡 РЕКОМЕНДУЕТСЯ

#### 3. App Label

**Файл:** `android/app/src/main/AndroidManifest.xml:5`

**Текущее:**
```xml
android:label="bary3"
```

**Рекомендуется:**
```xml
android:label="Bary3"
```
или
```xml
android:label="Bary3 - Финансы для детей"
```

## Подготовка к релизу

### 1. Обновить версию

**Файл:** `pubspec.yaml`

```yaml
version: 1.0.0+1  # version+build_number
```

### 2. Проверить зависимости

```bash
flutter pub outdated
flutter pub upgrade
```

### 3. Запустить тесты

```bash
flutter test
flutter test integration_test/
```

### 4. Проверить анализ кода

```bash
flutter analyze
```

### 5. Оптимизировать размер

```bash
flutter build apk --split-per-abi  # Для Android
```

## Сборка релизной версии

### Android

#### APK

```bash
flutter build apk --release
```

#### App Bundle (для Play Store)

```bash
flutter build appbundle --release
```

Файл будет в: `build/app/outputs/bundle/release/app-release.aab`

### iOS (только macOS)

```bash
flutter build ios --release
```

Затем откройте Xcode и создайте архив для App Store.

## Публикация

### Google Play Store

1. **Создайте аккаунт разработчика**
2. **Создайте приложение в Play Console**
3. **Загрузите App Bundle:**
   - Перейдите в "Production" → "Create new release"
   - Загрузите `app-release.aab`
   - Заполните описание релиза
   - Отправьте на проверку

### Apple App Store

1. **Создайте аккаунт разработчика**
2. **Создайте приложение в App Store Connect**
3. **Загрузите через Xcode:**
   - Откройте проект в Xcode
   - Product → Archive
   - Distribute App → App Store Connect
   - Следуйте инструкциям

## Чеклист перед публикацией

- [ ] Application ID изменен
- [ ] Release signing настроен
- [ ] App Label обновлен
- [ ] Версия обновлена
- [ ] Все тесты проходят
- [ ] Анализ кода без ошибок
- [ ] Локализация проверена
- [ ] Модель LLM включена в assets
- [ ] Библиотеки llama.cpp включены
- [ ] Скриншоты подготовлены
- [ ] Описание приложения готово
- [ ] Политика конфиденциальности готова

## После публикации

### Мониторинг

- Отслеживайте отзывы пользователей
- Мониторьте краши через Firebase Crashlytics
- Анализируйте метрики использования

### Обновления

1. Обновите версию в `pubspec.yaml`
2. Обновите changelog
3. Соберите новую версию
4. Загрузите обновление в магазины

---

*Последнее обновление: Январь 2025*
