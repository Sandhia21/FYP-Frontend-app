import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../data/models/course.dart';

class CourseInfoSection extends StatelessWidget {
  final Course course;

  const CourseInfoSection({
    Key? key,
    required this.course,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.name,
            style: TextStyles.h2,
          ),
          const SizedBox(height: Dimensions.sm),
          Text(
            course.description,
            style: TextStyles.bodyMedium,
          ),
          const SizedBox(height: Dimensions.md),
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: Dimensions.iconSm,
                color: AppColors.grey,
              ),
              const SizedBox(width: Dimensions.xs),
              Text(
                'Instructor: ${course.createdByUsername}',
                style: TextStyles.caption.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.sm),
          Row(
            children: [
              const Icon(
                Icons.code,
                size: Dimensions.iconSm,
                color: AppColors.grey,
              ),
              const SizedBox(width: Dimensions.xs),
              Text(
                'Course Code: ${course.courseCode}',
                style: TextStyles.caption.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.sm),
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: Dimensions.iconSm,
                color: AppColors.grey,
              ),
              const SizedBox(width: Dimensions.xs),
              Text(
                '${course.students.length} students enrolled',
                style: TextStyles.caption.copyWith(
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
