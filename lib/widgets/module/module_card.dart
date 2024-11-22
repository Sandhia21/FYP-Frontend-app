import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../data/models/module.dart';
import 'module_crud_dialog.dart';
import 'package:provider/provider.dart';
import '../../../providers/module_provider.dart';

class ModuleCard extends StatelessWidget {
  final Module module;
  final VoidCallback onTap;
  final bool isInstructor;

  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
    this.isInstructor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: Dimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.borderRadiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    color: AppColors.primary,
                    size: Dimensions.iconMd,
                  ),
                  const SizedBox(width: Dimensions.sm),
                  Expanded(
                    child: Text(
                      module.title,
                      style: TextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isInstructor)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          if (!context.mounted) return;
                          final result = await showDialog(
                            context: context,
                            builder: (context) => ModuleCrudDialog(
                              module: module,
                              courseId: module.courseId,
                            ),
                          );
                          if (result == true && context.mounted) {
                            // Refresh modules list
                            final moduleProvider = Provider.of<ModuleProvider>(
                                context,
                                listen: false);
                            await moduleProvider.fetchModules(module.courseId);
                          }
                        } else if (value == 'delete') {
                          if (!context.mounted) return;
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Module'),
                              content: const Text(
                                  'Are you sure you want to delete this module?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            final moduleProvider = Provider.of<ModuleProvider>(
                                context,
                                listen: false);
                            await moduleProvider.deleteModule(module.id);
                            // Refresh the list after deletion
                            await moduleProvider.fetchModules(module.courseId);
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Module'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Module'),
                        ),
                      ],
                    ),
                ],
              ),
              if (module.description.isNotEmpty) ...[
                const SizedBox(height: Dimensions.sm),
                Text(
                  module.description,
                  style: TextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
