import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import '../data/models/profile.dart';
import '../data/repositories/auth_repository.dart';
import '../services/api_config.dart';
import '../data/models/course.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  User? _user;
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._repository);

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  List<Course> get enrolledCourses =>
      _profile?.enrolledCourses
          .map((course) => Course.fromJson(course))
          .toList() ??
      [];
  List<Course> get createdCourses =>
      _profile?.createdCourses
          .map((course) => Course.fromJson(course))
          .toList() ??
      [];

  Future<void> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _user = await _repository.login(username, password);
      if (_user?.token != null) {
        await ApiConfig.setAuthToken(_user!.token!);
        await fetchProfile();
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.logout();

      // Clear local state
      _user = null;
      _profile = null;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      final hasToken = await ApiConfig.hasToken();
      if (hasToken) {
        await refreshToken();
      } else {
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> refreshToken() async {
    try {
      if (_user?.refreshToken != null) {
        final newUser = await _repository.refreshToken(_user!.refreshToken!);
        _user = newUser;
        if (_user?.token != null) {
          await ApiConfig.setAuthToken(_user!.token!);
        }
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      await logout();
      notifyListeners();
      throw e;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.register(
        username: username,
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );

      await login(username, password);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await _repository.getProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await _repository.updateProfile(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _profile = await _repository.updateProfileImage(imagePath);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isTeacher => _profile?.role == 'teacher';
  bool get isStudent => _profile?.role == 'student';

  List<Course> get userCourses {
    if (isTeacher) {
      return createdCourses;
    } else if (isStudent) {
      return enrolledCourses;
    }
    return [];
  }
}
