import 'package:flutter/foundation.dart';
import '../data/models/course.dart';
import '../data/repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repository;

  List<Course> _courses = [];
  Course _selectedCourse = Course.empty();
  bool _isLoading = false;
  String? _error;

  CourseProvider(this._repository);

  List<Course> get courses => _courses;
  Course get selectedCourse => _selectedCourse;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalQuizzes {
    return courses.fold(0, (sum, course) => sum + course.quizCount);
  }

  double get averageProgress {
    if (courses.isEmpty) return 0.0;
    return courses.fold(0.0, (sum, course) => sum + course.progress) /
        courses.length;
  }

  Future<void> fetchCourses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _courses = await _repository.fetchCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCourseDetail(int courseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final course = await _repository.getCourseDetail(courseId);
      _selectedCourse = course;
    } catch (e) {
      _error = e.toString();
      _selectedCourse = Course.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createCourse(Course course) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.createCourse(course);
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateCourse(course);
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int courseId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteCourse(courseId);
      await fetchCourses();
    } catch (e) {
      _error = e.toString();
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
