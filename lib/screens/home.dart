import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/components/theme_provider.dart';
import 'package:taskify/models/task.dart';
import 'package:taskify/screens/new_task.dart';
import 'package:taskify/components/task_provider.dart';
import 'package:taskify/screens/view_task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Set<String> _selectedTasks = {}; // Store selected task IDs
  String _searchQuery = "";
  bool _showFilterOptions = false; // Toggle filter buttons
  String? _selectedPriority; // Selected filter (null means no filter)
  bool _showSortOptions = false; // Toggle sort buttons
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    _loadSortingPreference();
  }

  Future<void> _loadSortingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedSort =
          prefs.getString("default_sorting") ?? "A - Z"; // Default to A - Z
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.tasks
        .where((task) =>
            task.title.toLowerCase().contains(_searchQuery) &&
            (_selectedPriority == null || task.priority == _selectedPriority))
        .toList();

    void sortTasks(List<Task> tasks) {
      int priorityValue(String priority) {
        switch (priority) {
          case "High":
            return 3;
          case "Average":
            return 2;
          case "Low":
            return 1;
          default:
            return 0; // Default value for unexpected cases
        }
      }

      int parseDate(String? date) {
        if (date == null || date == "No due date") {
          return DateTime(9999, 12, 31).millisecondsSinceEpoch;
        }
        List<String> parts = date.split('-'); // Format: DD-MM-YYYY
        return DateTime(
                int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]))
            .millisecondsSinceEpoch;
      }

      if (_selectedSort != null) {
        switch (_selectedSort) {
          case "A - Z":
            tasks.sort((a, b) => a.title.compareTo(b.title));
            break;
          case "Z - A":
            tasks.sort((a, b) => b.title.compareTo(a.title));
            break;
          case "Due Asc.":
            tasks.sort(
                (a, b) => parseDate(a.dueDate).compareTo(parseDate(b.dueDate)));
            break;
          case "Due Des.":
            tasks.sort(
                (a, b) => parseDate(b.dueDate).compareTo(parseDate(a.dueDate)));
            break;
          case "Priority Asc.":
            tasks.sort((a, b) =>
                priorityValue(a.priority).compareTo(priorityValue(b.priority)));
            break;
          case "Priority Des.":
            tasks.sort((a, b) =>
                priorityValue(b.priority).compareTo(priorityValue(a.priority)));
            break;
        }
      }
    }

    sortTasks(filteredTasks);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40.0),
            bottomRight: Radius.circular(40.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              titleSpacing: 20,
              title: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taskify',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _selectedTasks.isEmpty
                        ? IconButton(
                            icon: Icon(
                              Theme.of(context).brightness == Brightness.dark
                                  ? Icons.wb_sunny
                                  : Icons.dark_mode,
                              size: 30,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              final themeProvider = Provider.of<ThemeProvider>(
                                  context,
                                  listen: false);
                              themeProvider.toggleTheme(
                                  Theme.of(context).brightness ==
                                      Brightness.light);
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete,
                                size: 30, color: Colors.white),
                            onPressed: () async {
                              bool confirmDelete =
                                  await showDeleteConfirmationDialog(context);
                              if (confirmDelete) {
                                final taskProvider = Provider.of<TaskProvider>(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    listen: false);

                                // Store deleted tasks along with their original index positions
                                final List<
                                    Map<String,
                                        dynamic>> deletedTasks = _selectedTasks
                                    .map((taskId) {
                                      int index = taskProvider.tasks.indexWhere(
                                          (task) => task.id == taskId);
                                      if (index != -1) {
                                        return {
                                          "task": taskProvider.tasks[index],
                                          "index": index
                                        };
                                      }
                                      return null;
                                    })
                                    .whereType<Map<String, dynamic>>()
                                    .toList(); // Filter out null values safely

                                // Remove tasks from provider
                                for (var item in deletedTasks) {
                                  taskProvider.removeTask(item["task"].id);
                                }

                                // Show Snackbar with Undo button
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${deletedTasks.length} task(s) Moved to bin'),
                                    action: SnackBarAction(
                                      label: "Undo",
                                      textColor: Colors.indigo,
                                      onPressed: () {
                                        for (var item in deletedTasks) {
                                          taskProvider.insertTask(
                                              item["index"], item["task"]);
                                        }
                                      },
                                    ),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );

                                setState(() {
                                  _selectedTasks.clear();
                                });
                              }
                            },
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              Visibility(
                visible: taskProvider.tasks.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Search Tasks...",
                            hintStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(
                                color: Colors
                                    .grey, // Change this to any color you prefer
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.black,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value
                                  .toLowerCase(); // Convert to lowercase for case-insensitive search
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Filter Button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showSortOptions =
                                false; // Close sort options if filter is pressed
                            _showFilterOptions =
                                !_showFilterOptions; // Toggle filter visibility
                          });
                        },
                        icon: const Icon(Icons.filter_list),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Sort Button
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showFilterOptions =
                                false; // Close filter options if sort is pressed
                            _showSortOptions =
                                !_showSortOptions; // Toggle sort visibility
                          });
                        },
                        icon: const Icon(Icons.swap_vert),
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showFilterOptions)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ["Low", "Average", "High"].map((priority) {
                    bool isSelected = _selectedPriority == priority;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? (priority == "High"
                                  ? Colors.red
                                  : priority == "Average"
                                      ? Colors.orange
                                      : Colors.green)
                              : Colors.grey.shade300,
                          foregroundColor:
                              isSelected ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedPriority =
                                isSelected ? null : priority; // Toggle filter
                          });
                        },
                        child: Text(priority),
                      ),
                    );
                  }).toList(),
                ),
              if (_showSortOptions)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8, // Horizontal spacing
                        runSpacing: 8, // Vertical spacing
                        alignment: WrapAlignment.center,
                        children: [
                          "A - Z",
                          "Due Ascending",
                          "Priority Asc.",
                          "Z - A",
                          "Due Descending",
                          "Priority Des."
                        ].map((sortOption) {
                          bool isSelected = _selectedSort == sortOption;
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade300,
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                _selectedSort = isSelected ? null : sortOption;
                              });
                              await prefs.setString(
                                  "default_sorting", _selectedSort ?? "A - Z");
                            },
                            child: Text(sortOption),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: filteredTasks.isEmpty
                    ? const Center(
                        child: Text(
                          "No tasks available. Add a new task!",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount:
                            filteredTasks.length, // Use pre-filtered list
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index]; // Now it's safe
                          final isSelected = _selectedTasks.contains(task.id);

                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              padding: const EdgeInsets.only(left: 20),
                              alignment: Alignment.centerLeft,
                              color: Colors.red,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Confirm Deletion"),
                                  content: const Text(
                                      "Are you sure you want to delete this task?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(false), // Cancel
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(true), // Confirm
                                      child: const Text("Delete",
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (direction) {
                              final deletedTask = task;
                              final deletedIndex = taskProvider.tasks
                                  .indexWhere((t) => t.id == task.id);

                              taskProvider.removeTask(task.id);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${task.title} deleted'),
                                  action: SnackBarAction(
                                    label: "Undo",
                                    textColor: Colors.indigo,
                                    onPressed: () {
                                      taskProvider.insertTask(
                                          deletedIndex, deletedTask);
                                    },
                                  ),
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            },
                            child: GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedTasks.remove(task.id);
                                  } else {
                                    _selectedTasks.add(task.id);
                                  }
                                });
                              },
                              child: Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                color: isSelected
                                    // ignore: deprecated_member_use
                                    ? Colors.indigo.withOpacity(0.6)
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: task.status == "Completed",
                                        onChanged: (bool? newValue) {
                                          taskProvider
                                              .toggleTaskCompletion(task.id);
                                        },
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (_selectedTasks.isNotEmpty) {
                                              setState(() {
                                                if (isSelected) {
                                                  _selectedTasks
                                                      .remove(task.id);
                                                } else {
                                                  _selectedTasks.add(task.id);
                                                }
                                              });
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewTask(
                                                              task: task)));
                                            }
                                          },
                                          child: Column(
                                            spacing: 5,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task.title,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                truncateText(
                                                    task.description, 5),
                                                style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black54,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        size: 14,
                                                        color: Colors.white),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "${task.dueDate}",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewTask(
                                                            existingTask:
                                                                task)),
                                              );
                                            },
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: task.priority == "High"
                                                  ? Colors.red
                                                  : task.priority == "Average"
                                                      ? Colors.orange
                                                      : Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              task.priority,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              task.status,
                                              style: TextStyle(
                                                  color: task.status ==
                                                          "Not Started"
                                                      ? Colors.grey
                                                      : task.status ==
                                                              "In Progress"
                                                          ? Colors.blue
                                                          : task.status ==
                                                                  "Pending"
                                                              ? Colors.red
                                                              : Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NewTask()));
        },
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
            side: const BorderSide(color: Colors.black, width: 2.0)),
        child: const Icon(Icons.add_rounded, size: 35, color: Colors.black),
      ),
    );
  }
}

Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Cancel
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Confirm delete
              child: const Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false; // Default to false if the dialog is dismissed
}

String truncateText(String text, int wordLimit) {
  List<String> words = text.split(' ');
  if (words.length > wordLimit) {
    return '${words.sublist(0, wordLimit).join(' ')}...';
  }
  return text;
}
