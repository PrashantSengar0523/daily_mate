import 'package:daily_mate/common/widgets/app_button/t_app_button.dart';
import 'package:daily_mate/common/widgets/appbar/common_app_bar.dart';
import 'package:daily_mate/common/widgets/text_fields/text_field.dart';
import 'package:daily_mate/features/controllers/quick_tool_controller/notes_controller.dart';
import 'package:daily_mate/utils/constants/colors.dart';
import 'package:daily_mate/utils/constants/sizes.dart';
import 'package:daily_mate/utils/constants/text_strings.dart';
import 'package:daily_mate/utils/helpers/helper_functions.dart';
import 'package:daily_mate/utils/popups/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotesView extends StatelessWidget {
  NotesView({super.key});

  final NotesController controller = Get.put(NotesController());
  final GlobalKey<FormState> _addNoteKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final isDark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: TCommonAppBar(
        showBackArrow: true,
        appBarWidget: Text(
          TTexts.notes.tr,
          style: textStyle.headlineSmall?.copyWith(color: TColors.textWhite),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.secondary,
        child: const Icon(Icons.add, color: TColors.white),
        onPressed: () => showAddEditNoteDialog(context),
      ),
      body: Obx(() {
        if (controller.notes.isEmpty) {
          return Center(child: Text(TTexts.noNoteData.tr));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.notes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 cards per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85, // card height-width ratio
          ),
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return NoteCard(
              note: note,
              textStyle: textStyle,
              isDark: isDark,
              onEdit: () => showAddEditNoteDialog(context, note: note),
              onDelete: () => controller.deleteNote(note.id),
            );
          },
        );
      }),
    );
  }

  /// Reusable Note Card

  void showAddEditNoteDialog(BuildContext context, {NoteModel? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    DateTime? selectedDateTime; // for reminder
    final reminderController =
        TextEditingController(); // show formatted datetime

    TDialogs.defaultDialog(
      context: context,
      child: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom,),
            child: Form(
              key: _addNoteKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Header Row (Title + Close)
                  Row(
                    children: [
                      Text(
                        note == null ? TTexts.addNote.tr : TTexts.editNote.tr,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        child: const Icon(Icons.close, size: 22),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: TSizes.defaultSpace),
            
                  /// Title Field
                  TTextField(
                    controller: titleController,
                    hintText: TTexts.title.tr,
                    maxLength: 40,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return TTexts.emptyFieldValidation.tr;
                      }
                      if (val.trim().length > 40) {
                        return TTexts.title40Chars.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
            
                  /// Content Field
                  TTextField(
                    controller: contentController,
                    maxLines: 5,
                    hintText: TTexts.content.tr,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return TTexts.emptyFieldValidation.tr;
                      }
                      return null;
                    },
                  ),
            
                  /// Reminder field (only if selected)
                  if (selectedDateTime != null) ...[
                    const SizedBox(height: TSizes.defaultSpace),
                    Row(
                      children: [
                        /// Reminder text
                        Expanded(
                          child: Text(
                            reminderController.text,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontSize: TSizes.fontSizeSm,
                              fontWeight: FontWeight.bold,
                              color:THelperFunctions.isDarkMode(context) ?TColors.secondary:TColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
            
                        /// Edit icon
                        InkWell(
                          onTap: () async {
                            final now = DateTime.now();
            
                            final pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime ?? now,
                              firstDate: now,
                              lastDate: DateTime(now.year + 5),
                            );
                            if (pickedDate == null) return;
            
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                selectedDateTime ??
                                    now.add(const Duration(minutes: 5)),
                              ),
                            );
                            if (pickedTime == null) return;
            
                            final chosenDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
            
                            if (chosenDateTime.isBefore(now)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Reminder must be in the future"),
                                ),
                              );
                              return;
                            }
            
                            setState(() {
                              selectedDateTime = chosenDateTime;
                              reminderController.text = THelperFunctions.formatReminder(chosenDateTime);
                            });
                          },
                          child: Icon(Icons.edit, color:THelperFunctions.isDarkMode(context) ?TColors.grey :TColors.iconPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
            
                  /// Reminder Checkbox
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "Note Reminder (Optional)",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: selectedDateTime != null,
                    onChanged: (enabled) async {
                      if (enabled == true) {
                        final now = DateTime.now();
            
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: DateTime(now.year + 5),
                        );
                        if (pickedDate == null) return;
            
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            now.add(const Duration(minutes: 5)),
                          ),
                        );
                        if (pickedTime == null) return;
            
                        final chosenDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
            
                        if (chosenDateTime.isBefore(now)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Reminder must be in the future"),
                            ),
                          );
                          return;
                        }
            
                        setState(() {
                          selectedDateTime = chosenDateTime;
                          reminderController.text = THelperFunctions.formatReminder(chosenDateTime);
                        });
                      } else {
                        setState(() {
                          selectedDateTime = null;
                          reminderController.clear();
                        });
                      }
                    },
                  ),
            
                  const SizedBox(height: 12),
            
                  /// Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TAppOutlinedButton(
                        onPressed: () => Get.back(),
                        height: 36,
                        text: TTexts.cancel.tr,
                      ),
                      const SizedBox(width: 12),
                      TAppButton(
                        text: TTexts.save.tr,
                        height: 36,
                        onPressed: () {
                          if (_addNoteKey.currentState!.validate()) {
                            if (note == null) {
                              controller.addNote(
                                titleController.text.trim(),
                                contentController.text.trim(),
                                reminder: selectedDateTime,
                              );
                            } else {
                              controller.editNote(
                                note.id,
                                titleController.text.trim(),
                                contentController.text.trim(),
                                reminder: selectedDateTime,
                              );
                            }
                            Get.back();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final TextTheme textStyle;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.textStyle,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _showActions = false;

  void _toggleActions() {
    setState(() => _showActions = !_showActions);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _toggleActions,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// Main Note Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors:
                    widget.isDark
                        ? [Colors.teal.shade700, Colors.teal.shade900]
                        : [Colors.greenAccent.shade100, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title Row
                Text(
                  widget.note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: widget.textStyle.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: widget.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                /// Content
                Expanded(
                  child: Text(
                    widget.note.content,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: widget.textStyle.bodyMedium?.copyWith(
                      height: 1.4,
                      color: widget.isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Overlay Actions (Edit + Delete)
          if (_showActions)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(
                        icon: Icons.edit,
                        color: Colors.blue,
                        onTap: () {
                          _toggleActions();
                          widget.onEdit();
                        },
                      ),
                      const SizedBox(width: 20),
                      _actionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onTap: () {
                          _toggleActions();
                          widget.onDelete();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}
