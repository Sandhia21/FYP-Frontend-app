import 'package:app/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/theme.dart';
import 'services/routes.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/module_provider.dart';
import 'providers/note_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/result_provider.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/repositories/enrollment_repository.dart';
import 'data/repositories/module_repository.dart';
import 'data/repositories/note_repository.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/result_repository.dart';

// Services
import 'services/auth_api_service.dart';
import 'services/course_api_service.dart';
import 'services/enrollment_api_service.dart';
import 'services/module_api_service.dart';
import 'services/note_api_service.dart';
import 'services/quiz_api_service.dart';
import 'services/result_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AIService.initialize(
      apiKey:
          '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');

  // Initialize API services
  final authService = AuthApiService();
  final courseService = CourseApiService();
  final enrollmentService = EnrollmentApiService();
  final moduleService = ModuleApiService();
  final noteService = NoteApiService();
  final quizService = QuizApiService();
  final resultService = ResultApiService();

  // Initialize repositories
  final authRepository = AuthRepository(authService);
  final courseRepository = CourseRepository(courseService);
  final enrollmentRepository = EnrollmentRepository(enrollmentService);
  final moduleRepository = ModuleRepository(moduleService);
  final noteRepository = NoteRepository(noteService);
  final quizRepository = QuizRepository(quizService);
  final resultRepository = ResultRepository(resultService);

  runApp(MyApp(
    authRepository: authRepository,
    courseRepository: courseRepository,
    enrollmentRepository: enrollmentRepository,
    moduleRepository: moduleRepository,
    noteRepository: noteRepository,
    quizRepository: quizRepository,
    resultRepository: resultRepository,
    moduleService: moduleService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final CourseRepository courseRepository;
  final EnrollmentRepository enrollmentRepository;
  final ModuleRepository moduleRepository;
  final NoteRepository noteRepository;
  final QuizRepository quizRepository;
  final ResultRepository resultRepository;
  final ModuleApiService moduleService;

  const MyApp({
    Key? key,
    required this.authRepository,
    required this.courseRepository,
    required this.enrollmentRepository,
    required this.moduleRepository,
    required this.noteRepository,
    required this.quizRepository,
    required this.resultRepository,
    required this.moduleService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository),
        ),

        // Course Provider
        ChangeNotifierProvider(
          create: (_) => CourseProvider(courseRepository),
        ),

        // Enrollment Provider
        ChangeNotifierProvider(
          create: (_) => EnrollmentProvider(enrollmentRepository),
        ),

        // Module Provider
        ChangeNotifierProvider(
          create: (_) => ModuleProvider(moduleService),
        ),

        // Note Provider
        ChangeNotifierProvider(
          create: (_) => NoteProvider(noteRepository),
        ),

        // Quiz Provider
        ChangeNotifierProvider(
          create: (_) =>
              QuizProvider(quizRepository), // Updated to use repository
        ),

        // Result Provider
        ChangeNotifierProvider(
          create: (_) => ResultProvider(resultRepository),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            title: 'LearnSmart',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            debugShowCheckedModeBanner: false,
            initialRoute: authProvider.isAuthenticated
                ? AppRoutes.home
                : AppRoutes.welcome,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
