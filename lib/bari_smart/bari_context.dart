class BariContext {
  final String localeTag;      // ru_RU / de_DE / en_US
  final String currencyCode;   // EUR / USD / CHF ...
  final int walletBalanceCents;
  final String? currentScreenId;
  
  // Расширенный контекст (опционально)
  final List<Map<String, dynamic>>? piggyBanks; // Краткая информация о копилках
  final List<Map<String, dynamic>>? calendarEvents; // Ближайшие события
  final List<Map<String, dynamic>>? recentTransactions; // Последние транзакции
  
  // Дополнительный контекст для AI
  final int playerLevel;
  final int playerXp;
  final int lessonsCompleted;
  final int? playerAge; // Возраст игрока для персонализации
  
  // Информация о недавних действиях пользователя
  final List<Map<String, dynamic>>? recentActions; // Недавние действия пользователя
  final DateTime? lastLessonCompletedAt; // Когда был пройден последний урок
  final DateTime? lastPlanCreatedAt; // Когда был создан последний план
  final DateTime? lastPiggyTopUpAt; // Когда было последнее пополнение копилки
  final List<String>? recentHintTypes; // Типы недавно показанных подсказок

  const BariContext({
    required this.localeTag,
    required this.currencyCode,
    required this.walletBalanceCents,
    this.currentScreenId,
    this.piggyBanks,
    this.calendarEvents,
    this.recentTransactions,
    this.playerLevel = 1,
    this.playerXp = 0,
    this.lessonsCompleted = 0,
    this.playerAge,
    this.recentActions,
    this.lastLessonCompletedAt,
    this.lastPlanCreatedAt,
    this.lastPiggyTopUpAt,
    this.recentHintTypes,
  });
  
  // Helper getters for AI Provider
  int get walletBalance => walletBalanceCents;
  String get currency => currencyCode;
  String get screenContext => currentScreenId ?? 'balance';
  
  int get piggyBanksCount => piggyBanks?.length ?? 0;
  
  int get totalPiggyBanksSaved {
    if (piggyBanks == null) return 0;
    int total = 0;
    for (final bank in piggyBanks!) {
      total += (bank['currentAmount'] as int?) ?? 0;
    }
    return total;
  }
  
  int get upcomingEventsCount => calendarEvents?.length ?? 0;
  int get lessonsCompletedCount => lessonsCompleted;
  
  /// Получает сумму доходов за последние N дней
  int getIncomeLastDays(int days) {
    if (recentTransactions == null) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    int total = 0;
    for (final t in recentTransactions!) {
      final dateStr = t['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null || date.isBefore(cutoff)) continue;
      final type = t['type']?.toString() ?? '';
      if (type.contains('income')) {
        total += (t['amount'] as int? ?? 0);
      }
    }
    return total;
  }
  
  /// Получает сумму расходов за последние N дней
  int getExpensesLastDays(int days) {
    if (recentTransactions == null) return 0;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    int total = 0;
    for (final t in recentTransactions!) {
      final dateStr = t['date'] as String?;
      if (dateStr == null) continue;
      final date = DateTime.tryParse(dateStr);
      if (date == null || date.isBefore(cutoff)) continue;
      final type = t['type']?.toString() ?? '';
      if (type.contains('expense')) {
        total += (t['amount'] as int? ?? 0);
      }
    }
    return total;
  }
  
  /// Форматирует последние транзакции для AI промпта
  String getRecentTransactionsSummary(String locale) {
    if (recentTransactions == null || recentTransactions!.isEmpty) {
      return locale == 'ru' ? 'Нет недавних транзакций' 
           : locale == 'en' ? 'No recent transactions'
           : 'Keine kürzlichen Transaktionen';
    }
    
    final symbol = _getCurrencySymbol(currencyCode);
    final transactions = recentTransactions!.take(10).map((t) {
      final amount = (t['amount'] as int? ?? 0) / 100;
      final type = t['type']?.toString().contains('income') == true ? '+' : '-';
      final category = t['category'] ?? '';
      final date = t['date'] != null 
          ? DateTime.parse(t['date']).toString().substring(0, 10)
          : '';
      return '$date: $type${amount.toStringAsFixed(2)}$symbol ($category)';
    }).join('\n');
    
    return transactions;
  }
  
  /// Форматирует ближайшие события для AI промпта
  String getUpcomingEventsSummary(String locale) {
    if (calendarEvents == null || calendarEvents!.isEmpty) {
      return locale == 'ru' ? 'Нет запланированных событий'
           : locale == 'en' ? 'No upcoming events'
           : 'Keine bevorstehenden Ereignisse';
    }
    
    final symbol = _getCurrencySymbol(currencyCode);
    final events = calendarEvents!.take(5).map((e) {
      final title = e['title'] ?? 'Событие';
      final amount = (e['amount'] as int? ?? 0) / 100;
      final date = e['date'] != null
          ? DateTime.parse(e['date']).toString().substring(0, 10)
          : '';
      final type = e['type']?.toString().contains('income') == true ? '+' : '-';
      return '$date: $title ($type${amount.toStringAsFixed(2)}$symbol)';
    }).join('\n');
    
    return events;
  }
  
  String _getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case 'EUR': return '€';
      case 'USD': return '\$';
      case 'RUB': return '₽';
      case 'CHF': return 'CHF';
      case 'GBP': return '£';
      default: return code;
    }
  }
}






