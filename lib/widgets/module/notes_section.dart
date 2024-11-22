import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/text_styles.dart';
import '../../providers/note_provider.dart';
import '../../ui/screens/notes/note_detail_screen.dart';
import '../notes/note_crud_dialog.dart';

class NotesSection extends StatelessWidget {
  final int moduleId;
  final bool isTeacher;

  const NotesSection({
    Key? key,
    required this.moduleId,
    this.isTeacher = false,
  }) : super(key: key);

  String _truncateTitle(String title, {int maxLength = 30}) {
    if (title.length <= maxLength) return title;
    return '${title.substring(0, maxLength)}...';
  }

  Future<void> _showCreateNoteDialog(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => NoteCrudDialog(moduleId: moduleId),
    );

    if (result == true) {
      // Refresh notes list
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      await noteProvider.loadNotes(moduleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        if (noteProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notes (${noteProvider.notes.length})',
                    style: TextStyles.h3,
                  ),
                  if (isTeacher)
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showCreateNoteDialog(context),
                      color: AppColors.primary,
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.md),
              Expanded(
                child: noteProvider.notes.isEmpty
                    ? const Center(
                        child: Text(
                          'No notes available',
                          style: TextStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: noteProvider.notes.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.sm,
                          horizontal: Dimensions.xs,
                        ),
                        itemBuilder: (context, index) {
                          final note = noteProvider
                              .notes[noteProvider.notes.length - 1 - index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: Dimensions.md),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(Dimensions.sm),
                                side: BorderSide(
                                  color: AppColors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NoteDetailScreen(
                                      moduleId: moduleId,
                                      noteId: note.id,
                                    ),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.md,
                                  vertical: Dimensions.sm,
                                ),
                                title: Text(
                                  _truncateTitle(note.title),
                                  style: TextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.all(Dimensions.sm),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(Dimensions.sm),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
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
