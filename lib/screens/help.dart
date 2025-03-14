import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Custom height for AppBar
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40.0), // Rounded bottom left
            bottomRight: Radius.circular(40.0), // Rounded bottom right
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue, // Set background color
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8, // Soft shadow effect
                  spreadRadius: 2,
                ),
              ],
            ),
            child: AppBar(
                backgroundColor: Colors.transparent, // Transparent AppBar
                elevation: 0, // Remove default shadow
                titleSpacing: 20, // Adjust spacing for title
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Help & FAQ's",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "General",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("What is Taskify?",
                  "Taskify is a task management app that helps you organize, track, and prioritize your tasks efficiently."),
              _faqItem("How do I add a new task?",
                  "Tap the '+' (Add Task) button on the home screen, enter the task details, and tap Save."),
              _faqItem("Can I edit a task after creating it?",
                  "Yes! Tap the edit icon on any task to modify its details."),
              _faqItem("How do I mark a task as completed?",
                  "Simply tap the checkbox next to the task to mark it as completed."),
            ]),
            SizedBox(height: 30),
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Task Management",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("How do I delete a task?",
                  "You can swipe left on a task to delete it. A confirmation dialog will appear before deletion."),
              _faqItem("How do I select multiple tasks?",
                  "Long press on a task to enter selection mode. You can then tap other tasks to select them."),
              _faqItem("Can I recover a deleted task?",
                  "Yes! Deleted tasks move to the Recycle Bin, where you can restore them."),
              _faqItem("How do I prioritize tasks?",
                  "While creating or editing a task, choose from High, Medium, or Low priority."),
            ]),
            SizedBox(height: 30),
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Search, Filter & Sorting",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("How do I search for a task?",
                  "Use the search bar on the home screen to quickly find a task by title or description."),
              _faqItem("How do I filter tasks?",
                  "Tap the filter icon to filter tasks by priority, completion status, or due date."),
              _faqItem("Can I sort my tasks?",
                  "Yes! Tap the sort icon to sort tasks by date, priority, or name."),
            ]),
            SizedBox(height: 30),
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Storage & Backup",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("How do I back up my tasks?",
                  "Go to Settings > Backup, then tap the Backup button to save your tasks to local storage."),
              _faqItem("Can I restore my tasks from a backup?",
                  "Yes, go to Settings > Backup and tap Restore to reload a previously saved backup."),
              _faqItem("Where is my backup stored?",
                  "Backups are saved in the app’s local storage at: Android/data/com.yourapp.taskify/files/backup/"),
              _faqItem("How do I check storage usage?",
                  "Visit Settings > Storage Usage to see how much space your tasks are using."),
            ]),
            SizedBox(height: 30),
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Recycle Bin",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("What happens when I delete a task?",
                  "Deleted tasks move to the Recycle Bin and remain there until permanently deleted."),
              _faqItem("How do I restore a task from the Recycle Bin?",
                  "Go to Recycle Bin, find the task, and tap Restore."),
              _faqItem(
                  "How do I permanently delete tasks from the Recycle Bin?",
                  "Open the Recycle Bin, select tasks, and tap Delete Permanently."),
            ]),
            SizedBox(height: 30),
            Column(children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Others",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              _faqItem("Can I change the app theme?",
                  "Yes! Tap the theme icon in the top right corner to toggle between light and dark mode."),
            ]),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _faqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
            child: Text("        $answer"),
          )
        ],
      ),
    );
  }
}
