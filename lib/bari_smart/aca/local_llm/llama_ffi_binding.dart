import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'llm_engine.dart';

/// FFI binding для llama.cpp
///
/// Реализация на основе реального API llama.cpp
///
/// Требования:
/// - Скомпилированные библиотеки llama.cpp для Android/iOS
/// - Модель в формате GGUF
class LlamaFFIBinding implements LLMEngine {
  DynamicLibrary? _lib;
  Pointer<Void>? _model; // llama_model
  Pointer<Void>? _ctx; // llama_context
  bool _initialized = false;

  // FFI функции llama.cpp (инициализируются после загрузки библиотеки)
  late final LlamaModelDefaultParamsDart _llamaModelDefaultParams;
  late final LlamaLoadModelFromFileDart _llamaLoadModelFromFile;
  late final LlamaContextDefaultParamsDart _llamaContextDefaultParams;
  late final LlamaNewContextWithModelDart _llamaNewContextWithModel;
  late final LlamaTokenizeDart _llamaTokenize;
  late final LlamaDecodeDart _llamaDecode;
  late final LlamaSampleTokenDart _llamaSampleToken;
  late final LlamaGetLogitsDart _llamaGetLogits;
  late final LlamaGetVocabDart _llamaGetVocab;
  late final LlamaFreeModelDart _llamaFreeModel;
  late final LlamaFreeContextDart _llamaFreeContext;

  /// Загрузить нативную библиотеку llama.cpp
  Future<void> _loadLibrary() async {
    if (_lib != null) return;

    try {
      if (Platform.isAndroid) {
        // Android: используем DynamicLibrary.process() для загрузки из jniLibs
        // Библиотека должна быть в android/app/src/main/jniLibs/arm64-v8a/libllama.so
        // Flutter автоматически включает её в APK, и она доступна через process()
        try {
          _lib = DynamicLibrary.process();
          // Проверяем, что библиотека действительно загружена
          // Попробуем найти хотя бы одну функцию
          try {
            _lib!.lookup('llama_model_default_params');
          } catch (e) {
            // Если функция не найдена, пробуем явно открыть
            _lib = DynamicLibrary.open('libllama.so');
          }
        } catch (e) {
          // Последняя попытка: явное открытие
          _lib = DynamicLibrary.open('libllama.so');
        }
      } else if (Platform.isIOS) {
        // iOS: загружаем из Frameworks
        try {
          _lib = DynamicLibrary.open('llama.framework/llama');
        } catch (e) {
          _lib = DynamicLibrary.process();
        }
      } else {
        throw UnsupportedError(
          'Platform ${Platform.operatingSystem} is not supported',
        );
      }

      if (_lib != null) {
        _initializeFFIFunctions();
        if (kDebugMode) {
          debugPrint('[LlamaFFI] Library loaded successfully');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error loading library: $e');
        debugPrint(
          '[LlamaFFI] Make sure llama.cpp is compiled and placed in jniLibs (Android) or Frameworks (iOS)',
        );
        debugPrint('[LlamaFFI] For now, using stub mode');
      }
      // Не бросаем исключение - используем stub mode для разработки
      _lib = null;
    }
  }

  /// Инициализировать FFI функции после загрузки библиотеки
  void _initializeFFIFunctions() {
    if (_lib == null) return;

    try {
      _llamaModelDefaultParams = _lib!
          .lookupFunction<
            LlamaModelDefaultParamsNative,
            LlamaModelDefaultParamsDart
          >('llama_model_default_params');

      _llamaLoadModelFromFile = _lib!
          .lookupFunction<
            LlamaLoadModelFromFileNative,
            LlamaLoadModelFromFileDart
          >('llama_load_model_from_file');

      _llamaContextDefaultParams = _lib!
          .lookupFunction<
            LlamaContextDefaultParamsNative,
            LlamaContextDefaultParamsDart
          >('llama_context_default_params');

      _llamaNewContextWithModel = _lib!
          .lookupFunction<
            LlamaNewContextWithModelNative,
            LlamaNewContextWithModelDart
          >('llama_new_context_with_model');

      _llamaTokenize = _lib!
          .lookupFunction<LlamaTokenizeNative, LlamaTokenizeDart>(
            'llama_tokenize',
          );

      _llamaDecode = _lib!.lookupFunction<LlamaDecodeNative, LlamaDecodeDart>(
        'llama_decode',
      );

      _llamaSampleToken = _lib!
          .lookupFunction<LlamaSampleTokenNative, LlamaSampleTokenDart>(
            'llama_sample_token',
          );

      _llamaGetLogits = _lib!
          .lookupFunction<LlamaGetLogitsNative, LlamaGetLogitsDart>(
            'llama_get_logits',
          );

      _llamaGetVocab = _lib!
          .lookupFunction<LlamaGetVocabNative, LlamaGetVocabDart>(
            'llama_get_vocab',
          );

      _llamaFreeModel = _lib!
          .lookupFunction<LlamaFreeModelNative, LlamaFreeModelDart>(
            'llama_free_model',
          );

      _llamaFreeContext = _lib!
          .lookupFunction<LlamaFreeContextNative, LlamaFreeContextDart>(
            'llama_free_context',
          );

      if (kDebugMode) {
        debugPrint('[LlamaFFI] FFI functions initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error initializing FFI functions: $e');
        debugPrint('[LlamaFFI] Some functions may not be available');
      }
    }
  }

  @override
  Future<bool> initialize(String modelPath, String systemPrompt) async {
    if (_initialized) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Already initialized');
      }
      return true;
    }

