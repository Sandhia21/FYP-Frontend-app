class User {
  final String username;
  final int id;
  final String? imageUrl;
  final String? token;
  final String? refreshToken;
  final String role;
  final String email;
  final List<dynamic> enrolledCourses;
  final List<dynamic> createdCourses;
  final String? firstName;
  final String? lastName;

  User({
    required this.username,
    required this.id,
    this.imageUrl,
    this.token,
    this.refreshToken,
    required this.role,
    required this.email,
    this.enrolledCourses = const [],
    this.createdCourses = const [],
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['user']['username'] ?? '',
      id: json['user']['id'] ?? 0,
      imageUrl: json['user']['image'],
      token: json['access'],
      refreshToken: json['refresh'],
      role: json['user']['role'] ?? 'student',
      email: json['user']['email'] ?? '',
      enrolledCourses: json['enrolled_courses'] ?? [],
      createdCourses: json['created_courses'] ?? [],
      firstName: json['user']['first_name'],
      lastName: json['user']['last_name'],
    );
  }

  bool isStudent() => role == 'student';
}
