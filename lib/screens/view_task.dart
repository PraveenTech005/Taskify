import "package:flutter/material.dart";
import "package:taskify/models/task.dart";
import 'dart:io'; // New Update
import 'package:open_file/open_file.dart'; // New Update
import 'package:provider/provider.dart';
import 'package:taskify/components/task_provider.dart';

class ViewTask extends StatefulWidget {
  final Task task;
  const ViewTask({super.key, required this.task});

  @override
  State<ViewTask> createState() => _ViewTaskState();
}

class _ViewTaskState extends State<ViewTask> {
  late String selectedStatus; // Stores the selected status

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.task.status; // Set the initial status
  }

  bool isImageFile(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.gif');
  }

  void _openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  void _updateStatus(String newStatus, BuildContext context) {
    setState(() {
      selectedStatus = newStatus;
    });

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    Task updatedTask = Task(
      id: widget.task.id,
      title: widget.task.title,
      description: widget.task.description,
      dueDate: widget.task.dueDate,
      priority: widget.task.priority,
      status: newStatus, // Updated status
      filePaths: widget.task.filePaths,
    );

    taskProvider.updateTask(widget.task, updatedTask);
  }

  @override
  Widget build(BuildContext context) {
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
              titleSpacing: 0,
              title: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'View Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () => _deleteTask(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Title", widget.task.title, isBold: true),
              const SizedBox(height: 30),
              _buildInfoRow("Description", widget.task.description,
                  isWrap: true),
              const SizedBox(height: 30),
              _buildInfoRow("Due Date", widget.task.dueDate ?? "Not Set"),
              const SizedBox(height: 30),
              _buildPriorityRow(widget.task.priority),
              const SizedBox(height: 30),
              _buildStatusDropdown(context), // Dropdown for status
              const SizedBox(height: 30),

              if (widget.task.filePaths.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Attached Files",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: widget.task.filePaths.map((filePath) {
                        return ListTile(
                          leading: isImageFile(filePath)
                              ? Image.file(
                                  File(filePath),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.insert_drive_file,
                                  color: Colors.blue),
                          title: Text(filePath.split('/').last,
                              overflow: TextOverflow.ellipsis),
                          onTap: () => _openFile(filePath),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Attactments :     None",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        const Text(
          "Status: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            size: 40,
          ),
          value: selectedStatus,
          items: ["Not Started", "In Progress", "Pending", "Completed"]
              .map((status) =>
                  DropdownMenuItem(value: status, child: Text(status)))
              .toList(),
          onChanged: (newStatus) {
            if (newStatus != null) {
              _updateStatus(newStatus, context);
            }
          },
        ),
      ],
    );
  }

  void _deleteTask(BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
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

    if (confirmDelete) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final Task deletedTask = widget.task;
      taskProvider.removeTask(widget.task.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Task deleted"),
          action: SnackBarAction(
            label: "Undo",
            onPressed: () {
              taskProvider.addTask(deletedTask);
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildInfoRow(String label, String value,
      {bool isBold = false, bool isWrap = false}) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
            softWrap: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityRow(String priority) {
    return Row(
      spacing: 20,
      children: [
        const Text(
          "Priority: ",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: priority == "High"
                ? Colors.red
                : priority == "Average"
                    ? Colors.orange
                    : Colors.green,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            priority,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