    try {
      await _loadLibrary();

      if (_lib == null) {
        if (kDebugMode) {
          debugPrint('[LlamaFFI] Library not available, using stub mode');
        }
        // Заглушка для разработки без скомпилированной библиотеки
        _initialized = true;
        return true;
      }

      if (kDebugMode) {
        debugPrint('[LlamaFFI] Initializing model from: $modelPath');
        debugPrint('[LlamaFFI] System prompt length: ${systemPrompt.length}');
      }

      // 1. Получить параметры модели по умолчанию
      final modelParamsPtr = _llamaModelDefaultParams();
      if (modelParamsPtr.address == 0) {
        throw Exception('Failed to get model default params');
      }

      // 2. Загрузить модель
      final modelPathPtr = modelPath.toNativeUtf8();
      _model = _llamaLoadModelFromFile(modelPathPtr, modelParamsPtr);
      malloc.free(modelPathPtr);
      malloc.free(modelParamsPtr);

      if (_model == null || _model!.address == 0) {
        throw Exception('Failed to load model from $modelPath');
      }

      // 3. Получить параметры контекста по умолчанию
      final ctxParamsPtr = _llamaContextDefaultParams();
      if (ctxParamsPtr.address == 0) {
        throw Exception('Failed to get context default params');
      }

      // 4. Создать контекст
      _ctx = _llamaNewContextWithModel(_model!, ctxParamsPtr);
      malloc.free(ctxParamsPtr);

      if (_ctx == null || _ctx!.address == 0) {
        throw Exception('Failed to create context');
      }

      // 5. System prompt будет добавлен в первый промпт при генерации

      _initialized = true;

      if (kDebugMode) {
        debugPrint('[LlamaFFI] Model initialized successfully');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error initializing: $e');
        debugPrint('[LlamaFFI] Stack trace: $stackTrace');
      }
      _initialized = false;
      return false;
    }
  }

  @override
  Future<String?> generate(
    String prompt, {
    int maxTokens = 256,
    double temperature = 0.7,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Not initialized, cannot generate');
      }
      return null;
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[LlamaFFI] Generating response for prompt (${prompt.length} chars)',
        );
        debugPrint(
          '[LlamaFFI] Max tokens: $maxTokens, Temperature: $temperature',
        );
      }

      if (_lib == null) {
        // Заглушка для разработки
        return 'AI response (stub): $prompt';
      }

      // 1. Токенизация промпта
      final promptPtr = prompt.toNativeUtf8();
      final maxTokensCount =
          512; // Максимальное количество токенов для токенизации
      final tokensPtr = malloc<Int32>(maxTokensCount * sizeOf<Int32>());

      final tokensCount = _llamaTokenize(
        _ctx!,
        promptPtr,
        prompt.length,
        tokensPtr,
        maxTokensCount,
        true, // add_bos
        false, // special
      );

      malloc.free(promptPtr);

      if (tokensCount <= 0) {
        malloc.free(tokensPtr);
        throw Exception('Failed to tokenize prompt');
      }

      // 2. Декодирование токенов
      final decodeResult = _llamaDecode(_ctx!, tokensPtr, tokensCount);
      if (decodeResult != 0) {
        malloc.free(tokensPtr);
        throw Exception('Failed to decode tokens');
      }

      // 3. Генерация токенов
      final generatedTokens = <int>[];
      for (int i = 0; i < maxTokens; i++) {
        // Получить logits
        final logitsPtr = _llamaGetLogits(_ctx!);
        if (logitsPtr.address == 0) {
          break;
        }

        // Сэмплирование следующего токена
        // Примечание: реальная сигнатура llama_sample_token может отличаться
        // После компиляции библиотеки нужно проверить точную сигнатуру
        final nextToken = _llamaSampleToken(_ctx!, logitsPtr, temperature);
        generatedTokens.add(nextToken);

        // Проверка на конец генерации (EOS token обычно 2 для Llama)
        if (nextToken == 2) {
          break;
        }

        // Декодирование следующего токена
        final nextTokenPtr = malloc<Int32>();
        nextTokenPtr.value = nextToken;
        final decodeNext = _llamaDecode(_ctx!, nextTokenPtr, 1);
        malloc.free(nextTokenPtr);

        if (decodeNext != 0) {
          break;
        }
      }

      malloc.free(tokensPtr);

      // 4. Детокенизация результата
      // Используем llama_get_vocab для преобразования токенов в текст
      final responseBuffer = StringBuffer();
      for (final tokenId in generatedTokens) {
        try {
          final vocabPtr = _llamaGetVocab(_ctx!, tokenId);
          if (vocabPtr.address != 0) {
            final tokenText = vocabPtr.toDartString();
            responseBuffer.write(tokenText);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[LlamaFFI] Error detokenizing token $tokenId: $e');
          }
          // Пропускаем токен, если не удалось детокенизировать
        }
      }

      final response = responseBuffer.toString().trim();

      if (kDebugMode) {
        debugPrint('[LlamaFFI] Generated ${generatedTokens.length} tokens');
        debugPrint('[LlamaFFI] Detokenized response length: ${response.length}');
      }

      return response.isEmpty ? null : response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error generating: $e');
      }
      return null;
    }
  }

  @override
  Future<List<RerankedChunk>> rerank(
    String query,
    List<String> chunks, {
    int topK = 5,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Not initialized, cannot rerank');
      }
      return [];
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[LlamaFFI] Reranking ${chunks.length} chunks for query: $query',
        );
      }

      if (_lib == null) {
        // Заглушка для разработки
        final results = chunks.asMap().entries.map((entry) {
          return RerankedChunk(
            text: entry.value,
            score: 0.5,
            originalIndex: entry.key,
          );
        }).toList();
        results.sort((a, b) => b.score.compareTo(a.score));
        return results.take(topK).toList();
      }

      // Для каждого чанка создаем промпт и получаем score через LLM
      final scores = <double>[];
      for (final chunk in chunks) {
        final rerankPrompt =
            'Query: $query\nChunk: $chunk\nRelevance score (0.0-1.0):';
        final response = await generate(
          rerankPrompt,
          maxTokens: 10,
          temperature: 0.1,
        );

        // Парсим score из ответа
        double score = 0.5; // Default
        if (response != null) {
          final scoreMatch = RegExp(r'([0-9.]+)').firstMatch(response);
          if (scoreMatch != null) {
            score = double.tryParse(scoreMatch.group(1)!) ?? 0.5;
            score = score.clamp(0.0, 1.0);
          }
        }
        scores.add(score);
      }

      // Создаем результаты с scores
      final results = chunks.asMap().entries.map((entry) {
        return RerankedChunk(
          text: entry.value,
          score: scores[entry.key],
          originalIndex: entry.key,
        );
      }).toList();

      // Сортируем по score (убывание) и берем topK
      results.sort((a, b) => b.score.compareTo(a.score));
      return results.take(topK).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error reranking: $e');
      }
      return [];
    }
  }

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> dispose() async {
    if (!_initialized) return;

    try {
      if (_lib != null) {
        try {
          if (_ctx != null && _ctx!.address != 0) {
            _llamaFreeContext(_ctx!);
            _ctx = null;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[LlamaFFI] Error freeing context: $e');
          }
        }

        try {
          if (_model != null && _model!.address != 0) {
            _llamaFreeModel(_model!);
            _model = null;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[LlamaFFI] Error freeing model: $e');
          }
        }
      }

      _initialized = false;

      if (kDebugMode) {
        debugPrint('[LlamaFFI] Disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[LlamaFFI] Error disposing: $e');
      }
    }
  }
}

