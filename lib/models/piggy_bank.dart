class PiggyBank {
  final String id;
  final String name;
  final int targetAmount; // в центах
  final int currentAmount; // в центах
  final String icon; // название иконки
  final int color; // цвет в int
  final DateTime createdAt;
  final bool autoFillEnabled; // автопополнение
  final AutoFillType? autoFillType; // тип автопополнения
  final double? autoFillPercent; // процент от дохода
  final int? autoFillAmount; // фиксированная сумма в центах

  PiggyBank({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    this.icon = 'savings',
    this.color = 0xFF4CAF50,
    required this.createdAt,
    this.autoFillEnabled = false,
    this.autoFillType,
    this.autoFillPercent,
    this.autoFillAmount,
  });

  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;
  bool get isCompleted => currentAmount >= targetAmount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'icon': icon,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'autoFillEnabled': autoFillEnabled,
        'autoFillType': autoFillType?.toString().split('.').last,
        'autoFillPercent': autoFillPercent,
        'autoFillAmount': autoFillAmount,
      };

  factory PiggyBank.fromJson(Map<String, dynamic> json) => PiggyBank(
        id: json['id'] as String,
        name: json['name'] as String,
        targetAmount: json['targetAmount'] as int,
        currentAmount: json['currentAmount'] as int? ?? 0,
        icon: json['icon'] as String? ?? 'savings',
        color: json['color'] as int? ?? 0xFF4CAF50,
        createdAt: DateTime.parse(json['createdAt'] as String),
        autoFillEnabled: json['autoFillEnabled'] as bool? ?? false,
        autoFillType: json['autoFillType'] != null
            ? AutoFillType.values.firstWhere(
                (e) => e.toString().split('.').last == json['autoFillType'],
                orElse: () => AutoFillType.percent,
              )
            : null,
        autoFillPercent: json['autoFillPercent'] as double?,
        autoFillAmount: json['autoFillAmount'] as int?,
      );

  PiggyBank copyWith({
    String? id,
    String? name,
    int? targetAmount,
    int? currentAmount,
    String? icon,
    int? color,
    DateTime? createdAt,
    bool? autoFillEnabled,
    AutoFillType? autoFillType,
    double? autoFillPercent,
    int? autoFillAmount,
  }) =>
      PiggyBank(
        id: id ?? this.id,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        createdAt: createdAt ?? this.createdAt,
        autoFillEnabled: autoFillEnabled ?? this.autoFillEnabled,
        autoFillType: autoFillType ?? this.autoFillType,
        autoFillPercent: autoFillPercent ?? this.autoFillPercent,
        autoFillAmount: autoFillAmount ?? this.autoFillAmount,
      );
}

enum AutoFillType {
  percent, // процент от дохода
  fixed, // фиксированная сумма
}

