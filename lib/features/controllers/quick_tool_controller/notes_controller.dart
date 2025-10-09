// ignore_for_file: depend_on_referenced_packages

import 'package:daily_mate/data/services/notification_service.dart';
import 'package:daily_mate/utils/constants/api_constants.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class NotesController extends GetxController {
  final RxList<NoteModel> notes = <NoteModel>[].obs;
  final notificationService = NotificationService();

  @override
  void onInit() {
    super.onInit();
    _loadNotes();
  }

  /// Add new note
  void addNote(String title, String content, {DateTime? reminder}) {
    final note = NoteModel(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      reminder: reminder,
    );

    notes.add(note);
    _saveNotes();

    // Schedule reminder if provided
    if (reminder != null) {
      notificationService.scheduleNoteReminder(
        noteId: note.id,
        title: title,
        scheduledDate: reminder,
      );
    }
  }

  /// Edit existing note
  void editNote(String id, String title, String content, {DateTime? reminder}) {
    final index = notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final oldNote = notes[index];

      notes[index] = NoteModel(
        id: id,
        title: title,
        content: content,
        createdAt: oldNote.createdAt,
        reminder: reminder,
      );

      _saveNotes();

      // Cancel old reminder if existed
      notificationService.cancelNoteReminder(id);

      // Schedule new reminder if provided
      if (reminder != null) {
        notificationService.scheduleNoteReminder(
          noteId: id,
          title: title,
          scheduledDate: reminder,
        );
      }
    }
  }

  /// Delete note
  void deleteNote(String id) {
    notes.removeWhere((note) => note.id == id);
    _saveNotes();
    notificationService.cancelNoteReminder(id); // cancel reminder too
  }

  /// Save notes to local storage
  void _saveNotes() {
    final data = notes.map((note) => note.toJson()).toList();
    storageService.write(notesIdKey, data);
  }

  /// Load notes from local storage
  void _loadNotes() {
    final data = storageService.read(notesIdKey);
    if (data != null && data is List) {
      notes.assignAll(
        data
            .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }
  }
}


class NoteModel {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime? reminder; // 👈 NEW FIELD

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminder,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'reminder': reminder?.toIso8601String(),
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        reminder: json['reminder'] != null
            ? DateTime.parse(json['reminder'])
            : null,
      );
}

