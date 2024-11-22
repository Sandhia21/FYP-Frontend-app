import '../models/enrollment.dart';
import '../../services/enrollment_api_service.dart';

class EnrollmentRepository {
  final EnrollmentApiService _enrollmentService;

  EnrollmentRepository(this._enrollmentService);

  Future<List<EnrollmentRequest>> fetchTeacherEnrollmentRequests() async {
    try {
      final response =
          await _enrollmentService.fetchTeacherEnrollmentRequests();
      return response
          .map((request) => EnrollmentRequest.fromJson(request))
          .toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<List<StudentEnrollmentRequest>>
      fetchStudentEnrollmentRequests() async {
    try {
      final response =
          await _enrollmentService.fetchStudentEnrollmentRequests();
      return response
          .map((request) => StudentEnrollmentRequest.fromJson(request))
          .toList();
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<void> respondToEnrollment(int requestId, bool isApproved) async {
    try {
      await _enrollmentService.respondToEnrollment(requestId, isApproved);
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  Future<bool> enrollInCourse(int courseId, String courseCode) async {
    try {
      final response =
          await _enrollmentService.enrollInCourse(courseId, courseCode);

      // Check if the response indicates successful enrollment
      if (response['status'] == 'success' ||
          response['detail']?.contains('successfully') == true) {
        return true;
      }

      // If we get here, something went wrong
      throw response['detail'] ?? 'Failed to enroll in course';
    } catch (e) {
      throw _handleRepositoryError(e);
    }
  }

  String _handleRepositoryError(dynamic error) {
    if (error is String) {
      switch (error.toLowerCase()) {
        case 'enrollment request not found':
          return 'The enrollment request no longer exists';
        case 'permission denied':
          return 'You do not have permission to manage enrollments';
        case 'network error occurred':
          return 'Please check your internet connection';
        case 'request already processed':
          return 'This enrollment request has already been processed';
        case 'course is full':
          return 'Cannot approve enrollment as the course is full';
        case 'already enrolled':
          return 'You are already enrolled in this course';
        case 'enrollment pending':
          return 'Your enrollment request is pending approval';
        case 'enrollment rejected':
          return 'Your previous enrollment request was rejected';
        case 'course full':
          return 'This course is currently full';
        case 'invalid course code':
          return 'The course code you entered is invalid';
        case 'course not found':
          return 'The course could not be found';
        case 'already enrolled':
          return 'You are already enrolled in this course';
        case 'enrollment limit reached':
          return 'The course has reached its enrollment limit';
        case 'invalid request':
          return 'Invalid enrollment request';
        case 'course inactive':
          return 'This course is currently inactive';
        case 'enrollment closed':
          return 'Enrollment for this course is closed';
        case 'please login to manage enrollments':
          return 'Please log in to enroll in courses';
        default:
          if (error.contains('already enrolled')) {
            return 'You are already enrolled in this course';
          }
          return error;
      }
    }
    return error.toString();
  }
}
