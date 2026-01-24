enum BariActionType { 
  openScreen, 
  openCalculator, 
  explainSimpler, 
  showSource, 
  createPlan,
  showMore,
}

class BariAction {
  final BariActionType type;
  final String label;
  final String? payload;
  const BariAction({required this.type, required this.label, this.payload});
}

class BariResponse {
  final String meaning;
  final String advice;
  final List<BariAction> actions;
  final double confidence;

  final String? sourceTitle;
  final String? sourceUrl;

  const BariResponse({
    required this.meaning,
    required this.advice,
    required this.actions,
    this.confidence = 0.7,
    this.sourceTitle,
    this.sourceUrl,
  });

  String toChatText({bool withSourceLine = false}) {
    final base = 'Что это значит: $meaning\nЧто делать: $advice';
    if (!withSourceLine || sourceUrl == null) return base;
    return '$base\nИсточник: ${sourceUrl!}';
  }

  BariResponse simpler() {
    // супер-простая версия без "умности"
    String s(String x) => x.length <= 90 ? x : '${x.substring(0, 90)}…';
    return BariResponse(
      meaning: s(meaning),
      advice: s(advice),
      actions: actions,
      confidence: confidence,
      sourceTitle: sourceTitle,
      sourceUrl: sourceUrl,
    );
  }
}

/// Результат анализа трат от Gemini Nano
class SpendingAnalysis {
  final String observation; // Что заметил
  final String suggestion; // Что улучшить
  final String motivation; // Мотивация

  SpendingAnalysis({
    required this.observation,
    required this.suggestion,
    required this.motivation,
  });

  Map<String, dynamic> toJson() => {
        'observation': observation,
        'suggestion': suggestion,
        'motivation': motivation,
      };

  factory SpendingAnalysis.fromJson(Map<String, dynamic> json) => SpendingAnalysis(
        observation: json['observation'] as String,
        suggestion: json['suggestion'] as String,
        motivation: json['motivation'] as String,
      );
}
