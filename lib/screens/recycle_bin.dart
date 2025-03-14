import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/components/task_provider.dart';
import 'package:taskify/models/task.dart';
import 'package:taskify/screens/view_task.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({super.key});

  @override
  _RecycleBinState createState() => _RecycleBinState();
}

class _RecycleBinState extends State<RecycleBin> {
  Set<String> selectedTasks = {}; // Store selected task IDs

  void _toggleSelection(String taskId) {
    setState(() {
      if (selectedTasks.contains(taskId)) {
        selectedTasks.remove(taskId);
      } else {
        selectedTasks.add(taskId);
      }
    });
  }

  void _restoreSelectedTasks(TaskProvider taskProvider) {
    if (selectedTasks.isNotEmpty) {
      for (var taskId in selectedTasks) {
        taskProvider.restoreTask(taskId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selected tasks restored!")),
      );
      setState(() {
        selectedTasks.clear();
      });
    }
  }

  void _deleteSelectedTasks(TaskProvider taskProvider) {
    if (selectedTasks.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Selected Tasks?"),
          content:
              const Text("This will permanently delete the selected tasks."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                for (var taskId in selectedTasks) {
                  taskProvider.deletedTasks
                      .removeWhere((task) => task.id == taskId);
                }
                setState(() {
                  selectedTasks.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Selected tasks deleted!")),
                );
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    bool isSelectionMode = selectedTasks.isNotEmpty;

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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSelectionMode
                        ? "${selectedTasks.length} Selected"
                        : "Recycle Bin",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: isSelectionMode
                  ? [
                      IconButton(
                        icon: const Icon(Icons.restore, color: Colors.white),
                        onPressed: () => _restoreSelectedTasks(taskProvider),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.delete_forever, color: Colors.red),
                        onPressed: () => _deleteSelectedTasks(taskProvider),
                      ),
                    ]
                  : taskProvider.deletedTasks.isNotEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _showConfirmDeleteDialog(context, taskProvider);
                              },
                            ),
                          ),
                        ]
                      : [],
            ),
          ),
        ),
      ),
      body: taskProvider.deletedTasks.isEmpty
          ? const Center(
              child: Text("Recycle Bin is empty!"),
            )
          : ListView.builder(
              itemCount: taskProvider.deletedTasks.length,
              itemBuilder: (context, index) {
                Task task = taskProvider.deletedTasks[index];
                bool isSelected = selectedTasks.contains(task.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTask(task: task)));
                  },
                  onLongPress: () {
                    _toggleSelection(task.id);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.5)
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Text(task.description),
                      leading: isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                _toggleSelection(task.id);
                              },
                            )
                          : null,
                      trailing: !isSelectionMode
                          ? IconButton(
                              icon: const Icon(Icons.restore,
                                  color: Colors.green),
                              onPressed: () {
                                taskProvider.restoreTask(task.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Task restored!")),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showConfirmDeleteDialog(
      BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Empty Recycle Bin?"),
        content:
            const Text("This will permanently delete all tasks in the bin."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              taskProvider.emptyRecycleBin();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Recycle Bin emptied!")),
              );
            },
            child:
                const Text("Delete All", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
