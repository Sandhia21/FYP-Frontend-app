import '../../data/models/parsed_questions.dart';

class QuizFormatController {
  static final QuizFormatController _instance =
      QuizFormatController._internal();

  QuizFormatController._internal();
  factory QuizFormatController() => _instance;

  // Format quiz content to standardized string format
  String formatQuizContent(List<ParsedQuestion> questions) {
    final buffer = StringBuffer();

    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      buffer.writeln('${i + 1}. ${q.question}');

      for (var j = 0; j < q.options.length; j++) {
        buffer.writeln('${String.fromCharCode(65 + j)}) ${q.options[j]}');
      }

      buffer.writeln(
          'Correct Answer: ${String.fromCharCode(65 + q.correctOptionIndex)}');
      if (i < questions.length - 1) buffer.writeln();
    }

    return buffer.toString().trim();
  }

  // Parse string content into structured questions
  List<ParsedQuestion> parseQuizContent(String content) {
    final List<ParsedQuestion> questions = [];
    final questionBlocks = content.split('\n\n');

    for (var block in questionBlocks) {
      if (block.trim().isEmpty) continue;

      final lines = block.split('\n');
      if (lines.length < 6) continue;

      final questionText =
          lines[0].replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();
      final options = lines.sublist(1, 5).map((line) {
        return line.replaceFirst(RegExp(r'^[A-D]\)\s*'), '').trim();
      }).toList();

      final correctAnswerLine = lines.lastWhere(
        (line) => line.startsWith('Correct Answer:'),
        orElse: () => 'Correct Answer: A',
      );
      final correctAnswer = correctAnswerLine.split(':').last.trim();
      final correctIndex = correctAnswer.codeUnitAt(0) - 'A'.codeUnitAt(0);

      questions.add(ParsedQuestion(
        question: questionText,
        options: options,
        correctOptionIndex: correctIndex,
      ));
    }

    return questions;
  }

  // Validate quiz format
  bool isValidQuizFormat(String content) {
    try {
      final questions = parseQuizContent(content);
      return questions.isNotEmpty;
    } catch (e) {
      print('Validation error: $e');
      return false;
    }
  }

  // Generate empty question template
  String generateEmptyTemplate(int questionCount) {
    final buffer = StringBuffer();

    for (var i = 0; i < questionCount; i++) {
      buffer.writeln('${i + 1}. Question: [Enter question here]');
      buffer.writeln('A) [Option 1]');
      buffer.writeln('B) [Option 2]');
      buffer.writeln('C) [Option 3]');
      buffer.writeln('D) [Option 4]');
      buffer.writeln('Correct Answer: [A/B/C/D]');
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  // Add scoring method
  double calculateScore(List<int> answers, List<ParsedQuestion> questions) {
    if (questions.isEmpty) return 0.0;

    int correctAnswers = 0;
    for (int i = 0; i < answers.length && i < questions.length; i++) {
      if (questions[i].isCorrectIndex(answers[i])) {
        correctAnswers++;
      }
    }

    return (correctAnswers / questions.length) * 100;
  }
}
