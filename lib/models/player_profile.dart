class PlayerProfile {
  final int xp;
  final int streakDays; // серия дней
  final bool premiumUnlocked;
  final DateTime? lastActivityDate;
  final int selfControlScore; // индикатор самоконтроля (0-100)

  PlayerProfile({
    this.xp = 0,
    this.streakDays = 0,
    this.premiumUnlocked = false,
    this.lastActivityDate,
    this.selfControlScore = 50, // начальное значение
  });

  int get level {
    // Улучшенная формула: экспоненциальный рост
    if (xp < 100) return 1;
    if (xp < 250) return 2;
    if (xp < 450) return 3;
    if (xp < 700) return 4;
    
    // Для уровней > 4: формула
    int level = 4;
    int requiredXP = 700;
    final int currentXP = xp;
    
    while (currentXP >= requiredXP) {
      level++;
      requiredXP += (level * 50); // Увеличиваем требования
    }
    
    return level;
  }

  int get xpForNextLevel {
    final currentLevel = level;
    if (currentLevel == 1) return 100;
    if (currentLevel == 2) return 250;
    if (currentLevel == 3) return 450;
    if (currentLevel == 4) return 700;
    
    // Для уровней > 4
    int requiredXP = 700;
    for (int i = 5; i <= currentLevel; i++) {
      requiredXP += (i * 50);
    }
    return requiredXP;
  }

  int get xpProgress {
    final currentLevel = level;
    int levelStartXP = 0;
    
    if (currentLevel > 1) {
      if (currentLevel == 2) {
        levelStartXP = 100;
      } else if (currentLevel == 3) {
        levelStartXP = 250;
      } else if (currentLevel == 4) {
        levelStartXP = 450;
      } else {
        levelStartXP = 700;
        for (int i = 5; i < currentLevel; i++) {
          levelStartXP += (i * 50);
        }
      }
    }
    
    return xp - levelStartXP;
  }

  double get xpProgressPercent => xpForNextLevel > 0 ? xpProgress / xpForNextLevel : 0.0;

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level, // вычисляемое значение
        'streakDays': streakDays,
        'premiumUnlocked': premiumUnlocked,
        'lastActivityDate': lastActivityDate?.toIso8601String(),
        'selfControlScore': selfControlScore,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
        xp: json['xp'] as int? ?? 0,
        streakDays: json['streakDays'] as int? ?? 0,
        premiumUnlocked: json['premiumUnlocked'] as bool? ?? false,
        lastActivityDate: json['lastActivityDate'] != null
            ? DateTime.parse(json['lastActivityDate'] as String)
            : null,
        selfControlScore: json['selfControlScore'] as int? ?? 50,
      );

  PlayerProfile copyWith({
    int? xp,
    int? streakDays,
    bool? premiumUnlocked,
    DateTime? lastActivityDate,
    int? selfControlScore,
  }) =>
      PlayerProfile(
        xp: xp ?? this.xp,
        streakDays: streakDays ?? this.streakDays,
        premiumUnlocked: premiumUnlocked ?? this.premiumUnlocked,
        lastActivityDate: lastActivityDate ?? this.lastActivityDate,
        selfControlScore: selfControlScore ?? this.selfControlScore,
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.icon = 'star',
    this.unlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        icon: json['icon'] as String? ?? 'star',
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
      );

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    bool? unlocked,
    DateTime? unlockedAt,
  }) =>
      Achievement(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        unlocked: unlocked ?? this.unlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
}

