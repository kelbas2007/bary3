# Быстрый старт

Руководство для быстрого начала работы с проектом Bary3.

## Требования

- Flutter SDK 3.x или выше
- Dart 3.x или выше
- Android Studio / VS Code
- Git

## Установка

### 1. Клонирование репозитория

```bash
git clone <repository-url>
cd bary3
```

### 2. Установка зависимостей

```bash
flutter pub get
```

### 3. Генерация локализации

```bash
flutter gen-l10n
```

### 4. Запуск приложения

```bash
# Android
flutter run

# iOS (требуется macOS)
flutter run -d ios

# Выбор устройства
flutter devices
flutter run -d <device-id>
```

## Основные команды

### Разработка

```bash
# Запуск в режиме разработки
flutter run

# Запуск с hot reload
flutter run --hot

# Анализ кода
flutter analyze

# Форматирование кода
dart format lib/
```

### Тестирование

```bash
# Запуск всех тестов
flutter test

# Запуск конкретного теста
flutter test test/path/to/test.dart

# Запуск с покрытием
flutter test --coverage
```

### Сборка

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS (требуется macOS)
flutter build ios
```

## Настройка модели LLM

Для работы AI-ассистента Бари требуется локальная модель:

```powershell
# Windows
.\scripts\download_model.ps1

# Linux/macOS
bash scripts/download_model.sh
```

Подробнее: [SETUP.md](./SETUP.md#модель-llm)

## Структура проекта

```
lib/
├── bari_smart/        # AI модуль (AKA)
├── models/            # Модели данных
├── screens/           # Экраны приложения
├── services/          # Бизнес-логика
├── widgets/           # Переиспользуемые виджеты
├── theme/             # Тема приложения
└── l10n/              # Локализация
```

## Следующие шаги

1. **Изучить архитектуру:** [ARCHITECTURE.md](./ARCHITECTURE.md)
2. **Настроить окружение:** [SETUP.md](./SETUP.md)
3. **Начать разработку:** [DEVELOPMENT.md](./DEVELOPMENT.md)

## Полезные ссылки

- [Flutter документация](https://docs.flutter.dev/)
- [Dart документация](https://dart.dev/guides)
- [Riverpod документация](https://riverpod.dev/)

---

*Последнее обновление: Январь 2025*
