# Заметки по реализации FFI binding для llama.cpp

## Текущий статус

✅ Базовая структура создана
✅ Заглушки для разработки работают
⏳ Требуется компиляция llama.cpp библиотек
⏳ Требуется полная реализация FFI функций

## Следующие шаги после компиляции библиотеки

### 1. Проверка экспортируемых символов

После компиляции проверьте, какие функции экспортирует библиотека:

```bash
# Android
nm -D android/app/src/main/jniLibs/arm64-v8a/libllama.so | grep llama

# iOS
nm ios/Frameworks/llama.framework/llama | grep llama
```

### 2. Определение FFI типов

На основе реальных сигнатур функций из `llama.h` определите правильные FFI типы.

Пример реальных сигнатур из llama.cpp:

```c
// Из llama.h
struct llama_model_params llama_model_default_params(void);
struct llama_model * llama_load_model_from_file(
    const char * path_model,
    struct llama_model_params params);

struct llama_context_params llama_context_default_params(void);
struct llama_context * llama_new_context_with_model(
    struct llama_model * model,
    struct llama_context_params params);

int llama_tokenize(
    struct llama_context * ctx,
    const char * text,
    int text_len,
    llama_token * tokens,
    int n_max_tokens,
    bool add_bos,
    bool special);

int llama_decode(
    struct llama_context * ctx,
    struct llama_batch batch);

llama_token llama_sample_token(
    struct llama_context * ctx,
    struct llama_sampler * sampler);

float * llama_get_logits(struct llama_context * ctx);

void llama_free_model(struct llama_model * model);
void llama_free_context(struct llama_context * ctx);
```

### 3. Реализация функций

После определения типов раскомментируйте и реализуйте функции в `llama_ffi_binding.dart`.

### 4. Тестирование

Протестируйте на реальном устройстве:
- Загрузка модели
- Генерация текста
- Переранжирование чанков

## Альтернативный подход: использование готового пакета

Если компиляция llama.cpp вызывает сложности, можно использовать готовый пакет:

```yaml
dependencies:
  llama_cpp_dart: ^0.1.0  # Если доступен на pub.dev
```

Однако для полного контроля и оптимизации рекомендуется собственная компиляция.

## Проблемы и решения

### Проблема: Библиотека не загружается

**Решение:**
- Проверьте путь к библиотеке
- Убедитесь, что библиотека скомпилирована как shared library
- Проверьте архитектуру устройства

### Проблема: Ошибки при вызове функций

**Решение:**
- Проверьте сигнатуры функций через `nm` или `objdump`
- Убедитесь, что FFI типы соответствуют реальным сигнатурам
- Используйте `calloc`/`malloc`/`free` для управления памятью

### Проблема: Низкая производительность

**Решение:**
- Используйте Metal для iOS
- Оптимизируйте параметры контекста (n_ctx, n_batch)
- Используйте квантованные модели (Q4_K_M)
