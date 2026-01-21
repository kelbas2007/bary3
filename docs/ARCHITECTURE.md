# Архитектура проекта Bary3

Обзор архитектуры приложения, структуры кода и основных компонентов.

## Общая архитектура

Bary3 построен на Flutter с использованием:
- **State Management:** Riverpod
- **Локализация:** Flutter Intl (ARB файлы)
- **AI:** Локальный LLM через llama.cpp (Dart FFI)
- **Хранение данных:** SharedPreferences, локальная БД

## Структура проекта

```
lib/
├── bari_smart/              # AI модуль (AKA)
│   ├── providers/
│   │   └── local_llm_provider.dart
│   ├── aca/
│   │   └── local_llm/
│   │       ├── llama_ffi_binding.dart
│   │       ├── model_loader.dart
│   │       └── model_version_manager.dart
│   ├── bari_smart.dart      # Главный класс AI
│   └── bari_features_hub.dart
├── models/                  # Модели данных
│   ├── transaction.dart
│   ├── piggy_bank.dart
│   ├── player_profile.dart
│   └── ...
├── screens/                 # Экраны приложения
│   ├── balance_screen.dart
│   ├── piggy_banks_screen.dart
│   ├── calendar_screen.dart
│   └── ...
├── services/                # Бизнес-логика
│   ├── storage_service.dart
│   ├── notification_service.dart
│   ├── level_service.dart
│   └── ...
├── widgets/                 # Переиспользуемые виджеты
│   ├── transaction_item.dart
│   ├── spending_chart_widget.dart
│   └── ...
├── theme/                   # Тема приложения
│   └── aurora_theme.dart
└── l10n/                    # Локализация
    ├── app_ru.arb
    ├── app_en.arb
    └── app_de.arb
```

## Основные компоненты

### 1. AI модуль (AKA)

**Локальный LLM провайдер:**
- `LocalLLMProvider` - основной провайдер для работы с LLM
- Использует llama.cpp через Dart FFI
- Поддерживает: чат, квизы, анализ трат, саммари для родителей

**Архитектура:**
```
LocalLLMProvider
  ├── ModelLoader (загрузка моделей)
  ├── LlamaFFIBinding (FFI binding)
  └── ModelVersionManager (версионирование)
```

### 2. State Management (Riverpod)

**Основные провайдеры:**
- `playerProfileProvider` - профиль игрока
- `transactionsProvider` - транзакции
- `piggyBanksProvider` - копилки
- `plannedEventsProvider` - запланированные события

### 3. Сервисы

**StorageService:**
- Управление данными через SharedPreferences
- Кэширование настроек
- Управление версиями данных

**NotificationService:**
- Локальные уведомления
- Планирование напоминаний
- Локализованные сообщения

**LevelService:**
- Управление уровнями игрока
- Начисление XP
- Уведомления о повышении уровня

### 4. UI компоненты

**Material 3 Design:**
- Динамические цвета
- NavigationBar / NavigationRail
- Адаптивная навигация

**Анимации:**
- Hero анимации
- Shared Axis Transitions
- AnimatedListView

**Оптимизация:**
- RepaintBoundary
- Lazy loading
- Кэширование

## Потоки данных

### Добавление транзакции

```
User Input → BalanceScreen
  → TransactionService
  → StorageService (сохранение)
  → transactionsProvider (обновление UI)
  → LevelService (начисление XP)
  → NotificationService (если нужно)
```

### Генерация ответа AI

```
User Message → BariChatScreen
  → BariSmart
  → LocalLLMProvider
  → LlamaFFIBinding (FFI)
  → llama.cpp (нативная библиотека)
  → Response → UI
```

## Модули

### Balance Module
- Отображение баланса
- Список транзакций
- Фильтры (день/неделя/месяц)
- Добавление доходов/расходов

### Piggy Banks Module
- Создание копилок
- Пополнение/снятие
- Автопополнение
- Прогресс к цели

### Calendar Module
- Календарь событий
- Планирование
- Уведомления
- Связь с транзакциями

### Lessons Module
- Список уроков
- Прохождение уроков
- Квизы
- Начисление XP

### AI Module (Bari)
- Чат с ассистентом
- Анализ трат
- Генерация квизов
- Саммари для родителей

## Паттерны проектирования

### Repository Pattern
- `PlayerProfileRepository`
- `PiggyBanksRepository`
- `TransactionsRepository`

### Service Layer
- Бизнес-логика в сервисах
- Разделение ответственности
- Тестируемость

### Provider Pattern (Riverpod)
- Управление состоянием
- Dependency Injection
- Реактивность

## Безопасность

- Локальное хранение данных
- Нет отправки данных на сервер
- Шифрование чувствительных данных (PIN)
- Проверка прав доступа

## Производительность

- Lazy loading списков
- Кэширование вычислений
- RepaintBoundary для оптимизации
- Мемоизация через Riverpod

## Масштабируемость

- Модульная архитектура
- Версионирование моделей
- Поддержка нескольких языков
- Расширяемая система функций

## Зависимости

**Основные:**
- `flutter_riverpod` - state management
- `shared_preferences` - локальное хранение
- `flutter_local_notifications` - уведомления
- `fl_chart` - графики
- `ffi` - для работы с нативными библиотеками

**Нативные:**
- llama.cpp (скомпилированные библиотеки)
- Android NDK / iOS frameworks

---

*Последнее обновление: Январь 2025*
