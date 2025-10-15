import 'package:academic_task_manager/model/subject_model.dart';
import 'package:academic_task_manager/model/task_model.dart';
import 'package:academic_task_manager/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

List<SubjectModel> subjects = [
  SubjectModel(name: "Mathematics", color: "0xFF42A5F5"),
  SubjectModel(name: "Physics", color: "0xFFFF5722"),
  SubjectModel(name: "Chemistry", color: "0xFF4CAF50"),
  SubjectModel(name: "Biology", color: "0xFF9C27B0"),
];

List<TaskModel> tasks = [
  TaskModel(
    id: 1,
    title: "Complete Assignment",
    subject: 0,
    dueDate: "2025-10-17 11:37:18.000",
    status: "Completed",
    createdAt: "2025-10-10 11:37:18.000",
  ),
  TaskModel(
    id: 2,
    title: "Study for Exam",
    subject: 1,
    dueDate: "2025-10-20 11:37:18.000",
    status: "In Progress",
    createdAt: "2025-10-10 11:37:18.000",
  ),
  TaskModel(
    id: 3,
    title: "Read Chapter 5",
    subject: 2,
    dueDate: "2025-10-15 11:37:18.000",
    status: "In Progress",
    createdAt: "2025-10-11 11:37:18.000",
  ),
  TaskModel(
    id: 4,
    title: "Prepare Presentation",
    subject: 3,
    dueDate: "2025-10-22 11:37:18.000",
    status: "In Progress",
    createdAt: "2025-10-12 11:37:18.000",
  ),
  TaskModel(
    id: 5,
    title: "Lab Report",
    subject: 1,
    dueDate: "2025-10-18 11:37:18.000",
    status: "Completed",
    createdAt: "2025-10-12 11:37:18.000",
  ),
];

class _HomeState extends State<Home> {
  List<TaskAccordingToCreatedAt> taskList = [];

  void groupTasksByCreatedAt() {
    Map<String, List<TaskModel>> groupedTasks = {};

    for (var task in tasks) {
      if (groupedTasks.containsKey(task.createdAt)) {
        groupedTasks[task.createdAt]!.add(task);
      } else {
        groupedTasks[task.createdAt] = [task];
      }
    }

    taskList = groupedTasks.entries
        .map(
          (entry) => TaskAccordingToCreatedAt(
            createdAt: entry.key,
            tasks: entry.value,
          ),
        )
        .toList();

    taskList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  void initState() {
    super.initState();
    groupTasksByCreatedAt();
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
      body: CustomScrollView(
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
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, color: Colors.green, size: 15),
                    const SizedBox(width: 10),
                    Text(
                      "$isCompleted / $totalTasks Tasks",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.circle, color: Colors.orange, size: 15),
                    const SizedBox(width: 10),
                    Text(
                      "$inProgress In Progress",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.circle, color: Colors.red, size: 15),
                    const SizedBox(width: 10),
                    Text(
                      "$overdue Overdue",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: subjects.length,
                  
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                color: Color(int.parse(subjects[index].color)),
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
                const Text("Upcoming Tasks", style: TextStyle(fontSize: 15)),
                const SizedBox(height: 10),
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
                            final subject = subjects[task.subject];
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
                                          color: Color(
                                            int.parse(subject.color),
                                          ),
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
                                    backgroundColor: Colors.grey.withAlpha(50),
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
                                        onChanged: (v) {
                                          setState(() {
                                            task.status = v!
                                                ? "Completed"
                                                : "In Progress";
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                      Text("Mark as Completed"),
                                      const Spacer(),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
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
    );
  }
}
