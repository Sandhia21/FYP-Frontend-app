import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/module_provider.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/module/module_card.dart';
import '../../../constants/colors.dart';

class ModuleListScreen extends StatefulWidget {
  final int courseId;
  final bool embedded;
  final bool isTeacher;

  const ModuleListScreen({
    super.key,
    required this.courseId,
    this.embedded = false,
    this.isTeacher = false,
  });

  @override
  State<ModuleListScreen> createState() => _ModuleListScreenState();
}

class _ModuleListScreenState extends State<ModuleListScreen> {
  @override
  void initState() {
    super.initState();
    // Add this to fetch modules when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadModules();
    });
  }

  Future<void> _loadModules() async {
    if (!mounted) return;
    try {
      final moduleProvider =
          Provider.of<ModuleProvider>(context, listen: false);
      await moduleProvider.fetchModules(widget.courseId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Consumer<ModuleProvider>(
      builder: (context, moduleProvider, child) {
        // Add print statement to debug
        print('Modules length: ${moduleProvider.modules.length}');
        print('Loading state: ${moduleProvider.isLoading}');
        print('Error state: ${moduleProvider.error}');

        if (moduleProvider.isLoading) {
          return const LoadingOverlay(
            isLoading: true,
            child: SizedBox.expand(),
          );
        }

        if (moduleProvider.error != null) {
          return Center(
            child: Text(
              moduleProvider.error!,
              style: TextStyles.error,
              textAlign: TextAlign.center,
            ),
          );
        }

        final modules = moduleProvider.modules;
        // print(modules);
        if (modules.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: Dimensions.sm),
                Text(
                  'No modules yet',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: Dimensions.md),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final module = modules[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.md),
              child: ModuleCard(
                module: module,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/module-detail',
                  arguments: {
                    'moduleId': module.id,
                    'courseId': widget.courseId,
                    'isTeacher': widget.isTeacher,
                  },
                ),
                isInstructor: false,
              ),
            );
          },
        );
      },
    );

    if (!widget.embedded) {
      content = Scaffold(
        appBar: const CustomAppBar(
          title: 'Course Modules',
        ),
        body: content,
      );
    }

    return content;
  }
}
