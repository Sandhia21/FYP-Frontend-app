class Course {
  final int id;
  final String name;
  final String description;
  final String courseCode;
  final String createdByUsername;
  final List<String> students;
  final String imageUrl;
  final double progress;
  final int quizCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.courseCode,
    required this.createdByUsername,
    required this.students,
    required this.imageUrl,
    required this.progress,
    required this.quizCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdByUsername: json['created_by']?['username'] ?? '',
      courseCode: json['code'] ?? '',
      students: List<String>.from(json['students'] ?? []),
      imageUrl: json['image'] ?? '',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      quizCount: json['quiz_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  factory Course.empty() {
    return Course(
      id: 0,
      name: '',
      description: '',
      courseCode: '',
      createdByUsername: '',
      students: [],
      imageUrl: '',
      progress: 0.0,
      quizCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory Course.forCreate({
    required String name,
    required String description,
    required String courseCode,
  }) {
    return Course(
      id: 0,
      name: name,
      description: description,
      courseCode: courseCode,
      createdByUsername: '',
      students: [],
      imageUrl: '',
      progress: 0.0,
      quizCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': courseCode,
      'created_by': {'username': createdByUsername},
      'students': students,
      'image': imageUrl,
      'progress': progress,
      'quiz_count': quizCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'description': description,
      'code': courseCode,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
    };
  }

  Course copyWith({
    int? id,
    String? name,
    String? description,
    String? courseCode,
    String? createdByUsername,
    List<String>? students,
    String? imageUrl,
    double? progress,
    int? quizCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      courseCode: courseCode ?? this.courseCode,
      createdByUsername: createdByUsername ?? this.createdByUsername,
      students: students ?? this.students,
      imageUrl: imageUrl ?? this.imageUrl,
      progress: progress ?? this.progress,
      quizCount: quizCount ?? this.quizCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
