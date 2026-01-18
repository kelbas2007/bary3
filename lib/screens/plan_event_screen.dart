import 'package:flutter/material.dart';
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/note_service.dart';
import '../theme/aurora_theme.dart';
import '../models/bari_memory.dart';
import '../l10n/app_localizations.dart';
import '../utils/date_formatter.dart';
import '../models/edit_scope.dart';
import '../services/deleted_events_service.dart';
import '../utils/repeating_events_helper.dart';
import 'note_editor_screen.dart';
import 'notes_screen.dart';

class PlanEventScreen extends StatefulWidget {
  final PlannedEvent? editingEvent;
  final EditScope?
  editScope; // Область редактирования (для повторяющихся событий)

  const PlanEventScreen({super.key, this.editingEvent, this.editScope});

  @override
  State<PlanEventScreen> createState() => _PlanEventScreenState();
}

class _PlanEventScreenState extends State<PlanEventScreen> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  TransactionType _type = TransactionType.income;
  String? _category;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  RepeatType _repeat = RepeatType.none;
  bool _notificationEnabled = true;
  int? _notificationMinutesBefore = 60;
  bool _autoExecute = false; // автоматически выполнять при наступлении даты
  bool _isRepeatingEvent =
      false; // является ли редактируемое событие частью повторяющейся серии
  String? _baseEventId; // базовый ID для повторяющихся событий
  int _relatedEventsCount = 0; // количество связанных событий
  final NoteService _noteService = NoteService();
  List<String> _linkedNoteIds = []; // ID связанных заметок

  // Разрешённые значения категорий для выпадающего списка
  static const List<String> _allowedCategories = [
    'food',
    'transport',
    'entertainment',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _noteService.init();
    if (widget.editingEvent != null) {
      _loadEditingEvent();
    }
  }

  Future<void> _loadEditingEvent() async {
    if (widget.editingEvent == null) return;

    final event = widget.editingEvent!;
    _amountController.text = (event.amount / 100).toStringAsFixed(0);
    _nameController.text = event.name ?? '';
    _type = event.type;
    _category = event.category;
    _selectedDate = event.dateTime;
    _selectedTime = TimeOfDay.fromDateTime(event.dateTime);
    _repeat = event.repeat;
    _notificationEnabled = event.notificationEnabled;
    _notificationMinutesBefore = event.notificationMinutesBefore;
    _autoExecute = event.autoExecute;
    _linkedNoteIds = List<String>.from(event.linkedNoteIds);

    // Если категория у события не входит в список доступных,
    // не пытаемся ставить её как initialValue (иначе падение dropdown)
    if (_category != null && !_allowedCategories.contains(_category)) {
      _category = null;
    }

    // Определяем, является ли это повторяющимся событием
    // (частью повторяющейся серии с суффиксом "_timestamp")
    _isRepeatingEvent = RepeatingEventsHelper.isRepeatingInstance(event);

    if (_isRepeatingEvent) {
      // Определяем базовый ID
      _baseEventId = RepeatingEventsHelper.getBaseEventId(event.id);

      if (_baseEventId != null && _baseEventId!.isNotEmpty) {
        // Подсчитываем количество связанных событий (исключая удаленные)
        final allEvents = await StorageService.getPlannedEvents();
        if (!mounted) return;

        final relatedEvents = RepeatingEventsHelper.findRelatedEvents(
          allEvents,
          _baseEventId,
        );

        // Батч-проверка удаленных событий
        final relatedIds = relatedEvents.map((e) => e.id).toList();
        final deletedIds = await DeletedEventsService.getDeletedEventIds(
          relatedIds,
        );
        if (!mounted) return;

        // Считаем только не удаленные
        _relatedEventsCount = relatedEvents
            .where((e) => !deletedIds.contains(e.id))
            .length;
      } else {
        _relatedEventsCount = 0;
      }

      if (mounted) {
        setState(() {});
      }
    } else {
      // Если это не повторяющееся событие, сбрасываем счетчик
      _relatedEventsCount = 0;
      _baseEventId = null;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  /// Создаёт все повторяющиеся события на год вперёд
  /// Ограничивает максимальное количество событий для предотвращения зависаний
  List<PlannedEvent> _createRepeatEvents(PlannedEvent baseEvent) {
    final List<PlannedEvent> repeatEvents = [baseEvent];

    if (baseEvent.repeat == RepeatType.none) {
      return repeatEvents;
    }

    final DateTime endDate = DateTime.now().add(const Duration(days: 365));
    DateTime currentDate = baseEvent.dateTime;

    // Максимальное количество событий для предотвращения зависаний
    const int maxEvents = 500;
    int eventCount = 1; // Уже есть базовое событие

    while (currentDate.isBefore(endDate) && eventCount < maxEvents) {
      DateTime nextDate;
      switch (baseEvent.repeat) {
        case RepeatType.daily:
          nextDate = currentDate.add(const Duration(days: 1));
          break;
        case RepeatType.weekly:
          nextDate = currentDate.add(const Duration(days: 7));
          break;
        case RepeatType.monthly:
          nextDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        case RepeatType.yearly:
          nextDate = DateTime(
            currentDate.year + 1,
            currentDate.month,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
          break;
        default:
          return repeatEvents;
      }

      if (nextDate.isAfter(endDate)) break;

      final event = PlannedEvent(
        id: '${baseEvent.id}_${nextDate.millisecondsSinceEpoch}',
        type: baseEvent.type,
        amount: baseEvent.amount,
        name: baseEvent.name,
        category: baseEvent.category,
        dateTime: nextDate,
        repeat: baseEvent.repeat,
        notificationEnabled: baseEvent.notificationEnabled,
        notificationMinutesBefore: baseEvent.notificationMinutesBefore,
        source: baseEvent.source,
        autoExecute: baseEvent.autoExecute,
      );

      repeatEvents.add(event);
      currentDate = nextDate;
      eventCount++;
    }

    return repeatEvents;
  }

  Future<void> _saveEvent() async {
    try {
      // Валидация суммы
      final amount = double.tryParse(_amountController.text);
      if (amount == null || amount <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.calendar_invalidAmount),
          ),
        );
        return;
      }

      // Создаем дату и время события
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Получаем текущие события
      final events = await StorageService.getPlannedEvents();
      if (!mounted) return;

      // Определяем, редактируем ли мы существующее событие
      if (widget.editingEvent != null) {
        await _handleEditEvent(events, amount, dateTime);
      } else {
        await _handleCreateEvent(events, amount, dateTime);
      }
    } catch (e) {
      debugPrint('Error saving event: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Обработка редактирования существующего события
  Future<void> _handleEditEvent(
    List<PlannedEvent> events,
    double amount,
    DateTime dateTime,
  ) async {
    final editingEvent = widget.editingEvent!;

    // Определяем область редактирования
    final scope =
        widget.editScope ??
        (_isRepeatingEvent ? EditScope.allRepeating : EditScope.thisEventOnly);

    if (scope == EditScope.thisEventOnly) {
      await _editSingleEvent(events, editingEvent, amount, dateTime);
    } else {
      await _editAllRepeatingEvents(events, editingEvent, amount, dateTime);
    }

    // Показываем уведомление об успешном обновлении
    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.calendar_eventUpdated),
        ),
      );
    }
  }

  /// Редактирование только одного события
  Future<void> _editSingleEvent(
    List<PlannedEvent> events,
    PlannedEvent editingEvent,
    double amount,
    DateTime dateTime,
  ) async {
    // Удаляем старое событие
    events.removeWhere((e) => e.id == editingEvent.id);

    // Отменяем уведомление для старого события
    if (editingEvent.notificationEnabled) {
      await NotificationService.cancelEventNotification(editingEvent.id);
    }

    // Создаем новое событие с обновленными данными
    await _createAndSaveEvent(events, amount, dateTime, editingEvent.id);
  }

  Future<List<Map<String, dynamic>>> _loadLinkedNotes() async {
    if (widget.editingEvent == null) return [];
    await _noteService.init();
    final notes = _noteService.getNotesForEvent(widget.editingEvent!.id);
    return notes.map((note) {
      return {
        'id': note.id,
        'title': note.title,
        'preview': note.content.length > 50
            ? '${note.content.substring(0, 50)}...'
            : note.content,
        'note': note,
      };
    }).toList();
  }

  /// Редактирование всех повторяющихся событий
  Future<void> _editAllRepeatingEvents(
    List<PlannedEvent> events,
    PlannedEvent editingEvent,
    double amount,
    DateTime dateTime,
  ) async {
    // Определяем базовый ID для повторяющихся событий
    final baseId = _isRepeatingEvent && _baseEventId != null
        ? _baseEventId
        : RepeatingEventsHelper.getBaseEventId(editingEvent.id);

    if (baseId == null || baseId.isEmpty) {
      // Не удалось определить baseId - редактируем только это событие
      await _editSingleEvent(events, editingEvent, amount, dateTime);
      return;
    }

    // Находим все связанные события
    final allRelatedEvents = RepeatingEventsHelper.findRelatedEvents(
      events,
      baseId,
    );

    // Проверяем, какие события уже удалены
    final relatedIds = allRelatedEvents.map((e) => e.id).toList();
    final deletedIds = await DeletedEventsService.getDeletedEventIds(
      relatedIds,
    );
    if (!mounted) return;

    // Фильтруем только не удаленные события
    final relatedEvents = allRelatedEvents
        .where((e) => !deletedIds.contains(e.id))
        .toList();

    // Отменяем уведомления для всех найденных событий
    for (var e in relatedEvents) {
      if (e.notificationEnabled) {
        await NotificationService.cancelEventNotification(e.id);
      }
      if (!mounted) return;
    }

    // Удаляем все найденные события из списка
    events.removeWhere((e) => relatedEvents.contains(e));

    // Создаем новое событие с обновленными данными
    await _createAndSaveEvent(events, amount, dateTime);
  }

  /// Обработка создания нового события
  Future<void> _handleCreateEvent(
    List<PlannedEvent> events,
    double amount,
    DateTime dateTime,
  ) async {
    // Создаем новое событие
    await _createAndSaveEvent(events, amount, dateTime);

    // Реакция Бари
    final memory = await StorageService.getBariMemory();
    if (!mounted) return;

    memory.addAction(
      BariAction(
        type: BariActionType.planCreated,
        timestamp: DateTime.now(),
        amount: (amount * 100).toInt(),
      ),
    );
    await StorageService.saveBariMemory(memory);

    // Показываем уведомление о создании
    if (mounted) {
      Navigator.pop(context, true);
      final events = await StorageService.getPlannedEvents();

      if (!mounted) return;

      final baseId = DateTime.now().millisecondsSinceEpoch.toString();
      final relatedEvents = RepeatingEventsHelper.findRelatedEvents(
        events,
        baseId,
      );
      final count = relatedEvents.length;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 1
                ? 'Создано $count повторяющихся событий'
                : 'Событие запланировано',
          ),
        ),
      );
    }
  }

  /// Создает событие с повторениями и сохраняет в хранилище
  Future<void> _createAndSaveEvent(
    List<PlannedEvent> events,
    double amount,
    DateTime dateTime, [
    String? preserveEventId,
  ]) async {
    // Создаем базовое событие
    final baseEvent = PlannedEvent(
      id: preserveEventId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: (amount * 100).toInt(),
      name: _nameController.text.isEmpty ? null : _nameController.text,
      category: _category,
      dateTime: dateTime,
      repeat: _repeat,
      notificationEnabled: _notificationEnabled,
      notificationMinutesBefore: _notificationMinutesBefore,
      source: EventSource.manual,
      autoExecute: _autoExecute,
      linkedNoteIds: _linkedNoteIds,
    );

    // Создаем все повторяющиеся события
    final repeatEvents = _createRepeatEvents(baseEvent);
    events.addAll(repeatEvents);

    // Сохраняем события
    await StorageService.savePlannedEvents(events);

    // Планируем уведомления для всех событий
    for (var event in repeatEvents) {
      if (event.notificationEnabled) {
        await NotificationService.scheduleEventNotification(event);
      }
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingEvent != null
              ? l10n.calendar_editEvent
              : l10n.calendar_planEvent,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Предупреждение о повторяющемся событии
              if (_isRepeatingEvent && _relatedEventsCount > 1)
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AuroraTheme.neonBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.planEvent_repeatingEventWarning,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.planEvent_repeatingEventDescription,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              if (_relatedEventsCount > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Найдено связанных событий: $_relatedEventsCount',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_isRepeatingEvent && _relatedEventsCount > 1)
                const SizedBox(height: 16),
              AuroraTheme.glassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.planEvent_eventType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<TransactionType>(
                        segments: [
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text(l10n.transaction_income),
                          ),
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text(l10n.transaction_expense),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged:
                            (Set<TransactionType> newSelection) {
                              setState(() {
                                _type = newSelection.first;
                              });
                            },
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.planEvent_amount,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.planEvent_nameOptional,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: InputDecoration(
                          labelText: l10n.planEvent_category,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'food',
                            child: Text(l10n.category_food),
                          ),
                          DropdownMenuItem(
                            value: 'transport',
                            child: Text(l10n.category_transport),
                          ),
                          DropdownMenuItem(
                            value: 'entertainment',
                            child: Text(l10n.category_entertainment),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text(l10n.category_other),
                          ),
                        ],
                        onChanged: (value) => setState(() => _category = value),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: Text(
                          l10n.planEvent_date,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          LocalizedDateFormatter.formatDateShort(
                            context,
                            _selectedDate,
                          ),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: _selectDate,
                      ),
                      ListTile(
                        title: Text(
                          l10n.planEvent_time,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: _selectTime,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.planEvent_repeat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<RepeatType>(
                        segments: [
                          ButtonSegment(
                            value: RepeatType.none,
                            label: Text(
                              l10n.calendar_noRepeat,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ButtonSegment(
                            value: RepeatType.daily,
                            label: Text(
                              l10n.calendar_everyDay,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ButtonSegment(
                            value: RepeatType.weekly,
                            label: Text(
                              l10n.calendar_everyWeek,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          ButtonSegment(
                            value: RepeatType.monthly,
                            label: Text(
                              l10n.calendar_everyMonth,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        selected: {_repeat},
                        onSelectionChanged: (Set<RepeatType> newSelection) {
                          setState(() {
                            _repeat = newSelection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: Text(
                          l10n.planEvent_notification,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: _notificationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationEnabled = value;
                          });
                        },
                      ),
                      if (_notificationEnabled) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _notificationMinutesBefore,
                          decoration: InputDecoration(
                            labelText: l10n.planEvent_remindBefore,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(l10n.planEvent_atMoment),
                            ),
                            DropdownMenuItem(
                              value: 15,
                              child: Text(l10n.planEvent_15minutes),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text(l10n.planEvent_30minutes),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text(l10n.planEvent_1hour),
                            ),
                            DropdownMenuItem(
                              value: 1440,
                              child: Text(l10n.planEvent_1day),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _notificationMinutesBefore = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      SwitchListTile(
                        title: const Text(
                          'Автоматически выполнить при наступлении даты',
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Сумма будет автоматически добавлена или вычтена из баланса',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        value: _autoExecute,
                        onChanged: (value) {
                          setState(() {
                            _autoExecute = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Связанные заметки
              if (widget.editingEvent != null)
                AuroraTheme.glassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Связанные заметки',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add,
                                color: AuroraTheme.neonBlue,
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NoteEditorScreen(),
                                  ),
                                );
                                if (result == true && mounted) {
                                  setState(() {});
                                }
                              },
                              tooltip: 'Создать заметку',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _loadLinkedNotes(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AuroraTheme.neonBlue,
                                ),
                              );
                            }
                            final notes = snapshot.data ?? [];
                            if (notes.isEmpty) {
                              return const Text(
                                'Нет связанных заметок',
                                style: TextStyle(color: Colors.white70),
                              );
                            }
                            return Column(
                              children: notes.map((note) {
                                return ListTile(
                                  title: Text(
                                    note['title'] ?? 'Без названия',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    note['preview'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () async {
                                      await _noteService.unlinkNoteFromEvent(
                                        note['id'] as String,
                                      );
                                      setState(() {
                                        _linkedNoteIds.remove(note['id']);
                                      });
                                    },
                                  ),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NoteEditorScreen(
                                          note: note['note'],
                                        ),
                                      ),
                                    );
                                    if (result == true && mounted) {
                                      setState(() {});
                                    }
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotesScreen(),
                              ),
                            );
                            if (result != null && mounted) {
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.note_add),
                          label: const Text('Просмотреть все заметки'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (widget.editingEvent != null) const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.common_cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveEvent,
                      child: Text(l10n.common_save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
