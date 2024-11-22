import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/constants/constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/module_provider.dart';
import '../common/custom_button.dart';
import '../common/loading_overlay.dart';
import 'module_crud_dialog.dart';

class ModuleListSection extends StatefulWidget {
  final int courseId;

  const ModuleListSection({
    Key? key,
    required this.courseId,
  }) : super(key: key);

  @override
  _ModuleListSectionState createState() => _ModuleListSectionState();
}

class _ModuleListSectionState extends State<ModuleListSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadModules();
    });
  }

  Future<void> _loadModules() async {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
    await moduleProvider.fetchModules(widget.courseId);
  }

  Future<void> _showAddModuleDialog() async {
    try {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ModuleCrudDialog(courseId: widget.courseId),
      );

      if (result == true && mounted) {
        // Refresh the modules list after successful creation
        await _loadModules();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module created successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating module: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTeacher =
        Provider.of<AuthProvider>(context).user?.role == 'teacher';

    return Consumer<ModuleProvider>(
      builder: (context, moduleProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modules',
                    style: TextStyles.h3,
                  ),
                  if (isTeacher)
                    CustomButton(
                      text: 'Add Module',
                      onPressed: _showAddModuleDialog,
                      icon: Icons.add,
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.md),
              LoadingOverlay(
                isLoading: moduleProvider.isLoading,
                child: moduleProvider.error != null
                    ? Center(
                        child: Column(
                          children: [
                            Text(
                              moduleProvider.error!,
                              style: TextStyles.error,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Dimensions.md),
                            CustomButton(
                              text: 'Retry',
                              onPressed: _loadModules,
                              width: 120,
                            ),
                          ],
                        ),
                      )
                    : moduleProvider.modules.isEmpty
                        ? const Center(
                            child: Text(
                              'No modules available',
                              style: TextStyles.bodyMedium,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: moduleProvider.modules.length,
                            itemBuilder: (context, index) {
                              final module = moduleProvider.modules[index];
                              return Card(
                                margin: const EdgeInsets.only(
                                  bottom: Dimensions.sm,
                                ),
                                child: ListTile(
                                  title: Text(module.title),
                                  subtitle: Text(
                                    module.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/module-detail',
                                    arguments: module.id,
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