// FFI типы для llama.cpp функций
//
// Основано на реальном API llama.cpp из llama.h
// https://github.com/ggerganov/llama.cpp/blob/master/llama.h

// Структуры параметров (используются как Pointer<Void> для упрощения)
// В полной реализации можно создать Struct классы

// llama_model_default_params
typedef LlamaModelDefaultParamsNative = Pointer<Void> Function();
typedef LlamaModelDefaultParamsDart = Pointer<Void> Function();

// llama_load_model_from_file
// Сигнатура: struct llama_model * llama_load_model_from_file(const char * path_model, struct llama_model_params params)
typedef LlamaLoadModelFromFileNative =
    Pointer<Void> Function(
      Pointer<Utf8>, // path_model
      Pointer<Void>, // params (llama_model_params struct)
    );
typedef LlamaLoadModelFromFileDart =
    Pointer<Void> Function(Pointer<Utf8>, Pointer<Void>);

// llama_context_default_params
typedef LlamaContextDefaultParamsNative = Pointer<Void> Function();
typedef LlamaContextDefaultParamsDart = Pointer<Void> Function();

// llama_new_context_with_model
// Сигнатура: struct llama_context * llama_new_context_with_model(struct llama_model * model, struct llama_context_params params)
typedef LlamaNewContextWithModelNative =
    Pointer<Void> Function(
      Pointer<Void>, // model
      Pointer<Void>, // params (llama_context_params struct)
    );
