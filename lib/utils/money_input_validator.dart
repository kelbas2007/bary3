import 'package:flutter/material.dart';
import 'package:bary3/l10n/app_localizations.dart';

/// Код ошибки валидации денежного ввода.
enum MoneyValidationError { empty, notANumber, notPositive, tooSmall }

/// Результат валидации денежного ввода.
class MoneyValidationResult {
  final bool isValid;
  final int? amountMinor;
  final MoneyValidationError? error;

  const MoneyValidationResult.valid(this.amountMinor)
    : isValid = true,
      error = null;

  const MoneyValidationResult.invalid(this.error)
    : isValid = false,
      amountMinor = null;

  /// Возвращает локализованный текст ошибки.
  String? getErrorMessage(BuildContext context) {
    if (error == null) return null;
    final l10n = AppLocalizations.of(context)!;
    switch (error!) {
      case MoneyValidationError.empty:
        return l10n.moneyValidator_enterAmount;
      case MoneyValidationError.notANumber:
        return l10n.moneyValidator_notANumber;
      case MoneyValidationError.notPositive:
        return l10n.moneyValidator_mustBePositive;
      case MoneyValidationError.tooSmall:
        return l10n.moneyValidator_tooSmall;
    }
  }
}

/// Единый валидатор сумм для всего приложения.
///
/// Принимает строку (с точкой или запятой) и возвращает сумму в минорных
/// единицах (например, центы) либо код ошибки.
class MoneyInputValidator {
  MoneyInputValidator._();

  static MoneyValidationResult validateToMinor(String raw) {
    final text = raw.trim().replaceAll(',', '.');
    if (text.isEmpty) {
      return const MoneyValidationResult.invalid(MoneyValidationError.empty);
    }

    final value = double.tryParse(text);
    if (value == null) {
      return const MoneyValidationResult.invalid(
        MoneyValidationError.notANumber,
      );
    }
    if (value <= 0) {
      return const MoneyValidationResult.invalid(
        MoneyValidationError.notPositive,
      );
    }

    final minor = (value * 100).round();
    if (minor <= 0) {
      return const MoneyValidationResult.invalid(MoneyValidationError.tooSmall);
    }

    return MoneyValidationResult.valid(minor);
  }

  /// Удобный хелпер: показывает SnackBar при ошибке и возвращает amountMinor.
  static int? validateAndShowError(BuildContext context, String raw) {
    final res = validateToMinor(raw);
    if (!res.isValid) {
      final errorMessage = res.getErrorMessage(context);
      if (errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
      return null;
    }
    return res.amountMinor;
  }
}
