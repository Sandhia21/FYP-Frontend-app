import '../models/note.dart';
import '../../services/note_api_service.dart';

class NoteRepository {
  final NoteApiService _noteService;

  NoteRepository(this._noteService);

  Future<List<Note>> getNotes(int moduleId) async {
    try {
      final response = await _noteService.fetchNotes(moduleId);
      return response.map((noteJson) => Note.fromJson(noteJson)).toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Note> getNote(int moduleId, int noteId) async {
    try {
      final response = await _noteService.getNote(moduleId, noteId);
      return Note.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> createNote(
      int moduleId, String title, String content, bool fromAI) async {
    try {
      await _noteService.createNote(moduleId, title, content, fromAI: fromAI);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> updateNote(
      int moduleId, int noteId, String title, String content) async {
    try {
      await _noteService.updateNote(moduleId, noteId, title, content);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> deleteNote(int moduleId, int noteId) async {
    try {
      await _noteService.deleteNote(moduleId, noteId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> generateQuizFromNotes(int moduleId, List<int> noteIds) async {
    try {
      await _noteService.generateQuizFromNotes(moduleId, noteIds);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'note not found':
          return 'The requested note does not exist';
        case 'permission denied':
          return 'You do not have permission to access this note';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'module not found':
          return 'The module associated with this note does not exist';
        case 'invalid note data':
          return 'Please check the note information and try again';
        case 'note limit reached':
          return 'Maximum number of notes reached for this module';
        case 'content too long':
          return 'Note content exceeds maximum length';
        case 'empty content':
          return 'Note content cannot be empty';
        case 'quiz generation failed':
          return 'Failed to generate quiz from selected notes';
        case 'insufficient notes':
          return 'Please select at least one note to generate quiz';
        case 'ai generation failed':
          return 'Failed to generate note content using AI';
        case 'ai service unavailable':
          return 'AI service is temporarily unavailable';
        case 'invalid title':
          return 'Please provide a clearer title for AI generation';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
