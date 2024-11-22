class QuizAttemptInfo {
  final int quizId;
  final String quizTitle;
  final int maxAttempts;
  final int attemptsMade;
  final int remainingAttempts;
  final bool canAttempt;

  QuizAttemptInfo({
    required this.quizId,
    required this.quizTitle,
    required this.maxAttempts,
    required this.attemptsMade,
    required this.remainingAttempts,
    required this.canAttempt,
  });

  factory QuizAttemptInfo.fromJson(Map<String, dynamic> json) {
    return QuizAttemptInfo(
      quizId: json['quiz_id'],
      quizTitle: json['quiz_title'],
      maxAttempts: json['max_attempts'],
      attemptsMade: json['attempts_made'],
      remainingAttempts: json['remaining_attempts'],
      canAttempt: json['can_attempt'],
    );
  }
}
