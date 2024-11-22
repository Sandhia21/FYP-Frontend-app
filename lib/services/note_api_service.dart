import 'package:dio/dio.dart';
import 'api_config.dart';

class NoteApiService {
  final Dio _dio;

  NoteApiService() : _dio = ApiConfig.dio;

  // Fetch all notes for a module
  Future<List<dynamic>> fetchNotes(int moduleId) async {
    try {
      final response = await _dio.get('/modules/$moduleId/notes/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Get a single note
  Future<Map<String, dynamic>> getNote(int moduleId, int noteId) async {
    try {
      final response = await _dio.get('/modules/$moduleId/notes/$noteId/');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Create a new note
  Future<Map<String, dynamic>> createNote(
    int moduleId,
    String title,
    String content, {
    bool fromAI = false,
  }) async {
    try {
      final response = await _dio.post(
        '/modules/$moduleId/notes/',
        data: {
          'title': title,
          'content': content,
          'from_ai': fromAI,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update an existing note
  Future<Map<String, dynamic>> updateNote(
    int moduleId,
    int noteId,
    String title,
    String content,
  ) async {
    try {
      final response = await _dio.put(
        '/modules/$moduleId/notes/$noteId/',
        data: {
          'title': title,
          'content': content,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Delete a note
  Future<void> deleteNote(int moduleId, int noteId) async {
    try {
      await _dio.delete('/modules/$moduleId/notes/$noteId/');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generate quiz from selected notes
  Future<Map<String, dynamic>> generateQuizFromNotes(
    int moduleId,
    List<int> noteIds,
  ) async {
    try {
      final response = await _dio.post(
        '/modules/$moduleId/notes/generate-quiz/',
        data: {
          'note_ids': noteIds,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Generate quiz from a single note
  Future<Map<String, dynamic>> generateQuizFromSingleNote(
    int moduleId,
    int noteId,
    String quizTitle,
  ) async {
    try {
      final response = await _dio.post(
        '/modules/$moduleId/notes/$noteId/generate-quiz/',
        data: {
          'quiz_title': quizTitle,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Update error handler to include AI-specific errors
  String _handleError(DioException e) {
    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        return 'Please login to access notes';
      }
      if (e.response!.statusCode == 403) {
        return 'You don\'t have permission to perform this action';
      }
      if (e.response!.statusCode == 404) {
        return 'Note not found';
      }
      if (e.response!.statusCode == 413) {
        return 'Content too long';
      }
      if (e.response!.data is Map) {
        final errorMessage = e.response!.data['detail'] ??
            e.response!.data['error'] ??
            'An error occurred';
        return errorMessage.toString();
      }
      if (e.response!.statusCode == 429) {
        return 'AI generation limit reached. Please try again later.';
      }
      return e.response!.statusMessage ?? 'An error occurred';
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server not responding';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Please check your internet connection';
    }

    return e.message ?? 'Network error occurred';
  }
}
