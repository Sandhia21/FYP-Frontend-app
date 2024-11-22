// import 'package:flutter/material.dart';
// import '../../../constants/colors.dart';
// import '../../../constants/dimensions.dart';
// import '../../../constants/text_styles.dart';
// import '../../../data/models/course.dart';

// class CourseCard extends StatelessWidget {
//   final Course course;
//   final VoidCallback onTap;

//   const CourseCard({
//     Key? key,
//     required this.course,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
//         child: Padding(
//           padding: const EdgeInsets.all(Dimensions.md),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 course.name, // Changed from title to name
//                 style: TextStyles.h3,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: Dimensions.sm),
//               Text(
//                 course.description,
//                 style: TextStyles.bodyMedium.copyWith(
//                   color: AppColors.grey,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: Dimensions.md),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.people_outline,
//                         size: Dimensions.iconSm,
//                         color: AppColors.grey,
//                       ),
//                       const SizedBox(width: Dimensions.xs),
//                       Text(
//                         '${course.students.length} students', // Using students list length
//                         style: TextStyles.caption.copyWith(
//                           color: AppColors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.code, // Changed to code icon
//                         size: Dimensions.iconSm,
//                         color: AppColors.grey,
//                       ),
//                       const SizedBox(width: Dimensions.xs),
//                       Text(
//                         course
//                             .courseCode, // Using courseCode instead of moduleCount
//                         style: TextStyles.caption.copyWith(
//                           color: AppColors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../data/models/course.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool showActiveStatus;

  const CourseCard({
    Key? key,
    required this.course,
    required this.onTap,
    this.showActiveStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Course Image Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                      ? Image.network(
                          course.imageUrl!,
                          fit: BoxFit.cover,
                          height: 100,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage(
                                'Image not available');
                          },
                        )
                      : _buildPlaceholderImage('No Image'),
                ),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Course Details Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.name,
                    style: TextStyles.h3.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${course.students.length} Students',
                            style: TextStyles.bodySmall.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (showActiveStatus)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Active',
                            style: TextStyles.caption.copyWith(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(String text) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
