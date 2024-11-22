class Module {
  final int id;
  final String title;
  final String description;
  final int courseId;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    try {
      return Module(
        id: json['id'] ?? 0,
        title: json['title'] ?? 'Untitled',
        description: json['description'] ?? 'No description',
        courseId: json['course_id'] ?? json['course'] ?? 0,
      );
    } catch (e) {
      print('Error parsing Module JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
    };
  }
}
