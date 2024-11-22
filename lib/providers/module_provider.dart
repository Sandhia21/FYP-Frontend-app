import 'package:flutter/foundation.dart';
import '../services/module_api_service.dart';
import '../data/models/module.dart';

class ModuleProvider with ChangeNotifier {
  final ModuleApiService _moduleService;

  Module? _selectedModule;
  List<Module> _modules = [];
  bool _isLoading = false;
  String? _error;

  ModuleProvider(this._moduleService);

  // Getters
  Module? get selectedModule => _selectedModule;
  List<Module> get modules => _modules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchModules(int courseId) async {
    _setLoading(true);
    try {
      final List<dynamic> data = await _moduleService.fetchModules(courseId);
      print('API Response: $data'); // Debug print

      if (data.isEmpty) {
        _modules = [];
        _error = null;
        return;
      }

      _modules = data
          .map((json) {
            try {
              if (json is! Map<String, dynamic>) {
                print('Invalid module data format: $json');
                return null;
              }
              return Module.fromJson(json);
            } catch (e) {
              print('Error parsing module: $e'); // Debug print
              print('Problematic JSON: $json'); // Add this line
              return null;
            }
          })
          .whereType<Module>()
          .toList();

      print('Parsed Modules: $_modules'); // Debug print
      _error = null;
    } catch (e) {
      print('Error fetching modules: $e'); // Debug print
      _error = e.toString();
      _modules = []; // Clear modules on error
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchModuleDetails(int moduleId) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> data =
          await _moduleService.fetchModuleDetails(moduleId);
      _selectedModule = Module.fromJson(data);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> createModule(
      int courseId, String title, String description) async {
    _setLoading(true);
    try {
      await _moduleService.createModule(courseId, title, description);
      await fetchModules(courseId);
      _error = null;
    } catch (e) {
      print('Error in ModuleProvider.createModule: $e');
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateModule(
      int moduleId, String title, String description, int courseId) async {
    _setLoading(true);
    try {
      await _moduleService.updateModule(
        moduleId,
        title,
        description,
        courseId,
      );
      await fetchModuleDetails(moduleId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteModule(int moduleId) async {
    _setLoading(true);
    try {
      await _moduleService.deleteModule(moduleId);
      await fetchModules(
          _selectedModule?.courseId ?? 0); // Refresh the list after deletion
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
