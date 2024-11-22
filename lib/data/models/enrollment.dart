import 'course.dart';
import 'user.dart';

class EnrollmentRequest {
  final int id;
  final Course course;
  final User student;
  final String status;

  EnrollmentRequest({
    required this.id,
    required this.course,
    required this.student,
    required this.status,
  });

  factory EnrollmentRequest.fromJson(Map<String, dynamic> json) {
    return EnrollmentRequest(
      id: json['id'] ?? 0,
      course: Course.fromJson(json['course'] ?? {}),
      student: User.fromJson(json['student'] ?? {}),
      status: json['status'] ?? 'unknown',
    );
  }
}

class StudentEnrollmentRequest {
  final String courseName;
  final String courseDescription;
  final String courseImage;
  final String status;

  StudentEnrollmentRequest({
    required this.courseName,
    required this.courseDescription,
    required this.courseImage,
    required this.status,
  });

  factory StudentEnrollmentRequest.fromJson(Map<String, dynamic> json) {
    return StudentEnrollmentRequest(
      courseName: json['course_name'] ?? 'Unknown Course',
      courseDescription:
          json['course_description'] ?? 'No description available',
      courseImage: json['course_image'] ?? 'no_image.png',
      status: json['enrollment_status'] ?? 'unknown',
    );
  }
}
