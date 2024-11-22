import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../data/models/course.dart';
import '../../../providers/course_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_overlay.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../constants/button_variant.dart';

class CourseCrudDialog extends StatefulWidget {
  final Course? course;
  final Function(Course course, String? imagePath)? onSubmit;

  const CourseCrudDialog({
    Key? key,
    this.course,
    this.onSubmit,
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
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final courseData = isEditing
          ? widget.course!.copyWith(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
            )
          : Course.forCreate(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              courseCode: '',
            );

      if (widget.onSubmit != null) {
        await widget.onSubmit!(courseData, _selectedImage?.path);
      } else {
        final courseProvider =
            Provider.of<CourseProvider>(context, listen: false);
        if (isEditing) {
          await courseProvider.updateCourse(courseData);
        } else {
          if (_selectedImage != null) {
            await courseProvider.createCourseWithImage(
                courseData, _selectedImage!.path);
          } else {
            await courseProvider.createCourse(courseData);
          }
        }
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
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Dimensions.md,
        vertical: Dimensions.lg,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusLg),
      ),
      child: LoadingOverlay(
        isLoading: _isLoading,
        child: Container(
          width: screenSize.width,
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: screenSize.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(Dimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.borderRadiusLg),
                    topRight: Radius.circular(Dimensions.borderRadiusLg),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isEditing ? Icons.edit_note : Icons.add_box_rounded,
                      color: AppColors.primary,
                      size: Dimensions.iconLg,
                    ),
                    const SizedBox(width: Dimensions.md),
                    Text(
                      isEditing ? 'Edit Course' : 'Create New Course',
                      style: TextStyles.h3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Picker
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey,
                            borderRadius: BorderRadius.circular(
                                Dimensions.borderRadiusMd),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                            ),
                          ),
                          child: _selectedImage != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.borderRadiusMd),
                                      child: Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: Dimensions.sm,
                                      right: Dimensions.sm,
                                      child: CustomButton(
                                        icon: Icons.edit,
                                        text: 'Change',
                                        onPressed: _pickImage,
                                        backgroundColor:
                                            AppColors.primary.withOpacity(0.9),
                                        textColor: AppColors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_rounded,
                                      size: Dimensions.iconLg,
                                      color: AppColors.primary.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: Dimensions.sm),
                                    Text(
                                      'Add Course Image',
                                      style: TextStyles.bodyMedium.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.xl),

                      // Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Course Name',
                                hintText: 'Enter the name of your course',
                                prefixIcon: const Icon(
                                  Icons.school,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.borderRadiusMd),
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundGrey,
                              ),
                              style: TextStyles.input,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a course name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: Dimensions.lg),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Description',
                                hintText: 'Enter course description',
                                prefixIcon: const Icon(
                                  Icons.description,
                                  color: AppColors.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.borderRadiusMd),
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundGrey,
                              ),
                              style: TextStyles.input,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a course description';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      if (_error != null) ...[
                        const SizedBox(height: Dimensions.md),
                        Container(
                          padding: const EdgeInsets.all(Dimensions.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                Dimensions.borderRadiusMd),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.error),
                              const SizedBox(width: Dimensions.sm),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyles.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.all(Dimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.divider.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                        variant: ButtonVariant.outlined,
                        backgroundColor: AppColors.surface,
                        textColor: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: Dimensions.md),
                    Expanded(
                      child: CustomButton(
                        text: isEditing ? 'Update Course' : 'Create Course',
                        onPressed: _handleSubmit,
                        isLoading: _isLoading,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
