import 'package:flutter/foundation.dart';
import '../data/models/enrollment.dart';
import '../data/repositories/enrollment_repository.dart';

class EnrollmentProvider extends ChangeNotifier {
  final EnrollmentRepository _repository;

  List<EnrollmentRequest> _teacherRequests = [];
  List<StudentEnrollmentRequest> _studentRequests = [];
  bool _isLoading = false;
  String? _error;

  EnrollmentProvider(this._repository);

  List<EnrollmentRequest> get teacherRequests => _teacherRequests;
  List<StudentEnrollmentRequest> get studentRequests => _studentRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeacherEnrollmentRequests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _teacherRequests = await _repository.fetchTeacherEnrollmentRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentEnrollmentRequests() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _studentRequests = await _repository.fetchStudentEnrollmentRequests();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToEnrollment(int requestId, bool isApproved) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.respondToEnrollment(requestId, isApproved);
      await loadTeacherEnrollmentRequests(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enrollInCourse(int courseId, String courseCode) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.enrollInCourse(courseId, courseCode);
      await loadStudentEnrollmentRequests(); // Refresh enrollment requests
      return true;
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
