import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:taskify/components/task_provider.dart";
import "package:taskify/models/task.dart";
import "package:taskify/screens/view_task.dart";

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TasksState createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  String selectedStatus = "Not Started";
  // ignore: prefer_final_fields
  Set<String> _selectedTasks = {}; // Track selected tasks

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final filteredTasks = taskProvider.tasks
        .where((task) => task.status == selectedStatus)
        .toList();

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
                      'Tasks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectedTasks.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: _deleteSelectedTasks,
                          ),
                        if (filteredTasks
                            .isNotEmpty) // Show "Delete All" only when tasks exist
                          TextButton(
                            onPressed: _deleteAllTasks,
                            child: Text(
                              "Delete ( $selectedStatus )",
                              style: TextStyle(
                                fontFamily: "Changa",
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterButtons(),
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      "No tasks available. Add a new task!",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      final isSelected = _selectedTasks.contains(task.id);

                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          color: Colors.red,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Delete Task?"),
                              content: Text(
                                  "Are you sure you want to delete '${task.title}'?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Delete",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          _removeTaskWithUndo(task);
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
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            color: isSelected
                                // ignore: deprecated_member_use
                                ? Colors.indigo.withOpacity(0.6)
                                : Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                            child: ListTile(
                              title: Text(
                                task.title,
                                style: selectedStatus == "Completed"
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(task.description),
                                  const SizedBox(height: 5),
                                  Text("Due: ${task.dueDate}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              trailing: _getStatusIcon(task.status),
                              onTap: () {
                                if (_selectedTasks.isNotEmpty) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedTasks.remove(task.id);
                                    } else {
                                      _selectedTasks.add(task.id);
                                    }
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ViewTask(task: task)),
                                  );
                                }
                              },
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
  }

  void _removeTaskWithUndo(Task task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.removeTask(task.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${task.title} deleted"),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.indigo,
          onPressed: () {
            taskProvider.addTask(task);
          },
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    List<String> statuses = [
      "Not Started",
      "In Progress",
      "Pending",
      "Completed"
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: statuses.map((status) {
          bool isSelected = selectedStatus == status;
          return ElevatedButton(
            onPressed: () {
              setState(() {
                selectedStatus = status;
                _selectedTasks.clear(); // Clear selection when switching status
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
                foregroundColor: isSelected ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 15)),
            child: Text(status, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status) {
      case "Not Started":
        return const Icon(Icons.do_not_disturb_on_sharp, color: Colors.grey);
      case "In Progress":
        return const Icon(Icons.directions_run_outlined, color: Colors.blue);
      case "Pending":
        return const Icon(Icons.pending_actions_rounded, color: Colors.red);
      case "Completed":
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.device_unknown);
    }
  }

  void _deleteAllTasks() async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete All $selectedStatus Tasks?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      // ignore: use_build_context_synchronously
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final deletedTasks = taskProvider.tasks
          .where((task) => task.status == selectedStatus)
          .toList();

      taskProvider.removeTasksByStatus(selectedStatus);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All $selectedStatus tasks deleted"),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Undo",
            textColor: Colors.indigo,
            onPressed: () {
              for (var task in deletedTasks) {
                taskProvider.addTask(task);
              }
            },
          ),
        ),
      );
    }
  }

  void _deleteSelectedTasks() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final deletedTasks = taskProvider.tasks
        .where((task) => _selectedTasks.contains(task.id))
        .toList();

    for (var taskId in _selectedTasks) {
      taskProvider.removeTask(taskId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_selectedTasks.length} task(s) deleted"),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.indigo,
          onPressed: () {
            for (var task in deletedTasks) {
              taskProvider.addTask(task);
            }
          },
        ),
      ),
    );

    setState(() {
      _selectedTasks.clear();
    });
  }
}
