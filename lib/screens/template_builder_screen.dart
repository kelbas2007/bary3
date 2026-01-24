import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/template_config.dart';
import '../models/note.dart';
import '../models/piggy_bank.dart';
import '../models/planned_event.dart';
import '../services/note_service.dart';
import '../services/storage_service.dart';
import '../state/planned_events_notifier.dart';
import '../bari_smart/bari_context_adapter.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import 'note_editor_screen.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  final TemplateConfig config;
  final String templateTitle;
  final IconData templateIcon;
  final Color templateColor;

  const TemplateBuilderScreen({
    super.key,
    required this.config,
    required this.templateTitle,
    required this.templateIcon,
    required this.templateColor,
  });

  @override
  ConsumerState<TemplateBuilderScreen> createState() =>
      _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState
    extends ConsumerState<TemplateBuilderScreen> {
  final Map<String, dynamic> _params = {};
  bool _isGenerating = false;
  String? _bariHint;

  @override
  void initState() {
    super.initState();
    // Инициализируем значения по умолчанию
    for (var param in widget.config.parameters) {
      if (param.defaultValue != null) {
        _params[param.id] = param.defaultValue;
      }
    }
    _loadBariHint();
  }

  Future<void> _loadBariHint() async {
    if (widget.config.bariHintBuilder == null) return;

    try {
      final l10n = AppLocalizations.of(context)!;
      final ctx = await BariContextAdapter.build(
        currentScreenId: 'template_builder',
      );
      final hint = await widget.config.bariHintBuilder!(l10n, _params, ctx);
      if (hint != null && mounted) {
        setState(() {
          _bariHint = hint;
        });
      }
    } catch (e) {
      debugPrint('Error loading Bari hint: $e');
    }
  }

  Future<void> _generateNote() async {
    if (!_validateParams()) {
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final l10n = AppLocalizations.of(context)!;
      final content = await widget.config.contentBuilder(l10n, _params);

      if (!mounted) return;

      // Создаем заметку
      final noteService = NoteService();
      final note = await noteService.createNote(
        title: widget.templateTitle,
        content: content,
        type: NoteType.rich,
        color: widget.templateColor,
        tags: [widget.config.templateId],
      );

      // Привязываем к дате, если указана
      if (_params.containsKey('date') && _params['date'] != null) {
        final date = _params['date'] as DateTime;
        await noteService.updateNote(
          note.copyWith(
            createdAt: date,
            calendarEventId: 'temp_${note.id}', // Временный ID, будет заменен при синхронизации
          ),
        );
      }

      // Привязываем к событию, если выбрано
      if (_params.containsKey('event') && _params['event'] != null) {
        final event = _params['event'] as PlannedEvent;
        await noteService.linkNoteToEvent(note.id, event.id);
      }

      if (!mounted) return;

      // Открываем редактор
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(note: note),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.templateBuilder_createError(e.toString())),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  bool _validateParams() {
    for (var param in widget.config.parameters) {
      if (param.required && !_params.containsKey(param.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Пожалуйста, заполните поле: ${param.label(AppLocalizations.of(context)!)}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_bariHint != null)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline,
                  color: AuroraTheme.neonYellow),
              onPressed: () => _showBariHint(context),
              tooltip: l10n.notes_bariTip,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.templateColor.withValues(alpha: 0.3),
              AuroraTheme.spaceBlue,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Подсказка от Бари
                    if (_bariHint != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AuroraTheme.neonYellow.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AuroraTheme.neonYellow.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb,
                                color: AuroraTheme.neonYellow, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _bariHint!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Параметры
                    ...widget.config.parameters.map((param) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildParameterField(param, l10n),
                        )),
                  ],
                ),
              ),
            ),
            // Кнопка создания
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AuroraTheme.spaceBlue.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.templateColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isGenerating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Создать заметку',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterField(
      TemplateParameter param, AppLocalizations l10n) {
    switch (param.type) {
      case ParameterType.text:
        return _buildTextField(param, l10n);
      case ParameterType.number:
      case ParameterType.amount:
        return _buildNumberField(param, l10n);
      case ParameterType.date:
        return _buildDateField(param, l10n);
      case ParameterType.select:
        return _buildSelectField(param, l10n);
      case ParameterType.multiSelect:
        return _buildMultiSelectField(param, l10n);
      case ParameterType.checkbox:
        return _buildCheckboxField(param, l10n);
      case ParameterType.piggyBank:
        return _buildPiggyBankField(param, l10n);
      case ParameterType.event:
        return _buildEventField(param, l10n);
    }
  }

  Widget _buildTextField(TemplateParameter param, AppLocalizations l10n) {
    return TextField(
      decoration: InputDecoration(
        labelText: param.label(l10n),
        hintText: param.hint?.call(l10n),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.templateColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          _params[param.id] = value.isEmpty ? null : value;
        });
        _loadBariHint();
      },
      controller: TextEditingController(
        text: _params[param.id]?.toString() ?? '',
      ),
    );
  }

  Widget _buildNumberField(TemplateParameter param, AppLocalizations l10n) {
    final isAmount = param.type == ParameterType.amount;
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: param.label(l10n),
        hintText: param.hint?.call(l10n),
        suffixText: isAmount ? 'руб.' : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.templateColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        final num = isAmount
            ? (double.tryParse(value) ?? 0) * 100 // Конвертируем в центы
            : (int.tryParse(value) ?? 0);
        setState(() {
          _params[param.id] = num;
        });
        _loadBariHint();
      },
      controller: TextEditingController(
        text: isAmount
            ? (_params[param.id] != null
                ? ((_params[param.id] as int) / 100).toStringAsFixed(0)
                : '')
            : (_params[param.id]?.toString() ?? ''),
      ),
    );
  }

  Widget _buildDateField(TemplateParameter param, AppLocalizations l10n) {
    final selectedDate = _params[param.id] as DateTime?;
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          locale: const Locale('ru', 'RU'),
        );
        if (date != null) {
          setState(() {
            _params[param.id] = date;
          });
          _loadBariHint();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: widget.templateColor.withValues(alpha: 0.8)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    param.label(l10n),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedDate != null
                        ? DateFormat('dd MMMM yyyy', 'ru').format(selectedDate)
                        : param.hint?.call(l10n) ?? 'Выберите дату',
                    style: TextStyle(
                      color: selectedDate != null
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectField(TemplateParameter param, AppLocalizations l10n) {
    final selected = _params[param.id];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButton<dynamic>(
        value: selected,
        hint: Text(
          param.label(l10n),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        isExpanded: true,
        dropdownColor: AuroraTheme.spaceBlue,
        style: const TextStyle(color: Colors.white),
        items: param.options?.map((option) {
          return DropdownMenuItem<dynamic>(
            value: option,
            child: Text(
              param.formatValue?.call(l10n, option) ?? option.toString(),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _params[param.id] = value;
          });
          _loadBariHint();
        },
      ),
    );
  }

  Widget _buildMultiSelectField(
      TemplateParameter param, AppLocalizations l10n) {
    final selected = (_params[param.id] as List<dynamic>?) ?? [];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            param.label(l10n),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (param.options ?? []).map((option) {
              final isSelected = selected.contains(option);
              return FilterChip(
                label: Text(
                  param.formatValue?.call(l10n, option) ?? option.toString(),
                ),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    final list = List<dynamic>.from(selected);
                    if (value) {
                      list.add(option);
                    } else {
                      list.remove(option);
                    }
                    _params[param.id] = list;
                  });
                  _loadBariHint();
                },
                selectedColor: widget.templateColor,
                checkmarkColor: Colors.white,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxField(TemplateParameter param, AppLocalizations l10n) {
    final value = _params[param.id] as bool? ?? false;
    return CheckboxListTile(
      title: Text(
        param.label(l10n),
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: param.hint != null
          ? Text(
              param.hint!(l10n),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            )
          : null,
      value: value,
      onChanged: (newValue) {
        setState(() {
          _params[param.id] = newValue ?? false;
        });
        _loadBariHint();
      },
      activeColor: widget.templateColor,
    );
  }

  Widget _buildPiggyBankField(
      TemplateParameter param, AppLocalizations l10n) {
    return FutureBuilder<List<PiggyBank>>(
      future: StorageService.getPiggyBanks(),
      builder: (context, snapshot) {
        final banks = snapshot.data ?? [];
        if (banks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Нет доступных копилок',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          );
        }

        final selected = _params[param.id] as String?;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: DropdownButton<String>(
            value: selected,
            hint: Text(
              param.label(l10n),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
            isExpanded: true,
            dropdownColor: AuroraTheme.spaceBlue,
            style: const TextStyle(color: Colors.white),
            items: banks.map((bank) {
              return DropdownMenuItem<String>(
                value: bank.id,
                child: Text('${bank.name} (${_formatMoney(bank.currentAmount)})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _params[param.id] = value;
              });
              _loadBariHint();
            },
          ),
        );
      },
    );
  }

  Widget _buildEventField(TemplateParameter param, AppLocalizations l10n) {
    final eventsAsync = ref.watch(plannedEventsProvider);
    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Нет доступных событий',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          );
        }

        final selected = _params[param.id] as String?;
        final selectedEvent = events.firstWhere(
          (e) => e.id == selected,
          orElse: () => events.first,
        );

        return InkWell(
          onTap: () async {
            final event = await showDialog<PlannedEvent>(
              context: context,
              builder: (context) => _EventPickerDialog(events: events),
            );
            if (event != null) {
              setState(() {
                _params[param.id] = event.id;
              });
              _loadBariHint();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: widget.templateColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        param.label(l10n),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selected != null
                            ? '${selectedEvent.name ?? "Событие"} - ${DateFormat("dd.MM.yyyy", "ru").format(selectedEvent.dateTime)}'
                            : 'Выберите событие',
                        style: TextStyle(
                          color: selected != null
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Ошибка загрузки событий',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  void _showBariHint(BuildContext context) {
    if (_bariHint == null) return;
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
          _bariHint!,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _formatMoney(int cents) {
    final rubles = cents / 100;
    if (rubles == rubles.toInt()) {
      return '${rubles.toInt()} руб.';
    }
    return '${rubles.toStringAsFixed(2)} руб.';
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
      title: Text(l10n.notes_selectEvent,
          style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ListTile(
              title: Text(event.name ?? l10n.common_plan,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                '${DateFormat.yMd(l10n.localeName).format(event.dateTime)} - ${event.type.toString().split('.').last}',
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
          child: Text(l10n.common_cancel,
              style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
