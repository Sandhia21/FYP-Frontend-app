class Result {
  final int id;
  final int quizId;
  final int studentId;
  final double percentage;
  final String quizContent;
  final String? aiRecommendations;
  final DateTime dateTaken;
  final String? studentName;

  Result({
    required this.id,
    required this.quizId,
    required this.studentId,
    required this.percentage,
    required this.quizContent,
    this.aiRecommendations,
    required this.dateTaken,
    this.studentName,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      quizId: json['quiz'],
      studentId: json['student'],
      percentage: (json['percentage'] is int)
          ? json['percentage'].toDouble()
          : json['percentage'],
      quizContent: json['quiz_content'],
      aiRecommendations: json['ai_recommendations'],
      dateTaken: DateTime.parse(json['date_taken']),
      studentName: json['student_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz': quizId,
      'student': studentId,
      'percentage': percentage,
      'quiz_content': quizContent,
      'ai_recommendations': aiRecommendations,
      'date_taken': dateTaken.toIso8601String(),
      'student_name': studentName,
    };
  }
}
