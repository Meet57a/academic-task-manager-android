import 'package:academic_task_manager/services/task_subject_service.dart';
import 'package:academic_task_manager/widgets/snackbar.dart';
import 'package:flutter/material.dart';

class AddSubject extends StatefulWidget {
  const AddSubject({super.key});

  @override
  State<AddSubject> createState() => _AddSubjectState();
}

class _AddSubjectState extends State<AddSubject> {
  final TextEditingController _subjectNameController = TextEditingController();
  Color _selectedColor = Colors.blue;

  // Predefined color options
  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lime,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void dispose() {
    _subjectNameController.dispose();
    super.dispose();
  }

  String _getColorInAARRGGBBFormat(Color color) {
    return "0x${_colorOptions
            .firstWhere(
              (c) => c.value == color.value,
              orElse: () => Colors.black,
            )
            .value
            .toRadixString(16)
            .padLeft(8, '0')
            .toUpperCase()}";
  }

  void _handleAddSubject() async {
    final subjectName = _subjectNameController.text.trim();
    try {
      if (subjectName.isNotEmpty) {
        final colorCode = _getColorInAARRGGBBFormat(_selectedColor);

        // Debug: Print color code to verify format
        debugPrint('Selected color: $_selectedColor');
        debugPrint('Selected color value: ${_selectedColor.value}');
        debugPrint('Generated color code: $colorCode');

        // Test parsing the generated color immediately
        try {
          final testColor = Color(
            int.parse(colorCode.replaceFirst('0x', ''), radix: 16),
          );
          debugPrint('Test parsed color: $testColor');
          debugPrint('Test parsed color value: ${testColor.value}');
          debugPrint(
            'Colors match: ${_selectedColor.value == testColor.value}',
          );
        } catch (e) {
          debugPrint('Error testing color parsing: $e');
        }

        final response = await TaskSubjectService().addSubject(
          subjectName,
          colorCode,
        );
        if (mounted) {
          Navigator.of(context).pop(response);
          showCustomSnackBar(context, "Subject added successfully!");
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a subject name'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomSnackBar(context, "Error adding subject: $e");
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 12,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _selectedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.subject, color: _selectedColor, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  'Add New Subject',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _selectedColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _subjectNameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Subject Name',
                hintText: 'Enter subject name (e.g., Mathematics)',
                prefixIcon: const Icon(Icons.book),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: _selectedColor, width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _handleAddSubject(),
            ),
            const SizedBox(height: 24),

            // Color Selection Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.palette, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Choose Color',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _selectedColor, width: 1),
                      ),
                      child: Text(
                        _getColorInAARRGGBBFormat(_selectedColor),
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: _selectedColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colorOptions.map((color) {
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleAddSubject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Add Subject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
