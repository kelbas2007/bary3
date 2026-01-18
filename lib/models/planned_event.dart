import 'transaction.dart';
import 'note.dart';

class PlannedEvent {
  final String id;
  final TransactionType type;
  final int amount; // в центах
  final String? name;
  final String? category;
  final DateTime dateTime;
  final RepeatType repeat;
  final bool notificationEnabled;
  final int? notificationMinutesBefore; // за сколько минут до события
  final PlannedEventStatus status;
  final EventSource? source; // источник события
  final bool autoExecute; // автоматически выполнять при наступлении даты
  final String? payoutPiggyBankId; // ID копилки для выплаты (null = кошелёк)
  final bool
  affectsWallet; // влияет ли на баланс кошелька (true для кошелька, false для копилки)
  final String? calendarEventId; // ID события в системном календаре
  final SyncStatus syncStatus; // статус синхронизации
  final List<String> linkedNoteIds; // ID привязанных заметок
  final bool syncToCalendar; // синхронизировать ли с календарём

  PlannedEvent({
    required this.id,
    required this.type,
    required this.amount,
    this.name,
    this.category,
    required this.dateTime,
    this.repeat = RepeatType.none,
    this.notificationEnabled = true,
    this.notificationMinutesBefore = 60,
    this.status = PlannedEventStatus.planned,
    this.source,
    this.autoExecute = false,
    this.payoutPiggyBankId,
    this.affectsWallet = true, // по умолчанию в кошелёк
    this.calendarEventId,
    this.syncStatus = SyncStatus.local,
    this.linkedNoteIds = const [],
    this.syncToCalendar = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'amount': amount,
    'name': name,
    'category': category,
    'dateTime': dateTime.toIso8601String(),
    'repeat': repeat.toString().split('.').last,
    'notificationEnabled': notificationEnabled,
    'notificationMinutesBefore': notificationMinutesBefore,
    'status': status.toString().split('.').last,
    'source': source?.toString().split('.').last,
    'autoExecute': autoExecute,
    'payoutPiggyBankId': payoutPiggyBankId,
    'affectsWallet': affectsWallet,
    'calendarEventId': calendarEventId,
    'syncStatus': syncStatus.toString().split('.').last,
    'linkedNoteIds': linkedNoteIds,
    'syncToCalendar': syncToCalendar,
  };

  factory PlannedEvent.fromJson(Map<String, dynamic> json) => PlannedEvent(
    id: json['id'] as String,
    type: TransactionType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
      orElse: () => TransactionType.income,
    ),
    amount: json['amount'] as int,
    name: json['name'] as String?,
    category: json['category'] as String?,
    dateTime: DateTime.parse(json['dateTime'] as String),
    repeat: RepeatType.values.firstWhere(
      (e) => e.toString().split('.').last == json['repeat'],
      orElse: () => RepeatType.none,
    ),
    notificationEnabled: json['notificationEnabled'] as bool? ?? true,
    notificationMinutesBefore: json['notificationMinutesBefore'] as int?,
    status: PlannedEventStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
      orElse: () => PlannedEventStatus.planned,
    ),
    source: json['source'] != null
        ? EventSource.values.firstWhere(
            (e) => e.toString().split('.').last == json['source'],
            orElse: () => EventSource.manual,
          )
        : null,
    autoExecute: json['autoExecute'] as bool? ?? false,
    payoutPiggyBankId: json['payoutPiggyBankId'] as String?,
    affectsWallet:
        json['affectsWallet'] as bool? ??
        true, // по умолчанию в кошелёк для старых событий
    calendarEventId: json['calendarEventId'] as String?,
    syncStatus: json['syncStatus'] != null
        ? SyncStatus.values.firstWhere(
            (e) => e.toString().split('.').last == json['syncStatus'],
            orElse: () => SyncStatus.local,
          )
        : SyncStatus.local,
    linkedNoteIds:
        (json['linkedNoteIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    syncToCalendar: json['syncToCalendar'] as bool? ?? false,
  );

  PlannedEvent copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? name,
    String? category,
    DateTime? dateTime,
    RepeatType? repeat,
    bool? notificationEnabled,
    int? notificationMinutesBefore,
    PlannedEventStatus? status,
    EventSource? source,
    bool? autoExecute,
    String? payoutPiggyBankId,
    bool? affectsWallet,
    String? calendarEventId,
    SyncStatus? syncStatus,
    List<String>? linkedNoteIds,
    bool? syncToCalendar,
  }) => PlannedEvent(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    name: name ?? this.name,
    category: category ?? this.category,
    dateTime: dateTime ?? this.dateTime,
    repeat: repeat ?? this.repeat,
    notificationEnabled: notificationEnabled ?? this.notificationEnabled,
    notificationMinutesBefore:
        notificationMinutesBefore ?? this.notificationMinutesBefore,
    status: status ?? this.status,
    source: source ?? this.source,
    autoExecute: autoExecute ?? this.autoExecute,
    payoutPiggyBankId: payoutPiggyBankId ?? this.payoutPiggyBankId,
    affectsWallet: affectsWallet ?? this.affectsWallet,
    calendarEventId: calendarEventId ?? this.calendarEventId,
    syncStatus: syncStatus ?? this.syncStatus,
    linkedNoteIds: linkedNoteIds ?? this.linkedNoteIds,
    syncToCalendar: syncToCalendar ?? this.syncToCalendar,
  );
}

enum RepeatType { none, daily, weekly, monthly, yearly }

enum PlannedEventStatus {
  planned,
  completed,
  canceled,
  missed, // пропущено
}

enum EventSource {
  manual, // обычный
  calculator, // из калькулятора
  earningsLab, // из Earnings Lab
  rule24Hours, // из правила 24 часов
}
