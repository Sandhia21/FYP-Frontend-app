import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../data/models/course.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_overlay.dart';

class CourseCrudDialog extends StatefulWidget {
  final Course? course;

  const CourseCrudDialog({
    Key? key,
    this.course,
  }) : super(key: key);

  @override
  State<CourseCrudDialog> createState() => _CourseCrudDialogState();
}

class _CourseCrudDialogState extends State<CourseCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _error;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.course?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.course?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courseProvider =
          Provider.of<CourseProvider>(context, listen: false);

      if (isEditing) {
        // Update existing course
        final updatedCourse = widget.course!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );
        await courseProvider.updateCourse(updatedCourse);
      } else {
        // Create new course
        final newCourse = Course.forCreate(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          courseCode: '', // Empty for new courses as it's handled by backend
        );
        await courseProvider.createCourse(newCourse);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                isEditing ? 'Edit Course' : 'Create Course',
                style: TextStyles.h2,
              ),
              const SizedBox(height: Dimensions.md),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Course Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Course Name',
                        hintText: 'Enter course name',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a course name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Dimensions.md),

                    // Course Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter course description',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.md),

              // Error Message
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TextStyles.error,
                ),
                const SizedBox(height: Dimensions.md),
              ],

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.of(context).pop(false),
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: Dimensions.md),
                  Expanded(
                    child: CustomButton(
                      text: isEditing ? 'Update' : 'Create',
                      onPressed: _handleSubmit,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
