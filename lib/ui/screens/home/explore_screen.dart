import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants/constants.dart';
import 'package:app/widgets/common/app_bar.dart';
import 'package:app/widgets/common/loading_overlay.dart';
import 'package:app/widgets/home/course_card.dart';
import 'package:app/providers/course_provider.dart';
import 'package:app/services/routes.dart';
import 'package:app/data/models/course.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Explore Courses',
        showBackButton: true,
        hideProfileIcon: true,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Consumer<CourseProvider>(
          builder: (context, courseProvider, child) {
            return LoadingOverlay(
              isLoading: courseProvider.isLoading,
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.md),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _handleSearch,
                      decoration: InputDecoration(
                        hintText: 'Search courses...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _handleSearch('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.borderRadiusMd),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.borderRadiusMd),
                          borderSide: const BorderSide(
                            color: AppColors.inputBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.borderRadiusMd),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Courses Grid
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => courseProvider.fetchCourses(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (courseProvider.error != null)
                            SliverToBoxAdapter(
                              child: Center(
                                child: Text(
                                  courseProvider.error!,
                                  style: TextStyles.error,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: const EdgeInsets.all(Dimensions.md),
                              sliver: _buildCoursesGrid(courseProvider),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCoursesGrid(CourseProvider courseProvider) {
    final filteredCourses = _getFilteredCourses(courseProvider.courses);

    if (filteredCourses.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
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
                    : 'No courses available',
                style: TextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return CourseCard(
            course: filteredCourses[index],
            showActiveStatus: false,
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
  }
}
