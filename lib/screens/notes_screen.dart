import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../models/note_template.dart';
import '../services/note_service.dart';
import '../theme/aurora_theme.dart';
import '../l10n/app_localizations.dart';
import 'note_editor_screen.dart';
import 'parent_report_builder_screen.dart';
import 'template_builder_screen.dart';
import '../models/enhanced_templates.dart';

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final service = NoteService();
  await service.init();
  return service.notes.value;
});

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  NoteViewMode _viewMode = NoteViewMode.grid;
  NoteFilter _currentFilter = NoteFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteEditor({Note? note, NoteTemplate? template}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          template: template,
        ),
      ),
    ).then((_) {
      // ignore: unused_result
      ref.refresh(notesProvider);
    });
  }

  void _showTemplatesDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templates = NoteTemplates.getTemplates();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AuroraTheme.spaceBlue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  l10n.notes_templates,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Scrollable grid
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final template = templates[index];
                    // Для шаблона отчета для родителей открываем специальный экран
                    if (template.id == 'parent_report') {
                      return _TemplateCard(
                        template: template,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ParentReportBuilderScreen(),
                            ),
                          );
                        },
                      );
                    }
                    
                    // Проверяем, есть ли улучшенная конфигурация для этого шаблона
                    final enhancedConfigs = EnhancedTemplates.getTemplateConfigs();
                    final enhancedConfig = enhancedConfigs.firstWhere(
                      (c) => c.templateId == template.id,
                      orElse: () => enhancedConfigs.first, // fallback
                    );
                    
                    // Если есть улучшенная конфигурация, используем её
                    if (enhancedConfigs.any((c) => c.templateId == template.id)) {
                      return _TemplateCard(
                        template: template,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateBuilderScreen(
                                config: enhancedConfig,
                                templateTitle: template.title(l10n),
                                templateIcon: template.icon,
                                templateColor: template.color,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    
                    // Иначе используем простой шаблон
                    return _TemplateCard(
                      template: template,
                      onTap: () {
                        Navigator.pop(context);
                        _openNoteEditor(template: template);
                      },
                    );
                  },
                ),
              ),
              // Cancel button
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.common_cancel,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AuroraTheme.spaceBlue,
        title: Text(
          AppLocalizations.of(context)!.notes_deleteConfirm,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          AppLocalizations.of(context)!.notes_deleteMessage(note.title),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.common_cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(AppLocalizations.of(context)!.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = NoteService();
      await service.deleteNote(note.id);
      // ignore: unused_result
      ref.refresh(notesProvider);
    }
  }

  void _togglePin(Note note) async {
    final service = NoteService();
    await service.togglePin(note.id);
    // ignore: unused_result
    ref.refresh(notesProvider);
  }

  void _toggleArchive(Note note) async {
    final service = NoteService();
    await service.toggleArchive(note.id);
    // ignore: unused_result
    ref.refresh(notesProvider);
  }

  List<Note> _filterNotes(List<Note> notes) {
    // Оптимизированная фильтрация - используем один проход где возможно
    final filtered = <Note>[];
    final query = _searchQuery.toLowerCase();
    final hasSearch = _searchQuery.isNotEmpty;

    // Применяем фильтр и поиск за один проход
    for (final note in notes) {
      // Применяем фильтр
      bool matchesFilter = false;
      switch (_currentFilter) {
        case NoteFilter.pinned:
          matchesFilter = note.pinned;
          break;
        case NoteFilter.archived:
          matchesFilter = note.archived;
          break;
        case NoteFilter.linked:
          matchesFilter = note.linkedEventId != null;
          break;
        case NoteFilter.all:
          matchesFilter = !note.archived;
          break;
      }

      if (!matchesFilter) continue;

      // Применяем поиск
      if (hasSearch) {
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = note.content.toLowerCase().contains(query);
        final tagsMatch = note.tags.any(
          (tag) => tag.toLowerCase().contains(query),
        );
        if (!titleMatch && !contentMatch && !tagsMatch) continue;
      }

      filtered.add(note);
    }

    // Сортировка: закрепленные первыми, затем по дате
    filtered.sort((a, b) {
      if (a.pinned && !b.pinned) return -1;
      if (!a.pinned && b.pinned) return 1;
      final aDate = a.updatedAt ?? a.createdAt;
      final bDate = b.updatedAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notes_title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == NoteViewMode.grid
                  ? Icons.view_list
                  : Icons.grid_view,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == NoteViewMode.grid
                    ? NoteViewMode.list
                    : NoteViewMode.grid;
              });
            },
            tooltip: _viewMode == NoteViewMode.grid
                ? l10n.notes_listView
                : l10n.notes_gridView,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AuroraTheme.blueGradient),
        child: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: AuroraTheme.spaceBlue.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: l10n.notes_searchHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: l10n.notes_all,
                          selected: _currentFilter == NoteFilter.all,
                          onTap: () =>
                              setState(() => _currentFilter = NoteFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.notes_pinned,
                          selected: _currentFilter == NoteFilter.pinned,
                          onTap: () => setState(
                            () => _currentFilter = NoteFilter.pinned,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.notes_archived,
                          selected: _currentFilter == NoteFilter.archived,
                          onTap: () => setState(
                            () => _currentFilter = NoteFilter.archived,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: l10n.notes_linked,
                          selected: _currentFilter == NoteFilter.linked,
                          onTap: () => setState(
                            () => _currentFilter = NoteFilter.linked,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Notes list/grid
            Expanded(
              child: notesAsync.when(
                data: (notes) {
                  final filteredNotes = _filterNotes(notes);

                  if (filteredNotes.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  return _viewMode == NoteViewMode.grid
                      ? _buildGridView(filteredNotes)
                      : _buildListView(filteredNotes);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AuroraTheme.neonBlue),
                ),
                error: (error, stackTrace) => Center(
                  child: Text(
                    l10n.notes_errorLoading,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'templates',
            mini: true,
            onPressed: () => _showTemplatesDialog(context),
            backgroundColor: AuroraTheme.neonPurple,
            child: const Icon(Icons.article, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _openNoteEditor(),
            backgroundColor: AuroraTheme.neonBlue,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_add,
            size: 80,
            color: AuroraTheme.neonBlue.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            _currentFilter == NoteFilter.archived
                ? l10n.notes_emptyArchived
                : _currentFilter == NoteFilter.pinned
                ? l10n.notes_emptyPinned
                : l10n.notes_empty,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.notes_emptySubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _openNoteEditor(),
            icon: const Icon(Icons.add),
            label: Text(l10n.notes_createFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: AuroraTheme.neonBlue,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Note> notes) {
    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _SwipeableNoteCard(
                  note: note,
                  onTap: () => _openNoteEditor(note: note),
                  onDelete: () => _deleteNote(note),
                  onTogglePin: () => _togglePin(note),
                  onToggleArchive: () => _toggleArchive(note),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SwipeableNoteListTile(
                    note: note,
                    onTap: () => _openNoteEditor(note: note),
                    onDelete: () => _deleteNote(note),
                    onTogglePin: () => _togglePin(note),
                    onToggleArchive: () => _toggleArchive(note),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum NoteViewMode { grid, list }

enum NoteFilter { all, pinned, archived, linked }

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AuroraTheme.neonBlue.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AuroraTheme.neonBlue : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AuroraTheme.neonBlue : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = note.color ?? AuroraTheme.spaceBlue.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _showContextMenu(context),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: note.pinned
                  ? AuroraTheme.neonYellow.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: note.pinned ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      note.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    // Content preview
                    Expanded(
                      child: Text(
                        note.content.length > 100
                            ? '${note.content.substring(0, 100)}...'
                            : note.content,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tags and date
                    Row(
                      children: [
                        if (note.tags.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              note.tags.first,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          _formatDate(
                            context,
                            note.updatedAt ?? note.createdAt,
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Pin indicator
              if (note.pinned)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.push_pin,
                    color: AuroraTheme.neonYellow,
                    size: 16,
                  ),
                ),
              // Archived indicator
              if (note.archived)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: Icon(Icons.archive, color: Colors.white70, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteContextMenu(
        note: note,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
        onToggleArchive: onToggleArchive,
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.notes_today;
    } else if (difference.inDays == 1) {
      return l10n.notes_yesterday;
    } else if (difference.inDays < 7) {
      return l10n.notes_daysAgo(difference.inDays);
    } else {
      final locale = Localizations.localeOf(context);
      return DateFormat.Md(locale.toString()).format(date);
    }
  }
}

class _NoteContextMenu extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  const _NoteContextMenu({
    required this.note,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AuroraTheme.spaceBlue,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Note title
          Text(
            note.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          // Actions
          _ContextMenuButton(
            icon: note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.pinned ? l10n.notes_unpin : l10n.notes_pin,
            color: AuroraTheme.neonYellow,
            onTap: () {
              Navigator.pop(context);
              onTogglePin();
            },
          ),
          const SizedBox(height: 12),
          _ContextMenuButton(
            icon: note.archived ? Icons.unarchive : Icons.archive,
            label: note.archived ? l10n.notes_unarchive : l10n.notes_archive,
            color: Colors.blueAccent,
            onTap: () {
              Navigator.pop(context);
              onToggleArchive();
            },
          ),
          const SizedBox(height: 12),
          _ContextMenuButton(
            icon: Icons.copy,
            label: l10n.notes_copy,
            color: Colors.green,
            onTap: () async {
              Navigator.pop(context);
              // Copy note to clipboard
              final text = '${note.title}\n\n${note.content}';
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.notes_copied),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          _ContextMenuButton(
            icon: Icons.share,
            label: l10n.notes_share,
            color: AuroraTheme.neonPurple,
            onTap: () async {
              Navigator.pop(context);
              // Share note
              // Use Share plugin if available, otherwise show snackbar
              try {
                // Share.share('${note.title}\n\n${note.content}', subject: note.title);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.notes_shareNotAvailable),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.common_error}: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          _ContextMenuButton(
            icon: Icons.delete,
            label: l10n.common_delete,
            color: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.common_cancel,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextMenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContextMenuButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  const _NoteListTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = note.color ?? AuroraTheme.spaceBlue.withValues(alpha: 0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: note.pinned
                  ? AuroraTheme.neonYellow.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: note.pinned ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNoteIcon(note.type),
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with pin indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        if (note.pinned)
                          const Icon(
                            Icons.push_pin,
                            color: AuroraTheme.neonYellow,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Content preview
                    Text(
                      note.content.length > 60
                          ? '${note.content.substring(0, 60)}...'
                          : note.content,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Tags and date
                    Row(
                      children: [
                        if (note.tags.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              note.tags.first,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const Spacer(),
                        Text(
                          _formatDate(
                            context,
                            note.updatedAt ?? note.createdAt,
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteContextMenu(
        note: note,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
        onToggleArchive: onToggleArchive,
      ),
    );
  }

  IconData _getNoteIcon(NoteType type) {
    switch (type) {
      case NoteType.checklist:
        return Icons.checklist;
      case NoteType.rich:
        return Icons.description;
      case NoteType.audio:
        return Icons.audiotrack;
      case NoteType.image:
        return Icons.image;
      default:
        return Icons.note;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.notes_today;
    } else if (difference.inDays == 1) {
      return l10n.notes_yesterday;
    } else if (difference.inDays < 7) {
      return l10n.notes_daysAgo(difference.inDays);
    } else {
      final locale = Localizations.localeOf(context);
      return DateFormat.Md(locale.toString()).format(date);
    }
  }
}

class _TemplateCard extends StatelessWidget {
  final NoteTemplate template;
  final VoidCallback onTap;
  const _TemplateCard({required this.template, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                template.color.withValues(alpha: 0.3),
                template.color.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: template.color.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: template.color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: template.color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  template.icon,
                  color: template.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: Text(
                  template.title(l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  template.description(l10n),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeableNoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  const _SwipeableNoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white, size: 32),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggleArchive();
        } else {
          onDelete();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AuroraTheme.spaceBlue,
              title: Text(
                AppLocalizations.of(context)!.notes_deleteConfirm,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.common_cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text(AppLocalizations.of(context)!.common_delete),
                ),
              ],
            ),
          ) ?? false;
        }
        return true;
      },
      child: _NoteCard(
        note: note,
        onTap: onTap,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
        onToggleArchive: onToggleArchive,
      ),
    );
  }
}

class _SwipeableNoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  const _SwipeableNoteListTile({
    required this.note,
    required this.onTap,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          onToggleArchive();
        } else {
          onDelete();
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AuroraTheme.spaceBlue,
              title: Text(
                AppLocalizations.of(context)!.notes_deleteConfirm,
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppLocalizations.of(context)!.common_cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  child: Text(AppLocalizations.of(context)!.common_delete),
                ),
              ],
            ),
          ) ?? false;
        }
        return true;
      },
      child: _NoteListTile(
        note: note,
        onTap: onTap,
        onDelete: onDelete,
        onTogglePin: onTogglePin,
        onToggleArchive: onToggleArchive,
      ),
    );
  }
}
