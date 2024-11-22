import 'package:flutter/material.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/registration_screen.dart';
import '../ui/screens/auth/welcome_screen.dart';
import '../ui/screens/course/course_detail_screen.dart';
import '../ui/screens/course/course_list_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/modules/module_detail_screen.dart';
import '../ui/screens/modules/module_list_screen.dart';
import '../ui/screens/notes/note_detail_screen.dart';
import '../ui/screens/notes/note_preview_screen.dart';
import '../ui/screens/home/explore_screen.dart';
import '../ui/screens/quiz/quiz_preview_screen.dart';
import '../ui/screens/notifications/notification_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/quiz/teacher/quiz_management_screen.dart';
import '../ui/screens/quiz/student/quiz_attempt_screen.dart';
import '../ui/screens/quiz/quiz_result_screen.dart';
import '../ui/screens/quiz/teacher/quiz_detail_screen.dart';
import '../data/models/parsed_questions.dart';
import '../ui/screens/quiz/create_quiz_screen.dart';
import '../data/models/quiz.dart';

class AppRoutes {
  // Auth Routes
  static const String welcome = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Main Routes
  static const String home = '/home';

  // Course Routes
  static const String courseList = '/course-list';
  static const String courseDetail = '/course-detail';

  // Module Routes
  static const String moduleList = '/module-list';
  static const String moduleDetail = '/module-detail';

  // Note Routes
  static const String noteDetail = '/note-detail';
  static const String notePreview = '/note-preview';

  // Quiz Routes
  static const String quizzes = '/quizzes';
  static const String quizManagement = '/quiz/management';
  static const String quizDetail = '/quiz/detail';
  static const String quizPreview = '/quiz/preview';
  static const String takeQuiz = '/quiz/take';
  static const String quizResult = '/quiz/result';
  static const String createQuiz = '/quiz/create';

  static const String explore = '/explore';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Routes
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());

      // Main Routes
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // Course Routes
      case courseList:
        return MaterialPageRoute(builder: (_) => const CourseListScreen());

      case courseDetail:
        final courseId = settings.arguments as int?;
        if (courseId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid course ID')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CourseDetailScreen(courseId: courseId),
        );

      // Module Routes
      case moduleList:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('courseId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid module list parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ModuleListScreen(
            courseId: args['courseId'] as int,
          ),
        );

      case moduleDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('moduleId') ||
            !args.containsKey('courseId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid module parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ModuleDetailScreen(
            moduleId: args['moduleId'] as int,
            courseId: args['courseId'] as int,
            isTeacher: args['isTeacher'] as bool? ?? false,
          ),
        );

      // Note Routes
      case noteDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('moduleId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid note parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => NoteDetailScreen(
            moduleId: args['moduleId'] as int,
            noteId: args['noteId'] as int?,
            isTeacher: args['isTeacher'] as bool? ?? false,
          ),
        );

      case notePreview:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('moduleId') ||
            !args.containsKey('topic') ||
            !args.containsKey('content')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid note preview parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => NotePreviewScreen(
            moduleId: args['moduleId'] as int,
            topic: args['topic'] as String,
            initialContent: args['content'] as String,
            isTeacher: args['isTeacher'] as bool? ?? false,
          ),
        );

      // Quiz Routes
      case quizzes:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('moduleId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizManagementScreen(
            moduleId: args['moduleId'] as int,
          ),
        );

      case quizManagement:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('moduleId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz management parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizManagementScreen(
            moduleId: args['moduleId'] as int,
          ),
        );

      case quizDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('moduleId') ||
            !args.containsKey('quizId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizDetailScreen(
            moduleId: args['moduleId'] as int,
            quizId: args['quizId'] as int,
          ),
        );

      case quizPreview:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('title') ||
            !args.containsKey('description') ||
            !args.containsKey('duration') ||
            !args.containsKey('questions')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz preview parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizPreviewScreen(
            title: args['title'] as String,
            description: args['description'] as String,
            duration: args['duration'] as String,
            questions: args['questions'] as List<ParsedQuestion>,
            onApprove: args['onApprove'] as Function(
                String, String, String, List<ParsedQuestion>)?,
          ),
        );

      case takeQuiz:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('moduleId') ||
            !args.containsKey('quizId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => QuizAttemptScreen(
            moduleId: args['moduleId'] as int,
            quizId: args['quizId'] as int,
          ),
        );

      case quizResult:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null ||
            !args.containsKey('moduleId') ||
            !args.containsKey('quizId') ||
            !args.containsKey('score') ||
            !args.containsKey('userAnswers') ||
            !args.containsKey('questions') ||
            !args.containsKey('correctCount') ||
            !args.containsKey('totalQuestions')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz result parameters')),
            ),
          );
        }

        return MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            moduleId: args['moduleId'] as int,
            quizId: args['quizId'] as int,
            score: args['score'] as double,
            userAnswers: List<int>.from(args['userAnswers'] as List),
            questions: List<ParsedQuestion>.from(args['questions'] as List),
            correctCount: args['correctCount'] as int,
            totalQuestions: args['totalQuestions'] as int,
          ),
        );

      // Add this new case
      case explore:
        return MaterialPageRoute(builder: (_) => const ExploreScreen());

      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case createQuiz:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || !args.containsKey('moduleId')) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Invalid quiz creation parameters')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CreateQuizScreen(
            moduleId: args['moduleId'] as int,
            quiz: args['quiz'] as Quiz?, // Optional parameter for editing
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
