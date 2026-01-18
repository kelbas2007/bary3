
class BariMemory {
  BariMood mood;
  final List<BariAction> recentActions; // последние 10
  final List<String> recentTips; // последние 10

  BariMemory({
    this.mood = BariMood.happy,
    List<BariAction>? recentActions,
    List<String>? recentTips,
  })  : recentActions = recentActions ?? [],
        recentTips = recentTips ?? [];

  void addAction(BariAction action) {
    recentActions.insert(0, action);
    if (recentActions.length > 10) {
      recentActions.removeLast();
    }
    _updateMood();
  }

  void addTip(String tip) {
    recentTips.insert(0, tip);
    if (recentTips.length > 10) {
      recentTips.removeLast();
    }
  }

  void _updateMood() {
    // Логика изменения настроения
    final completedPlans = recentActions
        .where((a) => a.type == BariActionType.planCompleted)
        .length;
    final lessons = recentActions
        .where((a) => a.type == BariActionType.lessonCompleted)
        .length;
    final expensesWithoutPlans = recentActions
        .where((a) =>
            a.type == BariActionType.expense &&
            !recentActions.any((b) =>
                b.type == BariActionType.planCompleted &&
                b.transactionId == a.transactionId))
        .length;

    if (completedPlans + lessons > expensesWithoutPlans * 2) {
      mood = BariMood.happy;
    } else if (expensesWithoutPlans > completedPlans + lessons) {
      mood = BariMood.encouraging;
    } else {
      mood = BariMood.neutral;
    }
  }

  Map<String, dynamic> toJson() => {
        'mood': mood.toString().split('.').last,
        'recentActions': recentActions.map((a) => a.toJson()).toList(),
        'recentTips': recentTips,
      };

  factory BariMemory.fromJson(Map<String, dynamic> json) {
    final memory = BariMemory(
      mood: BariMood.values.firstWhere(
        (e) => e.toString().split('.').last == json['mood'],
        orElse: () => BariMood.happy,
      ),
      recentActions: (json['recentActions'] as List<dynamic>?)
              ?.map((a) => BariAction.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recentTips: (json['recentTips'] as List<dynamic>?)
              ?.map((t) => t as String)
              .toList() ??
          [],
    );
    return memory;
  }
}

enum BariMood {
  happy,
  neutral,
  encouraging,
}

class BariAction {
  final BariActionType type;
  final DateTime timestamp;
  final String? transactionId;
  final String? piggyBankId;
  final String? lessonId;
  final int? amount;

  BariAction({
    required this.type,
    required this.timestamp,
    this.transactionId,
    this.piggyBankId,
    this.lessonId,
    this.amount,
  });

  Map<String, dynamic> toJson() => {
        'type': type.toString().split('.').last,
        'timestamp': timestamp.toIso8601String(),
        'transactionId': transactionId,
        'piggyBankId': piggyBankId,
        'lessonId': lessonId,
        'amount': amount,
      };

  factory BariAction.fromJson(Map<String, dynamic> json) => BariAction(
        type: BariActionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => BariActionType.income,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        transactionId: json['transactionId'] as String?,
        piggyBankId: json['piggyBankId'] as String?,
        lessonId: json['lessonId'] as String?,
        amount: json['amount'] as int?,
      );
}

enum BariActionType {
  income,
  expense,
  planCreated,
  planCompleted,
  piggyBankCreated,
  piggyBankCompleted,
  lessonCompleted,
}

