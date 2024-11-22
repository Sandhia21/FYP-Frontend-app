class Profile {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String role;
  final String? imageUrl;
  final List<dynamic> enrolledCourses;
  final List<dynamic> createdCourses;

  Profile({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.imageUrl,
    this.enrolledCourses = const [],
    this.createdCourses = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;

    return Profile(
      id: userData['id'] ?? 0,
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
      firstName: userData['first_name'],
      lastName: userData['last_name'],
      role: userData['role'] ?? 'student',
      imageUrl: userData['image'],
      enrolledCourses: json['enrolled_courses'] ?? [],
      createdCourses: json['created_courses'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'image': imageUrl,
      'enrolled_courses': enrolledCourses,
      'created_courses': createdCourses,
    };
  }
}
