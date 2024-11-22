import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/gradient_background.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../data/models/profile.dart';

import '../../../data/models/course.dart';
import '../../../ui/screens/modules/module_list_screen.dart';
import '../../../widgets/course/course_crud_dialog.dart';
import '../../../widgets/module/module_crud_dialog.dart';
import '../../../providers/module_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/enrollment/enrollment_dialog.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;

  const CourseDetailScreen({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() => _isInitializing = true);

    try {
      // Load data in parallel
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);
      final moduleProvider =
          Provider.of<ModuleProvider>(context, listen: false);

      await Future.wait([
        authProvider.fetchProfile(),
        courseProvider.getCourseDetail(widget.courseId),
      ]);

      // Only fetch modules if course loaded successfully
      if (courseProvider.selectedCourse.id != 0) {
        await moduleProvider.fetchModules(courseProvider.selectedCourse.id);
      }

      // Add a small delay to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading course: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  Future<void> _showEditCourseDialog(Course course) async {
    final result = await showDialog(
      context: context,
      builder: (context) => CourseCrudDialog(course: course),
    );

    if (result == true && mounted) {
      await _refreshData(); // Refresh all data after edit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );
    }
  }

  Future<void> _showAddModuleDialog(int courseId) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ModuleCrudDialog(courseId: courseId),
      );

      if (result == true && mounted) {
        await _refreshData(); // Refresh all data after adding module
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module created successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating module: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, int courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: const Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final courseProvider =
            Provider.of<CourseProvider>(context, listen: false);
        await courseProvider.deleteCourse(courseId);
        if (mounted) {
          Navigator.pop(context); // Return to course list
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Course deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting course: ${e.toString()}')),
          );
        }
      }
    }
  }

  bool _isTeacherAndOwner(Course course, Profile? userProfile) {
    return userProfile != null &&
        userProfile.role == 'teacher' &&
        course.createdByUsername == userProfile.username;
  }

  bool _isStudentEnrolled(Course course, Profile? userProfile) {
    return userProfile != null &&
        userProfile.role == 'student' &&
        userProfile.enrolledCourses
            .any((enrolledCourse) => enrolledCourse['id'] == course.id);
  }

  Future<void> _enrollInCourse(int courseId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProfile = authProvider.user;

    // Check if already enrolled
    if (userProfile?.enrolledCourses
            .any((course) => course['id'] == courseId) ??
        false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are already enrolled in this course'),
          ),
        );
      }
      return;
    }

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => EnrollmentDialog(courseId: courseId),
      );

      if (result == true && mounted) {
        // Refresh the user profile to get updated enrolled courses
        await authProvider.fetchProfile();

        // Refresh the course details
        await Provider.of<CourseProvider>(context, listen: false)
            .getCourseDetail(courseId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully enrolled in course')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error enrolling in course: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CourseProvider, AuthProvider>(
      builder: (context, courseProvider, authProvider, _) {
        final course = courseProvider.selectedCourse;
        final isLoading = courseProvider.isLoading || _isInitializing;
        final error = courseProvider.error;
        final userProfile = authProvider.profile;

        final isTeacherAndOwner = _isTeacherAndOwner(course, userProfile);
        final isStudentEnrolled = _isStudentEnrolled(course, userProfile);

        return Scaffold(
          appBar: CustomAppBar(
            title: course.name.isEmpty ? 'Course Details' : course.name,
            actions: isTeacherAndOwner && course.id != 0
                ? [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.white),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _showEditCourseDialog(course);
                        } else if (value == 'delete') {
                          await _showDeleteConfirmation(context, course.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Course'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Course'),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: LoadingOverlay(
            isLoading: isLoading,
            child: GradientBackground(
              colors: const [AppColors.background, AppColors.surface],
              child: error != null
                  ? _buildErrorState(error)
                  : course.id == 0 && !isLoading
                      ? _buildEmptyState()
                      : _buildContent(course),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              'Error Loading Course',
              style: TextStyles.h3.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: Dimensions.sm),
            Text(
              error,
              style: TextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.lg),
            CustomButton(
              text: 'Retry',
              onPressed: _initializeData,
              width: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: AppColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: Dimensions.md),
          Text(
            'Course Not Found',
            style: TextStyles.h3.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Course course) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userProfile = authProvider.profile;
        final isTeacherAndOwner = _isTeacherAndOwner(course, userProfile);
        final isStudentEnrolled = _isStudentEnrolled(course, userProfile);
        final isStudent = userProfile?.role == 'student';

        // Debug log - move outside of widget tree
        debugPrint(
            'isTeacherAndOwner: $isTeacherAndOwner, isStudentEnrolled: $isStudentEnrolled');
        debugPrint('userProfile role: ${userProfile?.role}');
        debugPrint('course creator: ${course.createdByUsername}');
        debugPrint('userProfile username: ${userProfile?.username}');
        debugPrint('enrolled courses: ${userProfile?.enrolledCourses}');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Image Section
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.sm),
                child: course.imageUrl.isNotEmpty
                    ? Image.network(
                        course.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/default_course.png',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: Dimensions.lg),

              // Instructor Info Section
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage:
                        AssetImage('assets/images/default_profile.png'),
                    radius: 20,
                  ),
                  const SizedBox(width: Dimensions.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Course by',
                        style: TextStyles.bodySmall,
                      ),
                      Text(
                        course.createdByUsername,
                        style: TextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.xl),

              // Course Overview Section
              Text(
                'Course Overview',
                style: TextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: Dimensions.md),
              Text(
                course.description,
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: Dimensions.md),
              Text(
                'Course Code: ${course.courseCode}',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              // Students Count
              const SizedBox(height: Dimensions.md),
              Row(
                children: const [
                  Icon(
                    Icons.group_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  SizedBox(width: Dimensions.xs),
                  Text(
                    'students enrolled',
                    style: TextStyles.bodyMedium,
                  ),
                ],
              ),

              // Module List Section - Show for both enrolled students and teacher owner
              if (isTeacherAndOwner || isStudentEnrolled) ...[
                const SizedBox(height: Dimensions.xl),
                Text(
                  'Course Modules',
                  style: TextStyles.h3.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Dimensions.md),
                Text(
                  isStudentEnrolled
                      ? 'Access your course materials below'
                      : 'Manage your course modules',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: Dimensions.md),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(Dimensions.borderRadiusMd),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: Consumer<ModuleProvider>(
                    builder: (context, moduleProvider, _) {
                      if (_isInitializing) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: Dimensions.md),
                              Text('Loading course content...'),
                            ],
                          ),
                        );
                      }

                      final modules = moduleProvider.modules;
                      final error = moduleProvider.error;

                      if (error != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error, size: 48),
                              const SizedBox(height: Dimensions.sm),
                              Text(
                                'Error loading modules: $error',
                                style: TextStyles.bodyMedium
                                    .copyWith(color: AppColors.error),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: Dimensions.md),
                              CustomButton(
                                text: 'Retry',
                                onPressed: _initializeData,
                                width: 120,
                              ),
                            ],
                          ),
                        );
                      }

                      if (modules.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_outlined,
                                size: 48,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: Dimensions.sm),
                              Text(
                                'No modules available yet',
                                style: TextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ModuleListScreen(
                        key: ValueKey('modules-${course.id}'),
                        courseId: course.id,
                        embedded: true,
                        isTeacher: isTeacherAndOwner,
                      );
                    },
                  ),
                ),
              ],

              // Teacher Actions Section
              if (isTeacherAndOwner) ...[
                const SizedBox(height: Dimensions.xl),
                CustomButton(
                  text: 'Add Module',
                  onPressed: () => _showAddModuleDialog(course.id),
                  backgroundColor: AppColors.primary,
                  width: double.infinity,
                ),
                const SizedBox(height: Dimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Edit Course',
                        onPressed: () => _showEditCourseDialog(course),
                        backgroundColor: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: CustomButton(
                        text: 'Delete Course',
                        onPressed: () =>
                            _showDeleteConfirmation(context, course.id),
                        backgroundColor: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],

              // Student Enrollment Section
              if (isStudent && !isStudentEnrolled) ...[
                const SizedBox(height: Dimensions.xl),
                CustomButton(
                  text: 'Enroll in Course',
                  onPressed: () => _enrollInCourse(course.id),
                  backgroundColor: AppColors.primary,
                  width: double.infinity,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
