import 'dart:ui';
import 'package:flutter/material.dart';

enum NoteType { text, checklist, rich, audio, image }

enum SyncStatus {
  local, // only in app
  syncing, // currently syncing
  synced, // synced with calendar
  error, // sync error
}

class Attachment {
  final String id;
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize; // in bytes
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'fileName': fileName,
    'filePath': filePath,
    'mimeType': mimeType,
    'fileSize': fileSize,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json['id'] as String,
    fileName: json['fileName'] as String,
    filePath: json['filePath'] as String,
    mimeType: json['mimeType'] as String,
    fileSize: json['fileSize'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class Note {
  String id;
  String title;
  String content; // plain text or Quill delta (as JSON string)
  NoteType type;
  DateTime createdAt;
  DateTime? updatedAt;
  List<String> tags;
  bool pinned;
  bool archived;
  Color? color;
  List<Attachment> attachments;
  String? linkedEventId; // ID of linked PlannedEvent
  String? calendarEventId; // ID in system calendar
  SyncStatus syncStatus;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.type = NoteType.text,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.pinned = false,
    this.archived = false,
    this.color,
    this.attachments = const [],
    this.linkedEventId,
    this.calendarEventId,
    this.syncStatus = SyncStatus.local,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'type': type.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'tags': tags,
    'pinned': pinned,
    'archived': archived,
    'color': color?.toARGB32(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
    'linkedEventId': linkedEventId,
    'calendarEventId': calendarEventId,
    'syncStatus': syncStatus.toString().split('.').last,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    type: NoteType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type'],
      orElse: () => NoteType.text,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : null,
    tags: (json['tags'] as List<dynamic>).cast<String>(),
    pinned: json['pinned'] as bool? ?? false,
    archived: json['archived'] as bool? ?? false,
    color: json['color'] != null ? Color(json['color'] as int) : null,
    attachments:
        (json['attachments'] as List<dynamic>?)
            ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
            .toList() ??
        const [],
    linkedEventId: json['linkedEventId'] as String?,
    calendarEventId: json['calendarEventId'] as String?,
    syncStatus: SyncStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['syncStatus'],
      orElse: () => SyncStatus.local,
    ),
  );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    NoteType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    bool? pinned,
    bool? archived,
    Color? color,
    bool clearColor = false,
    List<Attachment>? attachments,
    String? linkedEventId,
    bool clearLinkedEventId = false,
    String? calendarEventId,
    bool clearCalendarEventId = false,
    SyncStatus? syncStatus,
  }) => Note(
    id: id ?? this.id,
    title: title ?? this.title,
    content: content ?? this.content,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    tags: tags ?? this.tags,
    pinned: pinned ?? this.pinned,
    archived: archived ?? this.archived,
    color: clearColor ? null : (color ?? this.color),
    attachments: attachments ?? this.attachments,
    linkedEventId: clearLinkedEventId ? null : (linkedEventId ?? this.linkedEventId),
    calendarEventId: clearCalendarEventId ? null : (calendarEventId ?? this.calendarEventId),
    syncStatus: syncStatus ?? this.syncStatus,
  );
}
