import '../models/user.dart';
import '../../services/auth_api_service.dart';
import '../../services/api_config.dart';
import '../models/profile.dart';

class AuthRepository {
  final AuthApiService _authService;

  AuthRepository(this._authService);

  Future<User> login(String username, String password) async {
    try {
      final response = await _authService.login(username, password);
      final user = User.fromJson(response);
      return user;
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  // Add register method
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
  }) async {
    try {
      await _authService.register(
        username: username,
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      await ApiConfig.removeAuthToken();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<User> refreshToken(String refreshToken) async {
    try {
      final response = await _authService.refreshToken(refreshToken);
      return User.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Profile> getProfile() async {
    try {
      final response = await _authService.getProfile();
      return Profile.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Profile> updateProfile({
    required String username,
    required String email,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _authService.updateProfile(
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );

      print('Repository received response:');
      print(response);

      // If response doesn't contain user data, wrap it
      // if (!response.containsKey('user')) {
      //   response = {'user': response};
      // }

      return Profile.fromJson(response);
    } catch (e) {
      print('Repository error:');
      print(e);
      throw _handleRepositoryError(e);
    }
  }

  Future<Profile> updateProfileImage(String imagePath) async {
    try {
      final response = await _authService.updateProfileImage(imagePath);
      return Profile.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'invalid credentials':
          return 'Incorrect username or password';
        case 'token expired':
          return 'Your session has expired. Please login again';
        case 'invalid token':
          return 'Authentication failed. Please login again';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'username already exists':
          return 'This username is already taken';
        case 'email already exists':
          return 'This email is already registered';
        case 'invalid email format':
          return 'Please enter a valid email address';
        case 'password too weak':
          return 'Password must be at least 8 characters long';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
