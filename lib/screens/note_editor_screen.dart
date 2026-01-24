import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/note_template.dart';
import '../models/planned_event.dart';
import '../models/transaction.dart';
import '../services/note_service.dart';
import '../services/storage_service.dart';
import '../state/planned_events_notifier.dart';
import '../bari_smart/bari_smart.dart';
import '../bari_smart/bari_context_adapter.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note? note;
  final NoteTemplate? template;

  const NoteEditorScreen({super.key, this.note, this.template});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late final TextEditingController _titleController;
  late QuillController _quillController;
  late final NoteService _noteService;
  late Note _currentNote;
  bool _isEditing = false;
  bool _isSaving = false;
  final bool _autoSaveEnabled = true;
  Timer? _autoSaveTimer;
  final ImagePicker _imagePicker = ImagePicker();
  String? _bariTip;
  bool _showPreview = false;
  bool _controllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _noteService = NoteService();
    
    // Инициализируем базовую заметку без локализации
    _currentNote =
        widget.note ??
        Note(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: '',
          content: '',
          createdAt: DateTime.now(),
        );
    
    _isEditing = widget.note != null;
    _titleController = TextEditingController(text: _currentNote.title);
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_controllerInitialized) return;
    
    // Если есть шаблон и заметка еще не инициализирована из шаблона, инициализируем
    if (widget.template != null && !_isEditing && _currentNote.title.isEmpty) {
      _initializeFromTemplate();
    }

    // Parse content for Quill
    final contentJson = _parseContent(_currentNote.content);
    final document = Document.fromJson(contentJson);
    
    // Дополнительная проверка: убеждаемся, что документ заканчивается на \n
    _ensureDocumentEndsWithNewline(document);
    
    // Инициализируем контроллер
    _quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );
    
    _controllerInitialized = true;
    
    // Загружаем подсказку от Бари
    _loadBariTip();
    
    // Настраиваем автосохранение
    _setupAutoSave();
  }
  
  Future<void> _initializeFromTemplate() async {
    final l10n = AppLocalizations.of(context)!;
    final template = widget.template!;
    
    // Для шаблона отчета для родителей загружаем данные
    String content;
    if (template.id == 'parent_report') {
      content = await _generateParentReport(l10n);
    } else {
      content = template.contentBuilder(l10n);
    }
    
    _currentNote = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: template.title(l10n),
      content: content,
      createdAt: DateTime.now(),
      color: template.color,
      tags: [template.id],
    );
    _titleController.text = _currentNote.title;
  }
  
  Future<String> _generateParentReport(AppLocalizations l10n) async {
    try {
      final transactions = await StorageService.getTransactions();
      final events = await StorageService.getPlannedEvents();
      final progress = await StorageService.getLessonProgress();
      final profile = await StorageService.getPlayerProfile();
      
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekAgo = today.subtract(const Duration(days: 7));
      final monthAgo = DateTime(now.year, now.month - 1, now.day);
      
      // Фильтруем транзакции за разные периоды
      final todayTx = transactions.where((t) => 
        t.date.isAfter(today.subtract(const Duration(days: 1))) &&
        t.parentApproved && t.affectsWallet
      ).toList();
      
      final weekTx = transactions.where((t) => 
        t.date.isAfter(weekAgo) &&
        t.parentApproved && t.affectsWallet
      ).toList();
      
      final monthTx = transactions.where((t) => 
        t.date.isAfter(monthAgo) &&
        t.parentApproved && t.affectsWallet
      ).toList();
      
      // Подсчитываем суммы
      int calculateTotal(List<Transaction> transactions, TransactionType type) {
        return transactions
            .where((t) => t.type == type)
            .fold<int>(0, (sum, t) => sum + t.amount);
      }
      
      final todayIncome = calculateTotal(todayTx, TransactionType.income);
      final todayExpense = calculateTotal(todayTx, TransactionType.expense);
      final weekIncome = calculateTotal(weekTx, TransactionType.income);
      final weekExpense = calculateTotal(weekTx, TransactionType.expense);
      final monthIncome = calculateTotal(monthTx, TransactionType.income);
      final monthExpense = calculateTotal(monthTx, TransactionType.expense);
      
      // Подсчитываем активность
      final completedPlans = events.where((e) => 
        e.status == PlannedEventStatus.completed
      ).length;
      final completedLessons = progress.where((p) => p.completed).length;
      
      // Форматируем суммы
      String formatAmount(int cents) => '${(cents / 100).toStringAsFixed(2)} руб.';
      
      return '''📊 Отчет для родителей

📅 Дата отчета: ${DateFormat('dd.MM.yyyy').format(now)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📈 ЗА СЕГОДНЯ:
💰 Доходы: ${formatAmount(todayIncome)}
💸 Расходы: ${formatAmount(todayExpense)}
💵 Баланс: ${formatAmount(todayIncome - todayExpense)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 ЗА НЕДЕЛЮ:
💰 Доходы: ${formatAmount(weekIncome)}
💸 Расходы: ${formatAmount(weekExpense)}
💵 Баланс: ${formatAmount(weekIncome - weekExpense)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📆 ЗА МЕСЯЦ:
💰 Доходы: ${formatAmount(monthIncome)}
💸 Расходы: ${formatAmount(monthExpense)}
💵 Баланс: ${formatAmount(monthIncome - monthExpense)}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 АКТИВНОСТЬ:
✅ Завершено планов: $completedPlans из ${events.length}
📚 Пройдено уроков: $completedLessons
🔥 Серия дней: ${profile.streakDays} дней
💪 Самоконтроль: ${profile.selfControlScore}/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 ВЫВОДЫ:
${_generateInsights(weekIncome, weekExpense, monthIncome, monthExpense, completedPlans, completedLessons)}

📝 КОММЕНТАРИИ РОДИТЕЛЯ:
''';
    } catch (e) {
      return '''📊 Отчет для родителей

📅 Дата: _____

💰 ФИНАНСОВАЯ СВОДКА:
• Доходы: _____ руб.
• Расходы: _____ руб.
• Баланс: _____ руб.

📈 АКТИВНОСТЬ:
• Завершено планов: _____
• Пройдено уроков: _____

💡 ВЫВОДЫ И РЕКОМЕНДАЦИИ:
''';
    }
  }
  
  String _generateInsights(int weekIncome, int weekExpense, int monthIncome, int monthExpense, int plans, int lessons) {
    final insights = <String>[];
    
    if (weekExpense > weekIncome) {
      insights.add('⚠️ За неделю расходы превысили доходы');
    } else if (weekIncome > 0) {
      final savingsRate = ((weekIncome - weekExpense) / weekIncome * 100).toStringAsFixed(1);
      insights.add('✅ Накоплено $savingsRate% от доходов за неделю');
    }
    
    if (monthExpense > monthIncome) {
      insights.add('⚠️ За месяц расходы превысили доходы');
    } else if (monthIncome > 0) {
      final savingsRate = ((monthIncome - monthExpense) / monthIncome * 100).toStringAsFixed(1);
      insights.add('✅ Накоплено $savingsRate% от доходов за месяц');
    }
    
    if (plans > 0) {
      insights.add('✅ Выполнено $plans планов - отличная дисциплина!');
    }
    
    if (lessons > 0) {
      insights.add('📚 Пройдено $lessons уроков - продолжайте в том же духе!');
    }
    
    return insights.isEmpty ? 'Все идет хорошо!' : insights.join('\n');
  }
  
  void _setupAutoSave() {
    _titleController.addListener(_onContentChanged);
    _quillController.addListener(_onContentChanged);
  }
  
  void _onContentChanged() {
    if (!_autoSaveEnabled || _isSaving) return;
    
    // Отменяем предыдущий таймер
    _autoSaveTimer?.cancel();
    
    // Устанавливаем новый таймер на 3 секунды
    _autoSaveTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && !_isSaving) {
        _autoSave();
      }
    });
  }
  
  Future<void> _autoSave() async {
    if (_isSaving || !mounted) return;
    
    final title = _titleController.text.trim();
    if (title.isEmpty) return; // Не сохраняем заметки без заголовка
    
    try {
      _ensureDocumentEndsWithNewline(_quillController.document);
      final content = _quillController.document.toDelta().toJson().toString();
      
      final updatedNote = _currentNote.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );
      
      if (_isEditing) {
        await _noteService.updateNote(updatedNote);
        _currentNote = updatedNote;
      } else {
        // Для новых заметок создаем их при первом автосохранении
        if (_currentNote.id.isEmpty || _currentNote.id == '0') {
          final createdNote = await _noteService.createNote(
            title: title,
            content: content,
            type: NoteType.rich,
            color: _currentNote.color,
            tags: _currentNote.tags,
            linkedEventId: _currentNote.linkedEventId,
          );
          _currentNote = createdNote;
          _isEditing = true;
        } else {
          await _noteService.updateNote(updatedNote);
          _currentNote = updatedNote;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notes_autoSave),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }
  }
  
  Future<void> _loadBariTip() async {
    try {
      final ctx = await BariContextAdapter.build(
        currentScreenId: 'notes_editor',
      );
      
      final bariSmart = BariSmart.instance;
      await bariSmart.init();
      final response = await bariSmart.respond(
        'Дай совет по созданию заметки',
        ctx,
      );
      
      if (mounted) {
        setState(() {
          _bariTip = '${response.meaning}\n\n${response.advice}';
        });
      }
    } catch (e) {
      debugPrint('Error loading Bari tip: $e');
    }
  }

  /// Убеждается, что документ Quill заканчивается на символ новой строки
  void _ensureDocumentEndsWithNewline(Document document) {
    try {
      final delta = document.toDelta();
      if (delta.isEmpty) {
        document.insert(0, '\n');
        return;
      }
      
      // Проверяем последнюю операцию в Delta
      final lastOp = delta.last;
      if (lastOp.data is String) {
        final lastData = lastOp.data as String;
        if (!lastData.endsWith('\n')) {
          // Если последний элемент не заканчивается на \n, добавляем его в конец
          document.insert(document.length, '\n');
        }
      } else {
        // Если последний элемент не строка, добавляем \n
        document.insert(document.length, '\n');
      }
    } catch (e) {
      // В случае ошибки просто добавляем \n в конец
      document.insert(document.length, '\n');
    }
  }

  List<dynamic> _parseContent(String content) {
    try {
      if (content.isEmpty) {
        return [
          {'insert': '\n'},
        ];
      }
      // Try to parse as JSON
      final parsed = jsonDecode(content);
      if (parsed is List && parsed.isNotEmpty) {
        // Убеждаемся, что последний элемент заканчивается на \n
        final result = List<dynamic>.from(parsed);
        final lastItem = result.last;
        if (lastItem is Map<String, dynamic> && lastItem.containsKey('insert')) {
          final lastData = lastItem['insert'];
          if (lastData is String && !lastData.endsWith('\n')) {
            // Если последний элемент не заканчивается на \n, добавляем его
            result[result.length - 1] = {
              ...lastItem,
              'insert': '$lastData\n',
            };
          } else if (lastData is! String) {
            // Если последний элемент не строка, добавляем новый элемент с \n
            result.add({'insert': '\n'});
          }
        } else {
          // Если последний элемент не имеет 'insert', добавляем \n
          result.add({'insert': '\n'});
        }
        return result;
      }
      // If parsing fails, treat as plain text
      return [
        {'insert': '$content\n'},
      ];
    } catch (e) {
      // If parsing fails, treat as plain text
      return [
        {'insert': '$content\n'},
      ];
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.removeListener(_onContentChanged);
    _quillController.removeListener(_onContentChanged);
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;
    
    // Отменяем автосохранение перед ручным сохранением
    _autoSaveTimer?.cancel();

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showError(AppLocalizations.of(context)!.notes_titleRequired);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Убеждаемся, что документ заканчивается на \n перед сохранением
      _ensureDocumentEndsWithNewline(_quillController.document);
      
      final content = _quillController.document.toDelta().toJson().toString();
      final updatedNote = _currentNote.copyWith(
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      );

      if (_isEditing) {
        await _noteService.updateNote(updatedNote);
      } else {
        final createdNote = await _noteService.createNote(
          title: title,
          content: content,
          type: NoteType.rich,
          color: _currentNote.color,
          tags: _currentNote.tags,
          linkedEventId: _currentNote.linkedEventId,
        );
        _currentNote = createdNote;
        _isEditing = true;
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showError('Ошибка сохранения: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  Future<void> _linkToEvent() async {
    final eventsAsync = ref.read(plannedEventsProvider);
    
    final events = await eventsAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(<PlannedEvent>[]),
      error: (_, _) => Future.value(<PlannedEvent>[]),
    );
    
    if (events.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notes_noEvents),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    if (!mounted) return;
    
    final selectedEvent = await showDialog<PlannedEvent>(
      context: context,
      builder: (context) => _EventPickerDialog(events: events),
    );
    
    if (selectedEvent != null && mounted) {
      await _noteService.linkNoteToEvent(_currentNote.id, selectedEvent.id);
      if (!mounted) return;
      setState(() {
        _currentNote = _currentNote.copyWith(linkedEventId: selectedEvent.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notes_linkedToEvent),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  Future<void> _unlinkFromEvent() async {
    if (_currentNote.linkedEventId == null) return;
    
    await _noteService.unlinkNoteFromEvent(_currentNote.id);
    if (!mounted) return;
    setState(() {
      _currentNote = _currentNote.copyWith(clearLinkedEventId: true);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.notes_unlinkFromEvent),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
  
  Future<void> _linkToCalendarDate() async {
    if (_currentNote.calendarEventId != null) {
      // Отвязываем от даты
      await _noteService.updateNote(
        _currentNote.copyWith(clearCalendarEventId: true),
      );
      if (!mounted) return;
      setState(() {
        _currentNote = _currentNote.copyWith(clearCalendarEventId: true);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noteEditor_unlinkedFromDate),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return;
    }
    
    // Выбираем дату
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _currentNote.createdAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('ru', 'RU'),
    );
    
    if (selectedDate != null && mounted) {
      // Обновляем дату создания заметки и привязываем к календарю
      await _noteService.updateNote(
        _currentNote.copyWith(
          createdAt: selectedDate,
          calendarEventId: 'calendar_${_currentNote.id}',
        ),
      );
      if (!mounted) return;
      setState(() {
        _currentNote = _currentNote.copyWith(
          createdAt: selectedDate,
          calendarEventId: 'calendar_${_currentNote.id}',
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Заметка привязана к дате: ${DateFormat('dd MMMM yyyy', 'ru').format(selectedDate)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  Future<void> _shareNote() async {
    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText();
    
    final text = '$title\n\n$content';
    
    // Используем mailto для шаринга (работает на всех платформах)
    final uri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': title,
        'body': text,
      },
    );
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback: копируем в буфер обмена
        await Clipboard.setData(ClipboardData(text: text));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.notes_copied),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Fallback: копируем в буфер обмена
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.notes_copied),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
  
  void _togglePreview() {
    setState(() {
      _showPreview = !_showPreview;
    });
  }
  
  void _showBariTip(BuildContext context) {
    if (_bariTip == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Row(
          children: [
            const Icon(Icons.lightbulb, color: AuroraTheme.neonYellow),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.notes_bariTip,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          _bariTip!,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.common_done),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showColorPicker() {
    final colors = [
      Colors.transparent,
      AuroraTheme.neonBlue.withValues(alpha: 0.6),
      AuroraTheme.neonPurple.withValues(alpha: 0.6),
      AuroraTheme.neonMint.withValues(alpha: 0.6),
      AuroraTheme.neonYellow.withValues(alpha: 0.6),
      Colors.redAccent.withValues(alpha: 0.6),
      Colors.green.withValues(alpha: 0.6),
      Colors.orange.withValues(alpha: 0.6),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AuroraTheme.spaceBlue,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.notes_selectColor,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentNote = _currentNote.copyWith(color: color);
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _currentNote.color == color
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentNote = _currentNote.copyWith(clearColor: true);
                });
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.notes_clearColor,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addImageAttachment() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final attachment = await _noteService.addImageAttachment(
          _currentNote.id,
          image,
        );
        setState(() {
          _currentNote = _currentNote.copyWith(
            attachments: [..._currentNote.attachments, attachment],
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noteEditor_imageAdded),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noteEditor_imageError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _addFileAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final attachment = await _noteService.addFileAttachment(
          _currentNote.id,
          file,
        );
        setState(() {
          _currentNote = _currentNote.copyWith(
            attachments: [..._currentNote.attachments, attachment],
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.noteEditor_fileAdded),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noteEditor_fileError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showTagEditor() {
    final tagController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          AppLocalizations.of(context)!.notes_editTags,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tagController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.notes_tagHint,
                hintStyle: const TextStyle(color: Colors.white54),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _currentNote = _currentNote.copyWith(
                      tags: [..._currentNote.tags, value.trim()],
                    );
                  });
                  tagController.clear();
                }
              },
            ),
            const SizedBox(height: 16),
            if (_currentNote.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentNote.tags.map((tag) {
                  return Chip(
                    label: Text(
                      tag,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AuroraTheme.neonBlue.withValues(
                      alpha: 0.2,
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white70,
                    ),
                    onDeleted: () {
                      setState(() {
                        _currentNote = _currentNote.copyWith(
                          tags: _currentNote.tags
                              .where((t) => t != tag)
                              .toList(),
                        );
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.common_done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.notes_edit : l10n.notes_create),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_bariTip != null)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => _showBariTip(context),
              tooltip: l10n.notes_bariTip,
            ),
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.preview),
            onPressed: _togglePreview,
            tooltip: l10n.notes_preview,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareNote,
            tooltip: l10n.notes_share,
          ),
          // Кнопка привязки к дате в календаре
          IconButton(
            icon: Icon(_currentNote.calendarEventId != null
                ? Icons.calendar_today
                : Icons.calendar_today_outlined),
            onPressed: _linkToCalendarDate,
            tooltip: _currentNote.calendarEventId != null
                ? 'Отвязать от даты'
                : 'Привязать к дате в календаре',
          ),
          // Кнопка привязки к событию
          IconButton(
            icon: Icon(_currentNote.linkedEventId != null 
                ? Icons.event_available 
                : Icons.event),
            onPressed: _currentNote.linkedEventId != null 
                ? _unlinkFromEvent 
                : _linkToEvent,
            tooltip: _currentNote.linkedEventId != null 
                ? l10n.notes_unlinkFromEvent 
                : l10n.notes_linkToEvent,
          ),
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: _showColorPicker,
            tooltip: l10n.notes_changeColor,
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: _showTagEditor,
            tooltip: l10n.notes_editTags,
          ),
          IconButton(
            icon: _isSaving
                ? const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveNote,
            tooltip: l10n.common_save,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _currentNote.color ?? AuroraTheme.spaceBlue,
              AuroraTheme.spaceBlue,
            ],
          ),
        ),
        child: Column(
          children: [
            // Title field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: l10n.notes_titleHint,
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 2,
              ),
            ),
            // Attachments section
            if (_currentNote.attachments.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Вложения (${_currentNote.attachments.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentNote.attachments.map((attachment) {
                        return Chip(
                          label: Text(
                            attachment.fileName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white,
                          ),
                          onDeleted: () async {
                            await _noteService.removeAttachment(
                              _currentNote.id,
                              attachment.id,
                            );
                            setState(() {
                              _currentNote = _currentNote.copyWith(
                                attachments: _currentNote.attachments
                                    .where((a) => a.id != attachment.id)
                                    .toList(),
                              );
                            });
                          },
                          backgroundColor: AuroraTheme.neonBlue.withValues(
                            alpha: 0.3,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            if (_currentNote.attachments.isNotEmpty) const SizedBox(height: 8),
            // Quill editor or Preview
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: _showPreview ? _buildPreview() : _buildEditor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEditor() {
    return Column(
      children: [
        // Auto-save indicator
        if (_autoSaveEnabled && _autoSaveTimer != null && _autoSaveTimer!.isActive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: Colors.blue.withValues(alpha: 0.2),
            child: Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.notes_autoSave,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        // Toolbar with attachments button
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AuroraTheme.spaceBlue.withValues(alpha: 0.8),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.format_bold,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  _quillController.formatSelection(Attribute.bold);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_italic,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  _quillController.formatSelection(
                    Attribute.italic,
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_underlined,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  _quillController.formatSelection(
                    Attribute.underline,
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  _quillController.formatSelection(Attribute.ul);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.format_list_numbered,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: () {
                  _quillController.formatSelection(Attribute.ol);
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.image,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: _addImageAttachment,
                tooltip: 'Добавить изображение',
              ),
              IconButton(
                icon: const Icon(
                  Icons.attach_file,
                  size: 20,
                  color: Colors.white,
                ),
                onPressed: _addFileAttachment,
                tooltip: 'Добавить файл',
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: QuillEditor(
              controller: _quillController,
              focusNode: FocusNode(),
              scrollController: ScrollController(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPreview() {
    final content = _quillController.document.toPlainText();
    final title = _titleController.text.trim();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_currentNote.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _currentNote.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: AuroraTheme.neonBlue.withValues(alpha: 0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (_currentNote.linkedEventId != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.notes_linkedToEvent,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventPickerDialog extends StatelessWidget {
  final List<PlannedEvent> events;

  const _EventPickerDialog({required this.events});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AlertDialog(
      backgroundColor: AuroraTheme.spaceBlue,
      title: Text(
        l10n.notes_selectEvent,
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: events.isEmpty
            ? Text(
                l10n.notes_noEvents,
                style: const TextStyle(color: Colors.white70),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    title: Text(
                      event.name ?? 'Событие ${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${event.amount / 100} руб. • ${event.dateTime.toString().substring(0, 16)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => Navigator.pop(context, event),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}
