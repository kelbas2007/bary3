import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/aurora_theme.dart';

/// Диалог с прогресс-баром для загрузки модели ИИ
class ModelLoaderProgressDialog extends StatefulWidget {
  final Future<String> Function(ModelLoadProgressCallback? onProgress) loadModel;
  final VoidCallback? onComplete;
  final VoidCallback? onError;

  const ModelLoaderProgressDialog({
    super.key,
    required this.loadModel,
    this.onComplete,
    this.onError,
  });

  /// Показать диалог загрузки модели
  static Future<String?> show(
    BuildContext context, {
    required Future<String> Function(ModelLoadProgressCallback? onProgress) loadModel,
    VoidCallback? onComplete,
    VoidCallback? onError,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ModelLoaderProgressDialog(
        loadModel: loadModel,
        onComplete: onComplete,
        onError: onError,
      ),
    );
  }

  @override
  State<ModelLoaderProgressDialog> createState() => _ModelLoaderProgressDialogState();
}

class _ModelLoaderProgressDialogState extends State<ModelLoaderProgressDialog> {
  double _progress = 0.0;
  String _message = '';
  String _stage = 'loading';
  bool _isComplete = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  Future<void> _startLoading() async {
    try {
      final modelPath = await widget.loadModel((progress, stage, message) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
          _stage = stage;
          _message = message ?? _getDefaultMessage(stage);
        });
      });

      if (mounted) {
        setState(() {
          _isComplete = true;
          _progress = 1.0;
        });

        // Ждем немного, чтобы пользователь увидел завершение
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        widget.onComplete?.call();
        if (mounted) {
          Navigator.of(context).pop(modelPath);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
        widget.onError?.call();
      }
    }
  }

  String _getDefaultMessage(String stage) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return '';

    switch (stage) {
      case 'loading':
        return l10n.modelLoader_loading;
      case 'decompressing':
        return l10n.modelLoader_decompressing;
      case 'complete':
        return l10n.modelLoader_complete;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _isComplete || _hasError, // Разрешаем закрытие только после завершения или ошибки
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            gradient: AuroraTheme.blueGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AuroraTheme.neonBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: _isComplete
                    ? const Icon(
                        Icons.check_circle,
                        color: AuroraTheme.neonMint,
                        size: 40,
                      )
                    : _hasError
                        ? const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 40,
                          )
                        : const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AuroraTheme.neonBlue,
                            ),
                          ),
              ),
              const SizedBox(height: 24),

              // Заголовок
              Text(
                _hasError ? l10n.modelLoader_error : l10n.modelLoader_title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Прогресс-бар
              if (!_hasError) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progress >= 1.0
                          ? AuroraTheme.neonMint
                          : AuroraTheme.neonBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Сообщение
              Text(
                _hasError
                    ? (_errorMessage ?? l10n.modelLoader_errorMessage)
                    : (_message.isNotEmpty ? _message : _getDefaultMessage(_stage)),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              if (_hasError) ...[
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _errorMessage = null;
                          _progress = 0.0;
                        });
                        _startLoading();
                      },
                      child: Text(
                        l10n.modelLoader_retry,
                        style: const TextStyle(color: AuroraTheme.neonBlue),
                      ),
                    ),
                    const SizedBox(width: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.modelLoader_cancel,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Callback для прогресса загрузки/распаковки модели
typedef ModelLoadProgressCallback = void Function(
  double progress, // 0.0 - 1.0
  String stage, // 'loading', 'decompressing', 'complete'
  String? message, // Опциональное сообщение о текущем этапе
);
