import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/enrollment_provider.dart';
import '../common/custom_text_field.dart';
import '../common/custom_button.dart';
import '../../providers/auth_provider.dart';

class EnrollmentDialog extends StatefulWidget {
  final int courseId;

  const EnrollmentDialog({
    super.key,
    required this.courseId,
  });

  @override
  State<EnrollmentDialog> createState() => _EnrollmentDialogState();
}

class _EnrollmentDialogState extends State<EnrollmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitEnrollment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final enrollmentProvider = Provider.of<EnrollmentProvider>(
        context,
        listen: false,
      );

      // Check if already enrolled
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProfile = authProvider.user;

      if (userProfile?.enrolledCourses
              .any((course) => course['id'] == widget.courseId) ??
          false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already enrolled in this course'),
            ),
          );
          Navigator.of(context).pop(false);
        }
        return;
      }

      final result = await enrollmentProvider.enrollInCourse(
        widget.courseId,
        _codeController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully enrolled in course'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enroll in Course'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter the course code to enroll.',
              style: TextStyles.bodyMedium,
            ),
            const SizedBox(height: Dimensions.md),
            CustomTextField(
              controller: _codeController,
              labelText: 'Course Code',
              enabled: !_isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the course code';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: 'Enroll',
          onPressed:
              _isLoading ? null : _submitEnrollment, // Use the async method
          isLoading: _isLoading,
          width: 100,
        ),
      ],
    );
  }
}
