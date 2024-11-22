class ParsedQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  ParsedQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  // Helper getter to get correct answer text
  String get correctAnswer => options[correctOptionIndex];

  // Helper method to check if an answer is correct
  bool isCorrectAnswer(String answer) {
    return answer == correctAnswer;
  }

  // Helper method to check if an option index is correct
  bool isCorrectIndex(int index) {
    return index == correctOptionIndex;
  }

  // Add method to convert to content string format
  String toContentString(int questionNumber) {
    final buffer = StringBuffer();
    buffer.writeln('Question $questionNumber: $question');

    for (var i = 0; i < options.length; i++) {
      buffer.writeln('${String.fromCharCode(65 + i)}) ${options[i]}');
    }

    buffer.writeln(
        'Correct Answer: ${String.fromCharCode(65 + correctOptionIndex)}');
    return buffer.toString();
  }

  // Add validation method
  static String? validate({
    required String question,
    required List<String> options,
    required int correctOptionIndex,
  }) {
    if (question.isEmpty) return 'Question cannot be empty';
    if (options.length < 2) return 'At least 2 options are required';
    if (options.any((option) => option.isEmpty)) {
      return 'All options must have content';
    }
    if (correctOptionIndex < 0 || correctOptionIndex >= options.length) {
      return 'Invalid correct option index';
    }
    return null;
  }
}
