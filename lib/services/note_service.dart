import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/note.dart';
import './storage_service.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  final ValueNotifier<List<Note>> _notes = ValueNotifier<List<Note>>([]);
  ValueNotifier<List<Note>> get notes => _notes;

  final StreamController<Note> _noteUpdatedController =
      StreamController<Note>.broadcast();
  Stream<Note> get noteUpdated => _noteUpdatedController.stream;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _loadNotes();
    _initialized = true;
  }

  Future<void> _loadNotes() async {
    try {
      final loadedNotes = await StorageService.getNotes();
      _notes.value = loadedNotes;
    } catch (e) {
      debugPrint('Error loading notes in NoteService: $e');
    }
  }

  Future<Note> createNote({
    required String title,
    required String content,
    NoteType type = NoteType.text,
    List<String> tags = const [],
    bool pinned = false,
    Color? color,
    String? linkedEventId,
  }) async {
    final note = Note(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      pinned: pinned,
      color: color,
      linkedEventId: linkedEventId,
    );

    await StorageService.addNote(note);
    await _loadNotes();
    _noteUpdatedController.add(note);
    return note;
  }

  Future<void> updateNote(Note note) async {
    await StorageService.updateNote(note);
    await _loadNotes();
    _noteUpdatedController.add(note);
  }

  Future<void> togglePin(String noteId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(pinned: !note.pinned);
      await updateNote(updatedNote);
    }
  }

  Future<void> toggleArchive(String noteId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(archived: !note.archived);
      await updateNote(updatedNote);
    }
  }

  Future<void> linkNoteToEvent(String noteId, String eventId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(linkedEventId: eventId);
      await updateNote(updatedNote);
    }
  }

  Future<void> unlinkNoteFromEvent(String noteId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(
        // ignore: avoid_redundant_argument_values
        linkedEventId: null,
      );
      await updateNote(updatedNote);
    }
  }

  Future<void> addTag(String noteId, String tag) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedTags = note.tags.toList()..add(tag);
      final updatedNote = note.copyWith(tags: updatedTags);
      await updateNote(updatedNote);
    }
  }

  Future<void> removeTag(String noteId, String tag) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedTags = List<String>.from(note.tags)..remove(tag);
      final updatedNote = note.copyWith(tags: updatedTags);
      await updateNote(updatedNote);
    }
  }

  Future<void> setColor(String noteId, Color color) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(color: color);
      await updateNote(updatedNote);
    }
  }

  Future<void> clearColor(String noteId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedNote = note.copyWith(
        // ignore: avoid_redundant_argument_values
        color: null,
      );
      await updateNote(updatedNote);
    }
  }

  List<Note> getNotesForEvent(String eventId) {
    return _notes.value
        .where((note) => note.linkedEventId == eventId && !note.archived)
        .toList();
  }

  List<Note> getPinnedNotes() {
    return _notes.value.where((note) => note.pinned && !note.archived).toList();
  }

  List<Note> getArchivedNotes() {
    return _notes.value.where((note) => note.archived).toList();
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes.value;
    final lowerQuery = query.toLowerCase();
    return _notes.value.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Получить директорию для хранения вложений
  Future<Directory> _getAttachmentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${appDir.path}/note_attachments');
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    return attachmentsDir;
  }

  /// Добавить вложение к заметке (изображение)
  Future<Attachment> addImageAttachment(String noteId, XFile imageFile) async {
    try {
      final attachmentsDir = await _getAttachmentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final targetFile = File('${attachmentsDir.path}/$fileName');

      // Копируем файл
      final sourceFile = File(imageFile.path);
      await sourceFile.copy(targetFile.path);

      final attachment = Attachment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: imageFile.name,
        filePath: targetFile.path,
        mimeType: 'image/${imageFile.path.split('.').last}',
        fileSize: await targetFile.length(),
        createdAt: DateTime.now(),
      );

      await _addAttachmentToNote(noteId, attachment);
      return attachment;
    } catch (e) {
      debugPrint('Error adding image attachment: $e');
      rethrow;
    }
  }

  /// Добавить вложение к заметке (файл)
  Future<Attachment> addFileAttachment(String noteId, PlatformFile file) async {
    try {
      final attachmentsDir = await _getAttachmentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final targetFile = File('${attachmentsDir.path}/$fileName');

      // Копируем файл
      if (file.bytes != null) {
        await targetFile.writeAsBytes(file.bytes!);
      } else if (file.path != null) {
        final sourceFile = File(file.path!);
        await sourceFile.copy(targetFile.path);
      } else {
        throw Exception('File has no data');
      }

      final attachment = Attachment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        fileName: file.name,
        filePath: targetFile.path,
        mimeType: file.extension ?? 'application/octet-stream',
        fileSize: file.size,
        createdAt: DateTime.now(),
      );

      await _addAttachmentToNote(noteId, attachment);
      return attachment;
    } catch (e) {
      debugPrint('Error adding file attachment: $e');
      rethrow;
    }
  }

  /// Внутренний метод для добавления вложения к заметке
  Future<void> _addAttachmentToNote(
    String noteId,
    Attachment attachment,
  ) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final updatedAttachments = List<Attachment>.from(note.attachments)
        ..add(attachment);
      final updatedNote = note.copyWith(attachments: updatedAttachments);
      await updateNote(updatedNote);
    }
  }

  /// Удалить вложение из заметки
  Future<void> removeAttachment(String noteId, String attachmentId) async {
    final notes = _notes.value;
    final index = notes.indexWhere((n) => n.id == noteId);
    if (index >= 0) {
      final note = notes[index];
      final attachment = note.attachments.firstWhere(
        (a) => a.id == attachmentId,
        orElse: () => throw Exception('Attachment not found'),
      );

      // Удаляем файл с диска
      try {
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting attachment file: $e');
      }

      // Удаляем из заметки
      final updatedAttachments = note.attachments
          .where((a) => a.id != attachmentId)
          .toList();
      final updatedNote = note.copyWith(attachments: updatedAttachments);
      await updateNote(updatedNote);
    }
  }

  /// Удалить все вложения заметки (при удалении заметки)
  Future<void> deleteNoteAttachments(String noteId) async {
    final notes = _notes.value;
    final note = notes.firstWhere(
      (n) => n.id == noteId,
      orElse: () => throw Exception('Note not found'),
    );

    // Удаляем все файлы вложений
    for (final attachment in note.attachments) {
      try {
        final file = File(attachment.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting attachment file: $e');
      }
    }
  }

  /// Удалить заметку (включая все вложения)
  Future<void> deleteNote(String noteId) async {
    await deleteNoteAttachments(noteId);
    await StorageService.deleteNote(noteId);
    await _loadNotes();
  }

  void dispose() {
    _noteUpdatedController.close();
  }
}
