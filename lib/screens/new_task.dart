import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/components/task_provider.dart';
import 'package:taskify/models/task.dart';
import 'package:file_picker/file_picker.dart'; // New Update

class NewTask extends StatefulWidget {
  final Task? existingTask;

  const NewTask({super.key, this.existingTask});

  @override
  // ignore: library_private_types_in_public_api
  _NewTaskState createState() => _NewTaskState();
}

class _NewTaskState extends State<NewTask> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  DateTime? selectedDate;
  String selectedPriority = "Low";
  List<String> _selectedFilePaths = []; // New Update

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.existingTask?.title ?? '');
    descriptionController =
        TextEditingController(text: widget.existingTask?.description ?? '');

    if (widget.existingTask != null) {
      selectedPriority = widget.existingTask!.priority;
      if (widget.existingTask!.dueDate != "No due date") {
        List<String> parts = widget.existingTask!.dueDate!.split('-');
        selectedDate = DateTime(
          int.parse(parts[2]), // Year
          int.parse(parts[1]), // Month
          int.parse(parts[0]), // Day
        );
      }
    }
  }

// New Update
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Enable multiple file selection
    );

    if (result != null) {
      setState(() {
        _selectedFilePaths = result.files.map((file) => file.path!).toList();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter all fields")),
      );
      return;
    }

    String formattedDueDate = selectedDate != null
        ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
        : "No due date";

    Task newOrUpdatedTask = Task(
      title: titleController.text,
      description: descriptionController.text,
      dueDate: formattedDueDate,
      priority: selectedPriority,
      filePaths: _selectedFilePaths, // New Update
    );

    var taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (widget.existingTask != null) {
      taskProvider.updateTask(widget.existingTask!, newOrUpdatedTask);
    } else {
      taskProvider.addTask(newOrUpdatedTask);
    }

    Navigator.pop(context); // Go back to Home screen
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
                child: Text(
                  widget.existingTask != null ? 'Edit Task' : 'Add New Task',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Title",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(hintText: "Task Title")),
                    const SizedBox(height: 20),
                    const Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    TextField(
                        controller: descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            hintText: "Task Description")),
                    const SizedBox(height: 20),
                    const Text("Due Date",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => _selectDate(context),
                            child: Text(
                              selectedDate == null
                                  ? "DD/MM/YYYY"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                              style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_month_rounded),
                          onPressed: () => _selectDate(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Set Priority",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ["High", "Average", "Low"].map((priority) {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedPriority == priority
                                    ? (priority == "High"
                                        ? Colors.red
                                        : priority == "Average"
                                            ? Color.fromRGBO(255, 153, 65, 1)
                                            : Colors.green)
                                    : Colors.grey.shade300,
                                foregroundColor: selectedPriority == priority
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedPriority = priority;
                                });
                              },
                              child: Text(priority),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // New Update
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Attach Reference Files",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.grey[700]
                                              : Colors.grey[300]),
                                  onPressed: _pickFile,
                                  child: const Text("Pick Files",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_selectedFilePaths.isNotEmpty)
                          Column(
                            children: _selectedFilePaths.map((filePath) {
                              return ListTile(
                                leading: const Icon(Icons.insert_drive_file,
                                    color: Colors.blue),
                                title: Text(filePath.split('/').last,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child:
                        Text(widget.existingTask != null ? "Update" : "Save"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
