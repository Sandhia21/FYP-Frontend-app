import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/widgets.dart';
import '../../../widgets/course/course_crud_dialog.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCourses();
    });
  }

  Future<void> _loadCourses() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.fetchCourses();
  }

  Future<void> _showCreateCourseDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const CourseCrudDialog(),
    );

    if (result == true && mounted) {
      _loadCourses(); // Refresh the list after creation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isTeacher = authProvider.user?.role == 'teacher';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTeacher ? 'My Courses' : 'Available Courses',
          style: TextStyles.h2.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          return LoadingOverlay(
            isLoading: courseProvider.isLoading,
            child: RefreshIndicator(
              onRefresh: _loadCourses,
              child: courseProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            courseProvider.error!,
                            style: TextStyles.error,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: Dimensions.md),
                          CustomButton(
                            text: 'Retry',
                            onPressed: _loadCourses,
                            width: 120,
                          ),
                        ],
                      ),
                    )
                  : courseProvider.courses.isEmpty
                      ? Center(
                          child: Text(
                            isTeacher
                                ? 'You haven\'t created any courses yet'
                                : 'No courses available',
                            style: TextStyles.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(Dimensions.md),
                          itemCount: courseProvider.courses.length,
                          itemBuilder: (context, index) {
                            final course = courseProvider.courses[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: Dimensions.md),
                              child: CourseCard(
                                course: course,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/course-detail',
                                  arguments: course.id,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          );
        },
      ),
      floatingActionButton: isTeacher
          ? FloatingActionButton(
              onPressed: _showCreateCourseDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
