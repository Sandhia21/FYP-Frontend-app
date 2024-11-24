import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:app/constants/constants.dart';
import 'package:app/widgets/common/app_bar.dart';
import 'package:app/widgets/common/bottom_navigation.dart';
import 'package:app/widgets/common/loading_overlay.dart';
import 'package:app/widgets/home/stats_card.dart';
import 'package:app/widgets/home/course_card.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/course_provider.dart';
import 'package:app/services/routes.dart';
import 'package:app/data/models/course.dart';
import 'package:app/widgets/course/course_crud_dialog.dart';
import 'package:app/ui/screens/home/explore_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late MotionTabBarController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = MotionTabBarController(
      initialIndex: 0,
      length: 4,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    await courseProvider.fetchCourses();
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Course> _getFilteredCourses(List<Course> courses) {
    if (_searchQuery.isEmpty) return courses;
    return courses
        .where((course) =>
            course.name.toLowerCase().contains(_searchQuery) ||
            course.description.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _showCreateCourseDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: CourseCrudDialog(
          onSubmit: (Course course, String? imagePath) async {
            if (imagePath != null) {
              await Provider.of<CourseProvider>(context, listen: false)
                  .createCourseWithImage(course, imagePath);
            } else {
              await Provider.of<CourseProvider>(context, listen: false)
                  .createCourse(course);
            }
          },
        ),
      ),
    );

    if (result == true && mounted) {
      await _loadInitialData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final user = authProvider.user;

    // Get relevant courses based on user role
    final relevantCourses = authProvider.relevantCourses;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'VirtuLearn',
        showBackButton: false,
        showSearch: true,
        hideProfileIcon: true,
        onSearchChanged: _handleSearch,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LoadingOverlay(
          isLoading: courseProvider.isLoading || authProvider.isLoading,
          child: RefreshIndicator(
            onRefresh: _loadInitialData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (user?.role == 'student') ...[
                        Padding(
                          padding: const EdgeInsets.all(Dimensions.lg),
                          child: Row(
                            children: [
                              Expanded(
                                child: StatsCard(
                                  title: 'Courses',
                                  value: relevantCourses.length.toString(),
                                  icon: Icons.book_outlined,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primaryLight
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.lg,
                          vertical: Dimensions.md,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user?.role == 'teacher'
                                  ? 'Your Courses'
                                  : 'Enrolled Courses',
                              style: TextStyles.h2,
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ExploreScreen()),
                                  );
                                },
                                child: const Text('See All'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.md,
                    vertical: Dimensions.sm,
                  ),
                  sliver: Consumer<CourseProvider>(
                    builder: (context, courseProvider, child) {
                      if (courseProvider.error != null) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              courseProvider.error!,
                              style: TextStyles.error,
                            ),
                          ),
                        );
                      }

                      final filteredCourses =
                          _getFilteredCourses(relevantCourses);

                      if (filteredCourses.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(Dimensions.lg),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.school_outlined,
                                    size: 64,
                                    color: AppColors.grey,
                                  ),
                                  const SizedBox(height: Dimensions.md),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No courses match your search'
                                        : user?.role == 'teacher'
                                            ? 'You haven\'t created any courses yet'
                                            : 'You haven\'t enrolled in any courses yet',
                                    style: TextStyles.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: Dimensions.md),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                      child: const Text('Clear Search'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return CourseCard(
                              course: filteredCourses[index],
                              showActiveStatus: true,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.courseDetail,
                                arguments: filteredCourses[index].id,
                              ),
                            );
                          },
                          childCount: filteredCourses.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: user?.role == 'teacher'
          ? FloatingActionButton(
              onPressed: _showCreateCourseDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
