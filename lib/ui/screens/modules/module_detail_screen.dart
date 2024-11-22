import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../constants/dimensions.dart';
import '../../../constants/text_styles.dart';
import '../../../providers/module_provider.dart';
import '../../../widgets/common/app_bar.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/module/notes_section.dart';
import '../../../widgets/module/quiz_section.dart';
import '../../../widgets/module/results_section.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/module/module_crud_dialog.dart';
import '../../../data/models/module.dart';
import '../../../widgets/notes/note_crud_dialog.dart';
import '../../../providers/note_provider.dart';
import '../../../providers/result_provider.dart';

class ModuleDetailScreen extends StatefulWidget {
  final int moduleId;
  final int courseId;
  final bool isTeacher;

  const ModuleDetailScreen({
    super.key,
    required this.moduleId,
    required this.courseId,
    this.isTeacher = false,
  });

  @override
  State<ModuleDetailScreen> createState() => _ModuleDetailScreenState();
}

class _ModuleDetailScreenState extends State<ModuleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _quizId;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Initialize data without the post frame callback
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // Update initialization method
  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      // First load the user profile to ensure proper authorization
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.fetchProfile();

      // Load all data in parallel
      await Future.wait([
        _loadModuleDetails(),
        _loadQuizDetails(),
        _loadNotes(),
      ]);

      // Load results after quiz details are loaded
      if (_quizId != null) {
        await _loadResults();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading module: ${e.toString()}')),
        );
      }
    }
  }

  // New method to handle tab changes
  void _handleTabChange() {
    if (!mounted) return;

    switch (_tabController.index) {
      case 0: // Notes tab
        _loadNotes();
        break;
      case 1: // Quizzes tab
        _loadQuizDetails();
        break;
      case 2: // Results tab
        _loadResults();
        break;
    }
  }

  Future<void> _loadNotes() async {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    await noteProvider.loadNotes(widget.moduleId);
  }

  Future<void> _loadResults() async {
    if (_quizId != null) {
      final resultProvider =
          Provider.of<ResultProvider>(context, listen: false);
      await resultProvider.fetchResults(widget.moduleId, _quizId!);
    }
  }

  Future<void> _loadModuleDetails() async {
    final moduleProvider = Provider.of<ModuleProvider>(context, listen: false);
    await moduleProvider.fetchModuleDetails(widget.moduleId);
  }

  Future<void> _loadQuizDetails() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.fetchQuizzes(widget.moduleId);

    if (mounted) {
      setState(() {
        // Get the first quiz ID if available
        _quizId = quizProvider.quizzes.isNotEmpty
            ? quizProvider.quizzes.first.id
            : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Module Details',
      ),
      body: !_isInitialized
          ? const LoadingOverlay(
              isLoading: true,
              child: SizedBox.expand(),
            )
          : Consumer<ModuleProvider>(
              builder: (context, moduleProvider, child) {
                if (moduleProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          moduleProvider.error!,
                          style: TextStyles.error,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.md),
                        CustomButton(
                          text: 'Retry',
                          onPressed: _initializeData,
                          backgroundColor: AppColors.primary,
                        ),
                      ],
                    ),
                  );
                }

                final module = moduleProvider.selectedModule;
                if (module == null) {
                  return const Center(
                    child: Text(
                      'Module not found',
                      style: TextStyles.bodyLarge,
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Module Header
                    Padding(
                      padding: const EdgeInsets.all(Dimensions.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(module.title, style: TextStyles.h2),
                          const SizedBox(height: Dimensions.sm),
                          Text(
                            module.description,
                            style: TextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),

                    // Tab Bar
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Notes'),
                        Tab(text: 'Quizzes'),
                        Tab(text: 'Results'),
                      ],
                    ),

                    // Tab Content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          NotesSection(
                            moduleId: widget.moduleId,
                            isTeacher: widget.isTeacher,
                          ),
                          QuizSection(
                            moduleId: widget.moduleId,
                            isTeacher: widget.isTeacher,
                          ),
                          ResultSection(
                            moduleId: widget.moduleId,
                            quizId: _quizId ?? 0,
                            isTeacher: widget.isTeacher,
                          ),
                        ],
                      ),
                    ),

                    // Action Buttons Section
                    _buildActionButtons(module),
                  ],
                );
              },
            ),
    );
  }

  // Update the teacher check in the action buttons section
  Widget _buildActionButtons(Module module) {
    debugPrint('isTeacher value: ${widget.isTeacher}');
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Use the isTeacher prop from widget instead of checking auth
        if (!widget.isTeacher) {
          debugPrint('Teacher actions hidden because isTeacher is false');
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(Dimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Module',
                        onPressed: () => _showEditModuleDialog(module),
                        backgroundColor: AppColors.secondary,
                        icon: Icons.edit,
                      ),
                    ),
                    const SizedBox(width: Dimensions.sm),
                    Expanded(
                      child: CustomButton(
                        text: 'Module',
                        onPressed: () => _showDeleteConfirmation(
                          context,
                          module.id,
                        ),
                        backgroundColor: AppColors.error,
                        icon: Icons.delete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditModuleDialog(Module module) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ModuleCrudDialog(
        module: module,
        courseId: widget.courseId,
      ),
    );

    if (result == true && mounted) {
      await _loadModuleDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Module updated successfully')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, int moduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DeleteModule'),
        content: const Text(
          'Are you sure you want to delete this module? This action cannot be undone. '
          'All associated notes, quizzes, and results will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final moduleProvider =
            Provider.of<ModuleProvider>(context, listen: false);
        await moduleProvider.deleteModule(moduleId);
        if (mounted) {
          Navigator.pop(context); // Return to course detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Module deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  Future<void> _showCreateNoteDialog(int moduleId) async {
    final result = await showDialog(
      context: context,
      builder: (context) => NoteCrudDialog(
        moduleId: moduleId,
      ),
    );

    if (result == true && mounted) {
      // Refresh the notes list
      setState(() {
        // Force tab refresh by rebuilding
        _tabController.index = _tabController.index;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note created successfully')),
      );
    }
  }
}
