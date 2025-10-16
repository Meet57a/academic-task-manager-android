import 'package:flutter/material.dart';
import '../model/subject_model.dart';
import '../model/task_model.dart';
import '../services/task_subject_service.dart';

class EditTaskDialog extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTaskUpdated;

  const EditTaskDialog({
    Key? key,
    required this.task,
    this.onTaskUpdated,
  }) : super(key: key);

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _dueDateController;
  final _formKey = GlobalKey<FormState>();
  
  List<SubjectModel> _subjects = [];
  SubjectModel? _selectedSubject;
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _dueDateController = TextEditingController(text: widget.task.dueDate);
    _selectedDate = DateTime.tryParse(widget.task.dueDate);
    _fetchSubjects();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    try {
      final response = await TaskSubjectService().fetchSubjects();
      final List<dynamic> data = response as List<dynamic>;
      
      setState(() {
        _subjects = data.map((json) => SubjectModel.fromJson(json)).toList();
        // Set the current subject as selected
        _selectedSubject = _subjects.firstWhere(
          (subject) => subject.id == widget.task.subject,
          orElse: () => _subjects.isNotEmpty ? _subjects.first : SubjectModel(id: 0, name: "Unknown", color: "0xFF000000"),
        );
      });
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subjects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text = 
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _updateTask() async {
    if (!_formKey.currentState!.validate() || _selectedSubject == null) {
      if (_selectedSubject == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a subject'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await TaskSubjectService().updateTask(
        id: widget.task.id,
        title: _titleController.text.trim(),
        subject: _selectedSubject!.id,
        dueDate: _dueDateController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onTaskUpdated?.call();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update task: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  if (value.trim().length < 3) {
                    return 'Task title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Subject Dropdown
              DropdownButtonFormField<SubjectModel>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Select a subject',
                  border: OutlineInputBorder(),
                ),
                items: _subjects.map((subject) {
                  return DropdownMenuItem<SubjectModel>(
                    value: subject,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _parseColor(subject.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(subject.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (SubjectModel? newValue) {
                  setState(() {
                    _selectedSubject = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Due Date Field
              TextFormField(
                controller: _dueDateController,
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Select due date',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                  ),
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Current Status Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text('Status: ${widget.task.status}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateTask,
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Task'),
        ),
      ],
    );
  }

  // Helper method to parse color strings
  Color _parseColor(String colorString) {
    try {
      String cleanColor = colorString.trim();
      
      if (cleanColor.startsWith('0x') || cleanColor.startsWith('0X')) {
        cleanColor = cleanColor.substring(2);
      } else if (cleanColor.startsWith('#')) {
        cleanColor = cleanColor.substring(1);
        if (cleanColor.length == 6) {
          cleanColor = 'FF$cleanColor';
        }
      }
      
      if (cleanColor.length == 6) {
        cleanColor = 'FF$cleanColor';
      }
      
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
