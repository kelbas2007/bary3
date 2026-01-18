# Локальный LLM модуль (Фаза 1.1)

## Описание

Модуль для работы с локальным LLM через llama.cpp FFI binding. Поддерживает:
- Загрузку моделей с версионированием (model_v1.bin, model_v2.bin)
- Семантическое ранжирование (reranking)
- Шаблонизированную генерацию ответов
- Полностью офлайн работу

## Структура

- `llm_engine.dart` - абстракция LLM движка
- `llama_ffi_binding.dart` - FFI binding для llama.cpp
- `model_loader.dart` - загрузчик моделей с поддержкой версий
- `model_version_manager.dart` - менеджер версий моделей
- `prompt_builder.dart` - построитель промптов для шаблонов

## Использование

```dart
// 1. Загрузить модель
final loader = ModelLoader();
final modelPath = await loader.loadModel(akaVersion: 1);

// 2. Инициализировать движок
final engine = LlamaFFIBinding();
await engine.initialize(modelPath, systemPrompt);

// 3. Генерировать ответ
final response = await engine.generate('Привет, Бари!');

// 4. Переранжировать чанки
final reranked = await engine.rerank(query, chunks, topK: 5);
```

## Требования

- llama.cpp библиотеки для Android/iOS (требуется компиляция)
- Модель Llama 3.2 3B Q4_K_M (~200MB) в `assets/aka/models/model_v1.bin`

## Статус

✅ Базовая структура создана
⏳ Требуется реализация FFI binding для llama.cpp
⏳ Требуется компиляция нативных библиотек
