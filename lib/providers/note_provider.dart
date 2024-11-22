import 'package:flutter/foundation.dart';
import '../data/models/note.dart';
import '../data/repositories/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository;

  List<Note> _notes = [];
  Note? _selectedNote;
  bool _isLoading = false;
  String? _error;
  bool _isSelectionMode = false;
  final Set<int> _selectedNoteIds = {};

  NoteProvider(this._repository);

  // Getters
  List<Note> get notes => _notes;
  Note? get selectedNote => _selectedNote;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSelectionMode => _isSelectionMode;
  Set<int> get selectedNoteIds => _selectedNoteIds;
  bool get hasSelectedNotes => _selectedNoteIds.isNotEmpty;

  // Load notes
  Future<void> loadNotes(int moduleId) async {
    try {
      _setLoading(true);
      _notes = await _repository.getNotes(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Create note
  Future<void> createNote(
    int moduleId,
    String title,
    String content, {
    bool fromAI = false,
  }) async {
    try {
      _setLoading(true);
      await _repository.createNote(moduleId, title, content, fromAI);
      await loadNotes(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Update note
  Future<void> updateNote(
    int moduleId,
    int noteId,
    String title,
    String content,
  ) async {
    try {
      _setLoading(true);
      await _repository.updateNote(moduleId, noteId, title, content);
      await loadNotes(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Delete note
  Future<void> deleteNote(int moduleId, int noteId) async {
    try {
      _setLoading(true);
      await _repository.deleteNote(moduleId, noteId);
      await loadNotes(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Get single note
  Future<Note> getNote(int moduleId, int noteId) async {
    try {
      _setLoading(true);
      _selectedNote = await _repository.getNote(moduleId, noteId);
      _error = null;
      return _selectedNote!;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Generate quiz from selected notes
  Future<void> generateQuiz(int moduleId, List<int> noteIds) async {
    if (noteIds.isEmpty) {
      throw Exception('Please select at least one note');
    }

    try {
      _setLoading(true);
      await _repository.generateQuizFromNotes(moduleId, noteIds);
      _error = null;
      clearSelection(); // Clear selection after successful quiz generation
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _setLoading(false);
    }
  }

  // Selection mode methods
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      clearSelection();
    }
    notifyListeners();
  }

  void toggleNoteSelection(int noteId) {
    if (_selectedNoteIds.contains(noteId)) {
      _selectedNoteIds.remove(noteId);
    } else {
      _selectedNoteIds.add(noteId);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedNoteIds.clear();
    notifyListeners();
  }

  // Helper method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Clear state when disposing
  @override
  void dispose() {
    _notes = [];
    _selectedNote = null;
    _error = null;
    _selectedNoteIds.clear();
    super.dispose();
  }
}
