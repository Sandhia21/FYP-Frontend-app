import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/constants.dart';
import '../../../data/models/module.dart';
import '../../../providers/module_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_overlay.dart';

class ModuleCrudDialog extends StatefulWidget {
  final Module? module;
  final int courseId;

  const ModuleCrudDialog({
    super.key,
    this.module,
    required this.courseId,
  });

  @override
  State<ModuleCrudDialog> createState() => _ModuleCrudDialogState();
}

class _ModuleCrudDialogState extends State<ModuleCrudDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;
  String? _error;

  bool get isEditing => widget.module != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.module?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.module?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
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
      final moduleProvider =
          Provider.of<ModuleProvider>(context, listen: false);

      if (isEditing) {
        await moduleProvider.updateModule(
          widget.module!.id,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
          widget.courseId,
        );
      } else {
        await moduleProvider.createModule(
          widget.courseId,
          _titleController.text.trim(),
          _descriptionController.text.trim(),
        );
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
                isEditing ? 'Edit Module' : 'Create Module',
                style: TextStyles.h2,
              ),
              const SizedBox(height: Dimensions.md),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Module Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Module Title',
                        hintText: 'Enter module title',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a module title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Dimensions.md),

                    // Module Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter module description',
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