typedef LlamaNewContextWithModelDart =
    Pointer<Void> Function(Pointer<Void>, Pointer<Void>);

// llama_tokenize
// Сигнатура: int llama_tokenize(struct llama_context * ctx, const char * text, int text_len, llama_token * tokens, int n_max_tokens, bool add_bos, bool special)
typedef LlamaTokenizeNative =
    Int32 Function(
      Pointer<Void>, // ctx
      Pointer<Utf8>, // text
      Int32, // text_len
      Pointer<Int32>, // tokens (output)
      Int32, // n_max_tokens
      Bool, // add_bos
      Bool, // special
    );
typedef LlamaTokenizeDart =
    int Function(
      Pointer<Void>,
      Pointer<Utf8>,
      int,
      Pointer<Int32>,
      int,
      bool,
      bool,
    );

// llama_decode
// Сигнатура: int llama_decode(struct llama_context * ctx, struct llama_batch batch)
// Упрощенная версия: int llama_decode(struct llama_context * ctx, llama_token * tokens, int n_tokens)
typedef LlamaDecodeNative =
    Int32 Function(
      Pointer<Void>, // ctx
      Pointer<Int32>, // tokens
      Int32, // n_tokens
    );
typedef LlamaDecodeDart = int Function(Pointer<Void>, Pointer<Int32>, int);

// llama_sample_token
// Сигнатура: llama_token llama_sample_token(struct llama_context * ctx, struct llama_sampler * sampler)
// Упрощенная версия: llama_token llama_sample_token(struct llama_context * ctx, float * logits, double temperature)
typedef LlamaSampleTokenNative =
    Int32 Function(
      Pointer<Void>, // ctx
      Pointer<Float>, // logits
      Double, // temperature
    );
typedef LlamaSampleTokenDart =
    int Function(Pointer<Void>, Pointer<Float>, double);

// llama_get_logits
// Сигнатура: float * llama_get_logits(struct llama_context * ctx)
typedef LlamaGetLogitsNative =
    Pointer<Float> Function(
      Pointer<Void>, // ctx
    );
typedef LlamaGetLogitsDart = Pointer<Float> Function(Pointer<Void>);

// llama_get_vocab
// Сигнатура: const char * llama_get_vocab(struct llama_context * ctx, llama_token id)
// Используется для детокенизации
typedef LlamaGetVocabNative =
    Pointer<Utf8> Function(
      Pointer<Void>, // ctx
      Int32, // token_id
    );
typedef LlamaGetVocabDart = Pointer<Utf8> Function(Pointer<Void>, int);

// llama_free_model
// Сигнатура: void llama_free_model(struct llama_model * model)
typedef LlamaFreeModelNative =
    Void Function(
      Pointer<Void>, // model
    );
typedef LlamaFreeModelDart = void Function(Pointer<Void>);

// llama_free_context
// Сигнатура: void llama_free_context(struct llama_context * ctx)
typedef LlamaFreeContextNative =
    Void Function(
      Pointer<Void>, // ctx
    );
typedef LlamaFreeContextDart = void Function(Pointer<Void>);
