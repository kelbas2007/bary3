/// Единые правила финансовой логики приложения.
///
/// Важно: все пороги и правила держим в одном месте, чтобы:
/// - поведение было предсказуемым для подростка
/// - не было расхождений между экранами
class FinanceRules {
  FinanceRules._();

  /// Порог, начиная с которого доход из Earnings Lab требует одобрения родителя.
  ///
  /// Значение в минорных единицах валюты (например, центы).
  static const int parentApprovalThresholdMinor = 10000; // 100.00

  /// Требует ли операция одобрения родителя по сумме.
  static bool requiresParentApproval(int amountMinor) {
    return amountMinor >= parentApprovalThresholdMinor;
  }
}

