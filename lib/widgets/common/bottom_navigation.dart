import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';
import 'package:app/constants/constants.dart';

class BottomNavigation extends StatelessWidget {
  final MotionTabBarController controller;
  final int currentIndex;

  const BottomNavigation({
    Key? key,
    required this.controller,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      controller: controller,
      initialSelectedTab: "Home",
      labels: const ["Home", "Courses", "Quizzes", "Profile"],
      icons: const [
        Icons.home_outlined,
        Icons.menu_book_outlined,
        Icons.quiz_outlined,
        Icons.person_outline,
      ],
      badges: const [null, null, null, null],
      tabSize: 50,
      tabBarHeight: 55,
      textStyle: TextStyles.caption.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      tabIconColor: AppColors.grey,
      tabIconSize: 28.0,
      tabIconSelectedSize: 26.0,
      tabSelectedColor: AppColors.primary,
      tabIconSelectedColor: AppColors.white,
      tabBarColor: AppColors.white,
      onTabItemSelected: (int value) {
        controller.index = value;
      },
    );
  }
}
