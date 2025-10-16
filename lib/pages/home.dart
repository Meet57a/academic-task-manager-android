import 'package:academic_task_manager/components/add_subject.dart';
import 'package:academic_task_manager/components/add_task.dart';
import 'package:academic_task_manager/components/edit_task.dart';
import 'package:academic_task_manager/components/floating_action_button.dart';
import 'package:academic_task_manager/model/subject_model.dart';
import 'package:academic_task_manager/model/task_model.dart';
import 'package:academic_task_manager/provider/theme_provider.dart';
import 'package:academic_task_manager/services/task_subject_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

enum TaskFilter { all, active, completed, overdue }
enum SortOption { dueDate, created, alphabetical }

class _HomeState extends State<Home> {
  List<TaskAccordingToCreatedAt> taskList = [];
  List<SubjectModel> subjects = [];
  List<TaskModel> tasks = [];
  bool isLoadingSubjects = true;
  bool isLoadingTasks = true;
  TaskFilter currentFilter = TaskFilter.active;
  SortOption currentSort = SortOption.dueDate;
  int? selectedSubjectFilter;

  void groupTasksByCreatedAt() {
    Map<String, List<TaskModel>> groupedTasks = {};

    // Apply filters
    List<TaskModel> filteredTasks = _applyFilters(tasks);

    for (var task in filteredTasks) {
      if (groupedTasks.containsKey(task.created_at)) {
        groupedTasks[task.created_at]!.add(task);
      } else {
        groupedTasks[task.created_at] = [task];
      }
    }

    taskList = groupedTasks.entries
        .map(
          (entry) => TaskAccordingToCreatedAt(
            createdAt: entry.key,
            tasks: _applySorting(entry.value),
          ),
        )
        .toList();

    // Sort groups by date
    taskList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TaskModel> _applyFilters(List<TaskModel> tasks) {
    List<TaskModel> filtered = List.from(tasks);

    // Apply task filter
    switch (currentFilter) {
      case TaskFilter.active:
        filtered = filtered.where((task) => task.status != "Completed").toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.status == "Completed").toList();
        break;
      case TaskFilter.overdue:
        filtered = filtered.where((task) => 
          DateTime.parse(task.dueDate).isBefore(DateTime.now()) && 
          task.status != "Completed"
        ).toList();
        break;
      case TaskFilter.all:
        // No filtering
        break;
    }

    // Apply subject filter
    if (selectedSubjectFilter != null) {
      filtered = filtered.where((task) => task.subject == selectedSubjectFilter).toList();
    }

    return filtered;
  }

