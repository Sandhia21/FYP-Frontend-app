import 'package:dart_openai/dart_openai.dart';

import 'dart:convert';
import 'dart:async';

class AIService {
  static const String _systemPrompt = '''
  You are an educational AI assistant for VirtuLearn, a learning management system.
  Your responses should be educational, accurate, and appropriate for students.
  ''';

  // Initialize OpenAI
  static void initialize({required String apiKey}) {
    OpenAI.apiKey = apiKey;
  }

  // Generate educational notes
  static Future<String> generateNotes({
    required String topic,
  }) async {
    final prompt = '''
    Generate comprehensive educational notes about "$topic".
    Target grade level: undergraduate.
    Include:
    - Key concepts
    - Detailed explanations
    - Examples where applicable
    - Summary points
    Format the response in markdown.
    ''';

    try {
      // Wrap the API call in a timeout
      final response = await Future.any([
        OpenAI.instance.chat.create(
          model: 'gpt-4-turbo-preview',
          messages: [
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.system,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  _systemPrompt,
                ),
              ],
            ),
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  prompt,
                ),
              ],
            ),
          ],
          maxTokens: 2048,
          temperature: 0.7,
        ),
        Future.delayed(const Duration(seconds: 60)).then((_) =>
            throw TimeoutException('Request timed out after 60 seconds')),
      ]);

      final content = response.choices.first.message.content?.first.text;
      if (content == null || content.isEmpty) {
        throw Exception('Empty response from AI');
      }
      return content;
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on RequestFailedException catch (e) {
      if (e.message.contains('rate_limit')) {
        throw Exception(
            'Too many requests. Please wait a moment and try again.');
      } else {
        throw Exception('Failed to generate notes: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to generate notes. Please try again later.');
    }
  }

  // Generate quiz questions
  static Future<String> generateQuiz({
    required String topic,
    required int numberOfQuestions,
    required String difficulty,
  }) async {
    final prompt = '''
Generate a quiz with $numberOfQuestions multiple-choice questions about "$topic".
Format each question exactly as follows:

1. [Question text here]
A) [First option]
B) [Second option]
C) [Third option]
D) [Fourth option]
Correct Answer: [A/B/C/D]

Make sure each question:
- Starts with a number and period
- Has exactly 4 options labeled A) through D)
- Ends with "Correct Answer: " followed by the letter
- Is separated from other questions by a blank line
''';

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo', // Using a faster model for quiz generation
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                _systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                prompt,
              ),
            ],
          ),
        ],
        maxTokens: 2048, // Specify max tokens
        temperature: 0.7, // Add temperature for better variety
      );

      final content = response.choices.first.message.content?.first.text;
      if (content == null) throw Exception('Empty response from AI');
      return content;
    } on RequestFailedException catch (e) {
      // Handle OpenAI specific errors
      if (e.message.contains('timeout')) {
        throw Exception(
            'Request timed out. Please try again with fewer questions or a simpler topic.');
      } else if (e.message.contains('rate_limit')) {
        throw Exception(
            'Too many requests. Please wait a moment and try again.');
      } else {
        throw Exception('Failed to generate quiz: ${e.message}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception(
          'Failed to generate quiz. Please try again later. Error: $e');
    }
  }

  // Generate learning recommendations
  static Future<String> generateRecommendations({
    required List<Map<String, dynamic>> quizResults,
    required String subject,
  }) async {
    final prompt = '''
    Based on the following quiz results, provide personalized learning recommendations:
    ${jsonEncode(quizResults)}
    
    Please provide your recommendations in the following format:

    STRENGTHS:
    - [List of strong areas]

    AREAS FOR IMPROVEMENT:
    - [List of areas needing work]

    TOPICS TO REVIEW:
    - [Specific topics to study]

    RECOMMENDED RESOURCES:
    - [List of helpful resources]

    STUDY STRATEGIES:
    - [List of effective study methods]
    ''';

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-turbo-preview',
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                _systemPrompt,
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                prompt,
              ),
            ],
          ),
        ],
      );

      final content = response.choices.first.message.content?.first.text;
      if (content == null) throw Exception('Empty response from AI');
      return content;
    } catch (e) {
      throw Exception('Failed to generate recommendations: $e');
    }
  }

  // Chat bot for student queries
  static Future<String> getChatResponse({
    required String userQuery,
    List<Map<String, String>>? chatHistory,
  }) async {
    final messages = [
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            _systemPrompt,
          ),
        ],
      ),
    ];

    // Add chat history if available
    if (chatHistory != null) {
      for (var message in chatHistory) {
        messages.add(
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                message['user'] ?? '',
              ),
            ],
          ),
        );
        if (message['assistant'] != null) {
          messages.add(
            OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.assistant,
              content: [
                OpenAIChatCompletionChoiceMessageContentItemModel.text(
                  message['assistant']!,
                ),
              ],
            ),
          );
        }
      }
    }

    // Add current query
    messages.add(
      OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            userQuery,
          ),
        ],
      ),
    );

    try {
      final response = await OpenAI.instance.chat.create(
        model: 'gpt-4-turbo-preview',
        messages: messages,
      );

      final content = response.choices.first.message.content?.first.text;
      if (content == null) throw Exception('Empty response from AI');
      return content;
    } catch (e) {
      throw Exception('Failed to get chat response: $e');
    }
  }
}
