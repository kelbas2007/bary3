import '../l10n/app_localizations.dart';

/// Конфигурация параметров шаблона
class TemplateParameter {
  final String id;
  final String Function(AppLocalizations l10n) label;
  final String Function(AppLocalizations l10n)? hint;
  final ParameterType type;
  final dynamic defaultValue;
  final List<dynamic>? options; // Для select типа
  final bool required;
  final String Function(AppLocalizations l10n, dynamic value)? formatValue;

  const TemplateParameter({
    required this.id,
    required this.label,
    this.hint,
    required this.type,
    this.defaultValue,
    this.options,
    this.required = false,
    this.formatValue,
  });
}

enum ParameterType {
  text,
  number,
  date,
  select,
  multiSelect,
  checkbox,
  piggyBank, // Выбор копилки
  event, // Выбор события
  amount, // Сумма в рублях
}

/// Конфигурация шаблона с параметрами
class TemplateConfig {
  final String templateId;
  final List<TemplateParameter> parameters;
  final Future<String> Function(
    AppLocalizations l10n,
    Map<String, dynamic> params,
  ) contentBuilder;
  final Future<String?> Function(
    AppLocalizations l10n,
    Map<String, dynamic> params,
    dynamic context, // BariContext from bari_context_adapter
  )? bariHintBuilder; // Подсказка от Бари на основе параметров

  const TemplateConfig({
    required this.templateId,
    required this.parameters,
    required this.contentBuilder,
    this.bariHintBuilder,
  });
}
