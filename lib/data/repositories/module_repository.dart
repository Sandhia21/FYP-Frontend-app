import '../models/module.dart';
import '../../services/module_api_service.dart';

class ModuleRepository {
  final ModuleApiService _moduleService;

  ModuleRepository(this._moduleService);

  Future<List<Module>> getModules(int courseId) async {
    try {
      final response = await _moduleService.fetchModules(courseId);
      return response.map((moduleJson) => Module.fromJson(moduleJson)).toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> createModule(
      int courseId, String title, String description) async {
    try {
      await _moduleService.createModule(courseId, title, description);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> updateModule(
      int moduleId, String title, String description, int courseId) async {
    try {
      await _moduleService.updateModule(moduleId, title, description, courseId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> deleteModule(int moduleId) async {
    try {
      await _moduleService.deleteModule(moduleId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'module not found':
          return 'The requested module does not exist';
        case 'permission denied':
          return 'You do not have permission to manage this module';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'course not found':
          return 'The course associated with this module does not exist';
        case 'invalid module data':
          return 'Please check the module information and try again';
        case 'module limit reached':
          return 'Maximum number of modules reached for this course';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
