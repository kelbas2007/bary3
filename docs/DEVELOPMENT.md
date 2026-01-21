# Руководство по разработке

Руководство по разработке функций, UI/UX компонентов и лучших практик.

## Реализованные функции

### 1. Переход на локальный LLM ✅

**Статус:** Полностью реализовано

- Удалены все облачные AI интеграции (OpenAI, Gemini Nano)
- Реализован `LocalLLMProvider` с использованием llama.cpp
- Интеграция в `BariSmart`
- Поддержка всех функций: чат, квизы, анализ трат, саммари для родителей

**Файлы:**
- `lib/bari_smart/providers/local_llm_provider.dart`
- `lib/bari_smart/aca/local_llm/`

### 2. Система уровней ✅

**Статус:** Полностью реализовано

- Начисление XP за финансовые операции
- Повышение уровня с уведомлениями
- Связь с копилками и транзакциями
- `LevelService` для управления уровнями

**Начисление XP:**
- Создание копилки: +15 XP
- Пополнение копилки: +5 XP за каждые 10% прогресса
- Завершение копилки: +50 XP
- Добавление транзакций: +10 XP

**Файлы:**
- `lib/services/level_service.dart`
- `lib/repositories/player_profile_repo.dart`

### 3. Локальные уведомления ✅

**Статус:** Полностью реализовано

- Ежедневные напоминания о расходах (20:00)
- Еженедельные обзоры (воскресенье 18:00)
- Уведомления о повышении уровня
- Настройки в UI
- Локализация на 3 языка

**Файлы:**
- `lib/services/notification_service.dart`
- `lib/services/bari_notification_service.dart`

### 4. Аналитика трат ✅

**Статус:** Полностью реализовано

- Графики расходов и доходов по категориям
- Интеграция в `CalendarForecastScreen`
- Использование `fl_chart` для визуализации
- Оптимизация через `RepaintBoundary`

**Файлы:**
- `lib/widgets/spending_chart_widget.dart`

### 5. UI достижений ✅

**Статус:** Полностью реализовано

- `AchievementsScreen` с анимациями
- Отображение всех достижений
- Уведомления о новых достижениях
- Интеграция с `AchievementsService`

**Файлы:**
- `lib/screens/achievements_screen.dart`

### 6. Группировка функций Бари ✅

**Статус:** Полностью реализовано

- `BariFeaturesHub` для централизованного управления
- Категоризация функций
- Интеграция в `AppFeaturesProvider`

**Файлы:**
- `lib/bari_smart/bari_features_hub.dart`

## UI/UX компоненты

### Material 3 Design System

**Реализовано:**
- Динамические цвета через `ColorScheme.fromSeed()`
- `NavigationBar` для мобильных устройств
- `NavigationRail` для планшетов (адаптивная навигация)
- Темы для всех Material 3 компонентов

**Файлы:**
- `lib/theme/aurora_theme.dart`
- `lib/screens/main_screen.dart`

### Анимации

**Реализовано:**
- Hero анимации для транзакций и копилок
- Shared Axis Transitions для Material 3 навигации
- AnimatedListView с поддержкой добавления/удаления
- Haptic feedback для всех интерактивных элементов

**Файлы:**
- `lib/utils/shared_axis_transitions.dart`
- `lib/utils/haptic_feedback_util.dart`
- `lib/widgets/animated_list_view.dart`

### Оптимизация производительности

**Реализовано:**
- RepaintBoundary для оптимизации перерисовки
- Performance Utils с мемоизацией
- Performance Monitor для отслеживания FPS
- Кэширование вычислений
- Lazy loading через ListView.builder

**Файлы:**
- `lib/utils/performance_utils.dart`
- `lib/services/performance_monitor.dart`

### Жесты и взаимодействия

**Реализовано:**
- SwipeableListItem для swipe actions
- DraggableListItem для drag & drop переупорядочивания
- Подтверждение действий при swipe
- Визуальная обратная связь

**Файлы:**
- `lib/widgets/swipeable_list_item.dart`
- `lib/widgets/draggable_list_item.dart`

### Улучшение UX

**Реализовано:**
- Skeleton screens с Shimmer эффектами
- Empty states с действиями
- PaginatedListView для больших списков
- Pull to refresh
- Адаптивная навигация (мобильные/планшеты)

**Файлы:**
- `lib/widgets/skeleton_loader.dart`
- `lib/widgets/empty_state_widget.dart`
- `lib/widgets/paginated_list_view.dart`

### Доступность

**Реализовано:**
- AccessibilityWrapper для Semantics
- ScalableText для масштабирования шрифта
- Semantics для Screen Reader
- Правильные labels и hints
- Live regions для динамического контента

**Файлы:**
- `lib/widgets/accessibility_wrapper.dart`

## Паттерны разработки

### Repository Pattern

```dart
class PlayerProfileRepository {
  Future<PlayerProfile> getProfile() async { ... }
  Future<void> updateProfile(PlayerProfile profile) async { ... }
}
```

### Service Layer

```dart
class LevelService {
  static Future<bool> checkLevelUp(
    PlayerProfile oldProfile,
    PlayerProfile newProfile,
  ) async { ... }
}
```

### Provider Pattern (Riverpod)

```dart
final playerProfileProvider = StateNotifierProvider<...>(...);
```

## Лучшие практики

### 1. Локализация

Всегда используйте локализацию:
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.someKey)
```

### 2. Обработка ошибок

```dart
try {
  // код
} catch (e) {
  if (kDebugMode) {
    debugPrint('Error: $e');
  }
  // обработка ошибки
}
```

### 3. Оптимизация

- Используйте `RepaintBoundary` для статичных виджетов
- Используйте `const` конструкторы где возможно
- Используйте `ListView.builder` для больших списков

### 4. Тестирование

- Пишите unit-тесты для бизнес-логики
- Пишите widget-тесты для UI компонентов
- Используйте `flutter test` для запуска тестов

## Запланированные улучшения

1. **Улучшение качества LLM**
   - Тонкая настройка промптов
   - Оптимизация параметров генерации

2. **Новые функции**
   - Расширенная аналитика
   - Дополнительные достижения
   - Улучшенные уведомления

3. **Оптимизация**
   - Кэширование ответов LLM
   - Оптимизация памяти
   - Улучшение производительности

---

*Последнее обновление: Январь 2025*
