import 'package:flutter/foundation.dart';

/// Менеджер версий моделей АКА
/// 
/// Поддерживает загрузку разных версий моделей (model_v1.bin, model_v2.bin)
/// без пересборки FFI-кода. Это позволяет обновлять модель при обновлении приложения.
class ModelVersionManager {
  /// Текущая версия АКА (увеличивается при обновлении модели)
  static const int currentAkaVersion = 1;

  /// Получить путь к модели для указанной версии АКА
  /// 
  /// [akaVersion] - версия АКА (1, 2, 3...)
  /// Возвращает путь к asset файлу модели (сжатая версия .xz)
  static String getModelPath(int akaVersion) {
    switch (akaVersion) {
      case 1:
        return 'assets/aka/models/model_v1.bin.xz';
      case 2:
        return 'assets/aka/models/model_v2.bin.xz';
      case 3:
        return 'assets/aka/models/model_v3.bin.xz';
      default:
        if (kDebugMode) {
          debugPrint('[ModelVersionManager] Unknown AKA version $akaVersion, using v1');
        }
        return 'assets/aka/models/model_v1.bin.xz';
    }
  }

  /// Проверить, поддерживается ли версия модели
  static bool isVersionSupported(int akaVersion) {
    return akaVersion >= 1 && akaVersion <= 3;
  }

  /// Получить метаданные модели для указанной версии
  static ModelMetadata getModelMetadata(int akaVersion) {
    switch (akaVersion) {
      case 1:
        return const ModelMetadata(
          version: 1,
          modelName: 'Llama 3.2 3B Q3_K_S',
          expectedSize: 350000000, // ~350MB сжатая версия (xz)
          quantization: 'Q3_K_S',
          compressed: true,
          compressionFormat: 'xz',
          uncompressedSize: 1470000000, // ~1.47GB несжатая версия (unsloth)
        );
      case 2:
        return const ModelMetadata(
          version: 2,
          modelName: 'Llama 4 3B Q3_K_S',
          expectedSize: 350000000,
          quantization: 'Q3_K_S',
          compressed: true,
          compressionFormat: 'xz',
          uncompressedSize: 1470000000, // ~1.47GB (unsloth)
        );
      default:
        return getModelMetadata(1);
    }
  }
}

/// Метаданные модели
class ModelMetadata {
  final int version;
  final String modelName;
  final int expectedSize; // в байтах (сжатый размер)
  final String quantization;
  final bool compressed; // сжата ли модель
  final String? compressionFormat; // формат сжатия (xz, gzip, etc.)
  final int? uncompressedSize; // размер несжатой версии в байтах

  const ModelMetadata({
    required this.version,
    required this.modelName,
    required this.expectedSize,
    required this.quantization,
    this.compressed = false,
    this.compressionFormat,
    this.uncompressedSize,
  });
}
