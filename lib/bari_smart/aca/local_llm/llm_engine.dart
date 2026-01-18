/// Абстракция локального LLM движка
/// 
/// Предоставляет единый интерфейс для работы с локальным LLM
/// независимо от конкретной реализации (llama.cpp, TFLite и т.д.)
abstract class LLMEngine {
  /// Инициализировать движок с моделью
  /// 
  /// [modelPath] - путь к файлу модели
  /// [systemPrompt] - системный промпт для настройки поведения
  /// Возвращает true если инициализация успешна
  Future<bool> initialize(String modelPath, String systemPrompt);

  /// Генерировать ответ на основе промпта
  /// 
  /// [prompt] - пользовательский промпт
  /// [maxTokens] - максимальное количество токенов в ответе
  /// [temperature] - температура генерации (0.0-1.0)
  /// Возвращает сгенерированный текст или null при ошибке
  Future<String?> generate(
    String prompt, {
    int maxTokens = 256,
    double temperature = 0.7,
  });

  /// Переранжировать список чанков по релевантности к запросу
  /// 
  /// [query] - пользовательский запрос
  /// [chunks] - список чанков для переранжирования
  /// [topK] - количество лучших чанков для возврата
  /// Возвращает отсортированный список чанков
  Future<List<RerankedChunk>> rerank(
    String query,
    List<String> chunks, {
    int topK = 5,
  });

  /// Проверить, инициализирован ли движок
  bool get isInitialized;

  /// Освободить ресурсы
  Future<void> dispose();
}

/// Результат переранжирования чанка
class RerankedChunk {
  final String text;
  final double score; // релевантность (0.0-1.0)
  final int originalIndex;

  const RerankedChunk({
    required this.text,
    required this.score,
    required this.originalIndex,
  });
}
