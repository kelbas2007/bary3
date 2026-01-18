// FFI типы для llama.cpp функций
// 
// ВАЖНО: Эти типы должны соответствовать реальным сигнатурам llama.cpp API.
// После компиляции библиотеки проверьте сигнатуры через:
//   nm -D libllama.so | grep llama
//
// Документация llama.cpp API:
//   https://github.com/ggerganov/llama.cpp/blob/master/llama.h

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// Структуры (используйте Struct из package:ffi)
// Пример:
// class LlamaModelParams extends Struct {
//   @Int32()
//   external int n_gpu_layers;
//   @Bool()
//   external bool use_mmap;
//   // ... остальные поля
// }

// Типы функций (обновите после проверки реальных сигнатур)

// llama_model_default_params
typedef LlamaModelDefaultParamsNative = Pointer<Void> Function();
typedef LlamaModelDefaultParamsDart = Pointer<Void> Function();

// llama_load_model_from_file
// Проверьте реальную сигнатуру: может быть Pointer<Struct> вместо Pointer<Void>
typedef LlamaLoadModelFromFileNative = Pointer<Void> Function(
    Pointer<Utf8>, // path_model
    Pointer<Void>  // params (может быть Struct)
);
typedef LlamaLoadModelFromFileDart = Pointer<Void> Function(
    Pointer<Utf8>,
    Pointer<Void>
);

// llama_context_default_params
typedef LlamaContextDefaultParamsNative = Pointer<Void> Function();
typedef LlamaContextDefaultParamsDart = Pointer<Void> Function();

// llama_new_context_with_model
typedef LlamaNewContextWithModelNative = Pointer<Void> Function(
    Pointer<Void>, // model
    Pointer<Void>  // params
);
typedef LlamaNewContextWithModelDart = Pointer<Void> Function(
    Pointer<Void>,
    Pointer<Void>
);

// llama_tokenize
// ВАЖНО: Проверьте реальную сигнатуру - может отличаться
// Возможные варианты:
//   - int llama_tokenize(ctx, text, text_len, tokens, n_max_tokens, add_bos, special)
//   - int llama_tokenize(ctx, text, tokens, n_max_tokens, add_bos)
typedef LlamaTokenizeNative = Int32 Function(
    Pointer<Void>,      // ctx
    Pointer<Utf8>,      // text
    Int32,              // text_len
    Pointer<Int32>,     // tokens (output)
    Int32,              // n_max_tokens
    Bool,               // add_bos
    Bool                // special
);
typedef LlamaTokenizeDart = int Function(
    Pointer<Void>,
    Pointer<Utf8>,
    int,
    Pointer<Int32>,
    int,
    bool,
    bool
);

// llama_decode
// ВАЖНО: Может использовать llama_batch структуру
typedef LlamaDecodeNative = Int32 Function(
    Pointer<Void>,      // ctx
    Pointer<Void>       // batch (может быть Struct)
);
typedef LlamaDecodeDart = int Function(
    Pointer<Void>,
    Pointer<Void>
);

// llama_sample_token (или llama_sample)
// Проверьте точное имя функции
typedef LlamaSampleTokenNative = Int32 Function(
    Pointer<Void>,      // ctx
    Pointer<Void>       // sampler (может быть Struct)
);
typedef LlamaSampleTokenDart = int Function(
    Pointer<Void>,
    Pointer<Void>
);

// llama_get_logits
typedef LlamaGetLogitsNative = Pointer<Float> Function(
    Pointer<Void>       // ctx
);
typedef LlamaGetLogitsDart = Pointer<Float> Function(
    Pointer<Void>
);

// llama_free_model
typedef LlamaFreeModelNative = Void Function(
    Pointer<Void>       // model
);
typedef LlamaFreeModelDart = void Function(
    Pointer<Void>
);

// llama_free_context
typedef LlamaFreeContextNative = Void Function(
    Pointer<Void>       // ctx
);
typedef LlamaFreeContextDart = void Function(
    Pointer<Void>
);
