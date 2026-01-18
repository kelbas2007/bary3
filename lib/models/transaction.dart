class Transaction {
  final String id;
  final TransactionType type;
  final int amount; // в центах
  final DateTime date;
  final String? category;
  final String? note;
  final String? piggyBankId;
  final String? plannedEventId;
  final TransactionSource? source; // источник транзакции
  final bool parentApproved; // одобрено родителем (для earnings)
  final bool affectsWallet; // влияет ли на баланс кошелька (false для операций только между копилками)
  
  // Новые поля для обратной связи с родителями
  final String? childComment; // Комментарий от ребёнка о выполненном задании
  final List<String>? photoPaths; // Пути к фото результата (до 3 фото)
  final int? parentRating; // Оценка качества от родителя (1-5 звёзд)
  final String? parentFeedback; // Комментарий от родителя

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.category,
    this.note,
    this.piggyBankId,
    this.plannedEventId,
    this.source,
    this.parentApproved = true, // по умолчанию одобрено
    this.affectsWallet = true, // по умолчанию влияет на кошелёк
    this.childComment,
    this.photoPaths,
    this.parentRating,
    this.parentFeedback,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString().split('.').last,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
        'note': note,
        'piggyBankId': piggyBankId,
        'plannedEventId': plannedEventId,
        'source': source?.toString().split('.').last,
        'parentApproved': parentApproved,
        'affectsWallet': affectsWallet,
        'childComment': childComment,
        'photoPaths': photoPaths,
        'parentRating': parentRating,
        'parentFeedback': parentFeedback,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        type: TransactionType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type'],
          orElse: () => TransactionType.income,
        ),
        amount: json['amount'] as int,
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String?,
        note: json['note'] as String?,
        piggyBankId: json['piggyBankId'] as String?,
        plannedEventId: json['plannedEventId'] as String?,
        source: json['source'] != null
            ? TransactionSource.values.firstWhere(
                (e) => e.toString().split('.').last == json['source'],
                orElse: () => TransactionSource.manual,
              )
            : null,
        parentApproved: json['parentApproved'] as bool? ?? true,
        affectsWallet: json['affectsWallet'] as bool? ?? true, // по умолчанию true для старых транзакций
        childComment: json['childComment'] as String?,
        photoPaths: json['photoPaths'] != null
            ? List<String>.from(json['photoPaths'] as List)
            : null,
        parentRating: json['parentRating'] as int?,
        parentFeedback: json['parentFeedback'] as String?,
      );
}

extension TransactionCopyWith on Transaction {
  Transaction copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    DateTime? date,
    String? category,
    String? note,
    String? piggyBankId,
    String? plannedEventId,
    TransactionSource? source,
    bool? parentApproved,
    bool? affectsWallet,
    String? childComment,
    List<String>? photoPaths,
    int? parentRating,
    String? parentFeedback,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      piggyBankId: piggyBankId ?? this.piggyBankId,
      plannedEventId: plannedEventId ?? this.plannedEventId,
      source: source ?? this.source,
      parentApproved: parentApproved ?? this.parentApproved,
      affectsWallet: affectsWallet ?? this.affectsWallet,
      childComment: childComment ?? this.childComment,
      photoPaths: photoPaths ?? this.photoPaths,
      parentRating: parentRating ?? this.parentRating,
      parentFeedback: parentFeedback ?? this.parentFeedback,
    );
  }
}

enum TransactionSource {
  manual, // обычная
  piggyBank, // из копилки
  plannedEvent, // из запланированного события
  earningsLab, // из Earnings Lab
}

enum TransactionType {
  income,
  expense,
}

