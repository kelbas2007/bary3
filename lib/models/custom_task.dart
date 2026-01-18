import 'planned_event.dart';

class CustomTask {
  final String id;
  final String title;
  final String category; // Дом, Учёба, Спорт, Другое
  final int rewardAmountMinor; // в minor units (cents)
  final String? description;
  final RepeatType repeatType;
  final int cooldownHours; // 0, 6, 12, 24, 48
  final DateTime? lastCompletedAt;
  final DateTime createdAt;

  CustomTask({
    required this.id,
    required this.title,
    required this.category,
    required this.rewardAmountMinor,
    this.description,
    required this.repeatType,
    required this.cooldownHours,
    this.lastCompletedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'rewardAmountMinor': rewardAmountMinor,
      'description': description,
      'repeatType': repeatType.toString().split('.').last,
      'cooldownHours': cooldownHours,
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomTask.fromJson(Map<String, dynamic> json) {
    return CustomTask(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      rewardAmountMinor: json['rewardAmountMinor'] as int,
      description: json['description'] as String?,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.toString().split('.').last == json['repeatType'],
        orElse: () => RepeatType.none,
      ),
      cooldownHours: json['cooldownHours'] as int? ?? 0,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  CustomTask copyWith({
    String? id,
    String? title,
    String? category,
    int? rewardAmountMinor,
    String? description,
    RepeatType? repeatType,
    int? cooldownHours,
    DateTime? lastCompletedAt,
    DateTime? createdAt,
  }) {
    return CustomTask(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      rewardAmountMinor: rewardAmountMinor ?? this.rewardAmountMinor,
      description: description ?? this.description,
      repeatType: repeatType ?? this.repeatType,
      cooldownHours: cooldownHours ?? this.cooldownHours,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

