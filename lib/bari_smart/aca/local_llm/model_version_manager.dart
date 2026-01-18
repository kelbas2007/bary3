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
  /// Возвращает путь к asset файлу модели
  static String getModelPath(int akaVersion) {
    switch (akaVersion) {
      case 1:
        return 'assets/aka/models/model_v1.bin';
      case 2:
        return 'assets/aka/models/model_v2.bin';
      case 3:
        return 'assets/aka/models/model_v3.bin';
      default:
        if (kDebugMode) {
          debugPrint('[ModelVersionManager] Unknown AKA version $akaVersion, using v1');
        }
        return 'assets/aka/models/model_v1.bin';
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
          modelName: 'Llama 3.2 3B Q4_K_M',
          expectedSize: 200000000, // ~200MB
          quantization: 'Q4_K_M',
        );
      case 2:
        return const ModelMetadata(
          version: 2,
          modelName: 'Llama 4 3B Q4_K_M',
          expectedSize: 200000000,
          quantization: 'Q4_K_M',
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
  final int expectedSize; // в байтах
  final String quantization;

  const ModelMetadata({
    required this.version,
    required this.modelName,
    required this.expectedSize,
    required this.quantization,
  });
}
