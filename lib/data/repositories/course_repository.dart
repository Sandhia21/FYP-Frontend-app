import '../models/course.dart';
import '../../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService _courseService;

  CourseRepository(this._courseService);

  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _courseService.fetchCourses();
      return response.map((courseJson) => Course.fromJson(courseJson)).toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Course> getCourseDetail(int courseId) async {
    try {
      final response = await _courseService.getCourseDetail(courseId);
      return Course.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Course> createCourse(Course course) async {
    try {
      final response = await _courseService.createCourse(course.toCreateJson());
      return Course.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<Course> updateCourse(Course course) async {
    try {
      final response = await _courseService.updateCourse(
        course.id,
        course.toUpdateJson(),
      );
      return Course.fromJson(response);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> deleteCourse(int courseId) async {
    try {
      await _courseService.deleteCourse(courseId);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'course not found':
          return 'The requested course does not exist';
        case 'permission denied':
          return 'You do not have permission to perform this action';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'invalid course data':
          return 'Please check the course information and try again';
        case 'duplicate course code':
          return 'A course with this code already exists';
        case 'invalid course code':
          return 'Please enter a valid course code';
        default:
          return error;
      }
    }
    return error.toString();
  }
}