  List<TaskModel> _applySorting(List<TaskModel> tasks) {
    List<TaskModel> sorted = List.from(tasks);
    
    switch (currentSort) {
      case SortOption.dueDate:
        sorted.sort((a, b) => DateTime.parse(a.dueDate).compareTo(DateTime.parse(b.dueDate)));
        break;
      case SortOption.created:
        sorted.sort((a, b) => b.created_at.compareTo(a.created_at));
        break;
      case SortOption.alphabetical:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    
    return sorted;
  }

  Future<void> fetchSubs() async {
    setState(() {
      isLoadingSubjects = true;
    });

    try {
      final response = await TaskSubjectService().fetchSubjects();
      debugPrint('Raw API response: $response');
      if (mounted) {
        setState(() {
          subjects.clear(); 
          final subjectList = (response as List).map((e) {
            debugPrint('Processing subject: $e');
            final subject = SubjectModel.fromJson(e);
            debugPrint(
              'Created subject: ${subject.name}, color: ${subject.color}',
            );
            return subject;
          }).toList();
          subjects.addAll(subjectList);
          isLoadingSubjects = false;
        });
      }
    } catch (e) {
      // Handle error - you can show a snackbar or use default subjects
      if (mounted) {
        setState(() {
          subjects = [
            SubjectModel(id: 0, name: "General", color: "0xFF2196F3"),
            SubjectModel(id: 1, name: "Mathematics", color: "0xFF4CAF50"),
            SubjectModel(id: 2, name: "Science", color: "0xFF9C27B0"),
            SubjectModel(id: 3, name: "English", color: "0xFFFF5722"),
          ];
          isLoadingSubjects = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load subjects: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> fetchTasks() async {
    debugPrint('Fetching tasks...');
    try {
      final response = await TaskSubjectService().fetchTasks();
      debugPrint('Raw tasks API response: $response');
      if (mounted) {
        setState(() {
          tasks.clear();
          final taskList = (response as List).map((e) {
            debugPrint('Processing task: $e');
            final task = TaskModel.fromMap(e);
            debugPrint('Created task: ${task.title}, subject: ${task.subject}');
            return task;
          }).toList();
          tasks.addAll(taskList);
          isLoadingTasks = false;
          groupTasksByCreatedAt(); 
        });
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      if (mounted) {
        setState(() {
          // Provide some default tasks for development
          tasks = [
            TaskModel(
              id: 1,
              title: "Complete Assignment",
              subject: subjects.isNotEmpty ? subjects.first.id : 1,
              dueDate: "2025-10-17",
              status: "In Progress",
              created_at: "2025-10-10",
            ),
          ];
          isLoadingTasks = false;
          groupTasksByCreatedAt();
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load tasks: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  //get subject by id safely
  SubjectModel getSubjectByIdSafe(int id) {
    return subjects.firstWhere(
      (subject) => subject.id == id,
      orElse: () => SubjectModel(id: 0, name: "Unknown", color: "0xFF000000"),
    );
  }

  void _showFilterBottomSheet() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode 
                  ? Colors.black.withOpacity(0.3) 
                  : Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Filter & Sort Tasks',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            
            // Task Status Filter
            Text(
              'Task Status', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: TaskFilter.values.map((filter) {
                return FilterChip(
                  label: Text(_getFilterLabel(filter)),
                  selected: currentFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      currentFilter = filter;
                      groupTasksByCreatedAt();
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: currentFilter == filter 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Subject Filter
            Text(
              'Subject', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    label: const Text('All Subjects'),
                    selected: selectedSubjectFilter == null,
                    onSelected: (selected) {
                      setState(() {
                        selectedSubjectFilter = null;
                        groupTasksByCreatedAt();
                      });
                    },
                    selectedColor: Colors.green,
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selectedSubjectFilter == null 
                          ? Colors.white 
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...subjects.map((subject) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _parseColor(subject.color),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(subject.name),
                          ],
                        ),
                        selected: selectedSubjectFilter == subject.id,
                        onSelected: (selected) {
                          setState(() {
                            selectedSubjectFilter = selected ? subject.id : null;
                            groupTasksByCreatedAt();
                          });
                        },
                        selectedColor: _parseColor(subject.color),
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: selectedSubjectFilter == subject.id 
                              ? Colors.white 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Sort Options
            Text(
              'Sort By', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: SortOption.values.map((sort) {
                return FilterChip(
                  label: Text(_getSortLabel(sort)),
                  selected: currentSort == sort,
                  onSelected: (selected) {
                    setState(() {
                      currentSort = sort;
                      groupTasksByCreatedAt();
                    });
                  },
                  selectedColor: Colors.orange,
                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: currentSort == sort 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: isDarkMode ? 8 : 2,
                ),
                child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
  
  String _getFilterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.active:
        return 'Active';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.overdue:
        return 'Overdue';
    }
  }
  
  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.dueDate:
        return 'Due Date';
      case SortOption.created:
        return 'Created Date';
      case SortOption.alphabetical:
        return 'A-Z';
    }
  }
  
  String _getTaskCountText(int totalTasks, int completedTasks) {
    switch (currentFilter) {
      case TaskFilter.all:
        return "$completedTasks / $totalTasks Tasks";
      case TaskFilter.active:
        return "$totalTasks Active Tasks";
      case TaskFilter.completed:
        return "$totalTasks Completed Tasks";
      case TaskFilter.overdue:
        return "$totalTasks Overdue Tasks";
    }
  }
  
  Color _getFilterColor() {
    switch (currentFilter) {
      case TaskFilter.all:
        return Colors.blue;
      case TaskFilter.active:
        return Colors.orange;
      case TaskFilter.completed:
        return Colors.green;
      case TaskFilter.overdue:
        return Colors.red;
    }
  }
  
  IconData _getFilterIcon() {
    switch (currentFilter) {
      case TaskFilter.all:
        return Icons.list;
      case TaskFilter.active:
        return Icons.radio_button_unchecked;
      case TaskFilter.completed:
        return Icons.check_circle;
      case TaskFilter.overdue:
        return Icons.warning;
    }
  }
  
  Widget _buildQuickFilterChip(TaskFilter filter, IconData icon, int count) {
    final isSelected = currentFilter == filter;
    final color = _getFilterColorForType(filter);
    
    return InkWell(
      onTap: () {
        setState(() {
          currentFilter = filter;
          groupTasksByCreatedAt();
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(height: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            Text(
              _getFilterLabel(filter).split(' ').first,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getFilterColorForType(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return Colors.blue;
      case TaskFilter.active:
        return Colors.orange;
      case TaskFilter.completed:
        return Colors.green;
      case TaskFilter.overdue:
        return Colors.red;
    }
  }
  
  Widget _buildStatCard(String label, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to parse color strings (same as before)
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

  @override
  void initState() {
    super.initState();
    fetchSubs();
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final totalTasks = taskList.fold<int>(
      0,
      (previousValue, element) => previousValue + element.tasks.length,
    );
    final isCompleted = taskList.fold<int>(
      0,
      (previousValue, element) =>
          previousValue +
          element.tasks.where((task) => task.status == "Completed").length,
    );
    final inProgress = taskList.fold<int>(
      0,
      (previousValue, element) =>
          previousValue +
          element.tasks.where((task) => task.status == "In Progress").length,
    );
    final overdue = taskList.fold<int>(
      0,
      (previousValue, element) =>
          previousValue +
          element.tasks
              .where(
                (task) => DateTime.parse(task.dueDate).isBefore(DateTime.now()),
              )
              .length,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButtonWidget(
        onAddTask: () async {
          await showDialog(
            context: context,
            builder: (context) => AddTaskDialog(
              onTaskAdded: () {
                // Refresh both tasks and subjects after adding a task
                fetchTasks();
                fetchSubs();
              },
            ),
          );
        },
        onAddSubject: () async {
          // Show dialog and wait for result
          final result = await showDialog(
            context: context,
            builder: (context) => const AddSubject(),
          );

          // If a subject was added, refresh the subjects list
          if (result != null && mounted) {
            fetchSubs();
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchSubs();
          setState(() {
            groupTasksByCreatedAt();
          });
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              pinned: false,
              elevation: 4,
              shadowColor: Colors.black26,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                "Task Manager",
                style: TextStyle(letterSpacing: 5, fontWeight: FontWeight.w600),
              ),

              actions: [
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterBottomSheet();
                  },
                  tooltip: 'Filter Tasks',
                ),
                IconButton(
                  icon: Icon(
                    themeNotifier.themeMode == ThemeMode.light
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  onPressed: () {
                    themeNotifier.toggleTheme();
                  },
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Main task count
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getFilterIcon(), 
                              color: _getFilterColor(), 
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _getTaskCountText(totalTasks, isCompleted),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getFilterColor(),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Statistics grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Active',
                                inProgress,
                                Icons.radio_button_unchecked,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Completed',
                                isCompleted,
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildStatCard(
                                'Overdue',
                                overdue,
                                Icons.warning,
                                Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 30,
                    child: isLoadingSubjects
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : subjects.isEmpty
                        ? const Center(
                            child: Text(
                              'No subjects available',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: subjects.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(25),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      subjects[index].name,
                                      style: TextStyle(
                                        color: Color(
                                          int.parse(subjects[index].color),
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Enhanced Filter Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.task, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "Tasks",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getFilterColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getFilterColor(), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_getFilterIcon(), color: _getFilterColor(), size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getFilterLabel(currentFilter),
                                    style: TextStyle(
                                      color: _getFilterColor(),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickFilterChip(
                                TaskFilter.active,
                                Icons.radio_button_unchecked,
                                tasks.where((t) => t.status != "Completed").length,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickFilterChip(
                                TaskFilter.completed,
                                Icons.check_circle,
                                tasks.where((t) => t.status == "Completed").length,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildQuickFilterChip(
                                TaskFilter.overdue,
                                Icons.warning,
                                tasks.where((t) => 
                                  DateTime.parse(t.dueDate).isBefore(DateTime.now()) && 
                                  t.status != "Completed"
                                ).length,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: taskList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(taskList[index].createdAt.substring(0, 10)),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskList[index].tasks.length,
                            itemBuilder: (context, taskIndex) {
                              final task = taskList[index].tasks[taskIndex];
                              final subject = getSubjectByIdSafe(task.subject);
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withAlpha(25),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  border: BorderDirectional(
                                    start: BorderSide(
                                      color: Color(int.parse(subject.color)),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          subject.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 2,
                                            color: Color(int.parse(subject.color)),
                                          ),
                                        ),
                                        const Spacer(),
                                        Badge(
                                          backgroundColor:
                                              task.status == "Completed"
                                              ? Colors.green
                                              : task.status == "In Progress"
                                              ? Colors.orange
                                              : Colors.red,
                                          label: Text(
                                            task.status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        DateTime.parse(
                                              task.dueDate,
                                            ).isBefore(DateTime.now())
                                            ? Badge(
                                                backgroundColor: Colors.red,
                                                label: Text(
                                                  "Overdue",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5,
                                                    ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      task.title,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_month,
                                          size: 15,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Due: ${task.dueDate.substring(0, 10)}",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(Icons.access_time, size: 15),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${DateTime.now().difference(DateTime.parse(task.dueDate)).inDays.abs()} days left",
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    LinearProgressIndicator(
                                      value: task.status == "Completed"
                                          ? 1.0
                                          : task.status == "In Progress"
                                          ? 0.5
                                          : 0.0,
                                      backgroundColor: Colors.grey.withAlpha(
                                        50,
                                      ),
                                      color: task.status == "Completed"
                                          ? Colors.green
                                          : task.status == "In Progress"
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Checkbox(
                                          value: task.status == "Completed",
                                          onChanged: (v) async {
                                            final newStatus = v! ? "Completed" : "In Progress";
                                            try {
                                              await TaskSubjectService().updateTaskStatus(task.id, newStatus);
                                              setState(() {
                                                task.status = newStatus;
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Task marked as $newStatus'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to update status: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                          activeColor: Colors.green,
                                        ),
                                        Text("Mark as Completed"),
                                        const Spacer(),
                                        const SizedBox(width: 10),
                                        IconButton(
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (context) => EditTaskDialog(
                                                task: task,
                                                onTaskUpdated: () {
    
                                                  fetchTasks();
                                                },
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Confirm Deletion'),
                                                content: const Text('Are you sure you want to delete this task?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop(); // Close the dialog
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      try {
                                                        await TaskSubjectService().deleteTask(task.id);
                                                        if (mounted) {
                                                          setState(() {
                                                            tasks.removeWhere((t) => t.id == task.id);
                                                            groupTasksByCreatedAt();
                                                          });
                                                          Navigator.of(context).pop(); // Close the dialog
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text('Task deleted successfully'),
                                                              backgroundColor: Colors.green,
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (mounted) {
                                                          Navigator.of(context).pop(); // Close the dialog
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('Failed to delete task: $e'),
                                                              backgroundColor: Colors.red,
                                                            ),
                                                          );
                                                        }
                                                      }
                                                    },
                                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
