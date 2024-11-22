import 'parsed_questions.dart';
import '../../widgets/quiz/quiz_format_controller.dart';

class Quiz {
  final int id;
  final int moduleId;
  final String title;
  final String description;
  final String content;
  final int createdBy;
  final DateTime createdAt;
  final bool isAIGenerated;
  final String? note;
  final int maxAttempts;
  final int quizDuration;
  late final List<ParsedQuestion> parsedQuestions;

  Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    required this.isAIGenerated,
    this.note,
    required this.maxAttempts,
    required this.quizDuration,
  }) {
    parsedQuestions = QuizFormatController().parseQuizContent(content);
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      moduleId: json['module'],
      title: json['title'],
      description: json['description'] ?? '',
      content: json['content'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      isAIGenerated: json['from_ai'] ?? false,
      note: json['note'],
      maxAttempts: json['max_attempts'] ?? 1,
      quizDuration: json['quiz_duration'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': moduleId,
      'title': title,
      'description': description,
      'content': content,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'from_ai': isAIGenerated,
      'note': note,
      'max_attempts': maxAttempts,
      'quiz_duration': quizDuration,
    };
  }

  Quiz copyWith({
    int? id,
    int? moduleId,
    String? title,
    String? description,
    String? content,
    int? createdBy,
    DateTime? createdAt,
    bool? isAIGenerated,
    String? note,
    int? maxAttempts,
    int? quizDuration,
  }) {
    return Quiz(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      note: note ?? this.note,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      quizDuration: quizDuration ?? this.quizDuration,
    );
  }

  String formatQuestions(List<ParsedQuestion> questions) {
    final controller = QuizFormatController();
    return controller.formatQuizContent(questions);
  }
}
