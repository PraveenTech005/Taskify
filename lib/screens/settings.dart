import "dart:convert";
import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:taskify/components/task_provider.dart";
import "package:taskify/components/theme_provider.dart";
import 'package:path_provider/path_provider.dart';
import "package:taskify/models/task.dart";
import "package:taskify/screens/help.dart";
import "package:taskify/screens/recycle_bin.dart";

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String selectedSorting = "A - Z"; // Default sorting method
  String backupStatus = "Backup Now";
  int storageSize = 0;

  List<String> sortingMethods = [
    "A - Z",
    "Z - A",
    "Due Ascending",
    "Due Descending",
    "Priority Ascending",
    "Priority Descending"
  ];

  @override
  void initState() {
    super.initState();
    _calculateStorageUsage();
    _loadSortingPreference();
  }

  Future<void> _calculateStorageUsage() async {
    int totalSize = 0;

    try {
      // Get stored task size in memory
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      List<Task> tasks = taskProvider.tasks;
      String jsonData = jsonEncode(tasks.map((task) => task.toMap()).toList());
      totalSize += utf8.encode(jsonData).length; // Convert JSON to bytes

      // Get backup files size
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${directory.path}/Taskify/Backups');
      if (await backupDir.exists()) {
        List<FileSystemEntity> files = backupDir.listSync();
        for (var file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error calculating storage size: $e");
    }

    setState(() {
      storageSize = totalSize;
    });
  }

  // Function to format size to MB/KB
  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(2)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
  }

  Future<void> _loadSortingPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? savedSorting = prefs.getString("default_sorting");
      if (savedSorting != null && sortingMethods.contains(savedSorting)) {
        selectedSorting = savedSorting;
      } else {
        selectedSorting = "A - Z"; // Ensure it's a valid choice
      }
    });
  }

  Future<void> _saveSortingPreference(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("default_sorting", value);
  }

  Future<void> _backupData() async {
    try {
      // Get the app's document directory path
      final directory = await getApplicationDocumentsDirectory();
      final backupDirectory = Directory('${directory.path}/Taskify/Backups');

      // Ensure directory exists
      if (!await backupDirectory.exists()) {
        await backupDirectory.create(recursive: true);
      }

      // Fetch tasks
      // ignore: use_build_context_synchronously
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      List<Task> tasks = taskProvider.tasks;

      // Convert tasks to JSON
      List<Map<String, dynamic>> taskList =
          tasks.map((task) => task.toMap()).toList();
      String jsonData = jsonEncode(taskList);

      // Create backup file
      final file = File(
          '${backupDirectory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json');

      // Write to the file and check if successful
      await file.writeAsString(jsonData);
      // ignore: avoid_print
      print("Backup file written: ${file.path}");

      // Update backup status
      setState(() {
        backupStatus = "Backup Success";
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Backup saved successfully!")));

      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          backupStatus = "Backup Now";
        });
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save backup!")));
    }
  }

  Future<void> _restoreData() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/Taskify/Backups');
    final backupFile = File('${backupDir.path}/tasks_backup.json');

    if (await backupFile.exists()) {
      try {
        String jsonString = await backupFile.readAsString();
        List<dynamic> jsonData = jsonDecode(jsonString);

        List<Task> restoredTasks = jsonData.map((taskData) {
          return Task.fromMap(taskData);
        }).toList();

        // ignore: use_build_context_synchronously
        var taskProvider = Provider.of<TaskProvider>(context, listen: false);
        taskProvider.setTasks(restoredTasks);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data restored successfully!")),
        );
      } catch (e) {
        // ignore: avoid_print
        print("Error restoring data: $e");
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to restore data")),
        );
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Backup Found")),
      );
    }
  }

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
                  // ignore: deprecated_member_use
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
                        'Settings',
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
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Column(
          spacing: 20,
          children: [
            Column(
              spacing: 20,
              children: [
                Row(
                  children: [
                    Text(
                      "Theme",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _themeButton(
                      context,
                      icon: Icons.wb_sunny,
                      label: "Light",
                      themeMode: ThemeMode.light,
                    ),
                    _themeButton(
                      context,
                      icon: Icons.dark_mode,
                      label: "Dark",
                      themeMode: ThemeMode.dark,
                    ),
                    _themeButton(
                      context,
                      icon: Icons.phone_android_rounded,
                      label: "Device",
                      themeMode: ThemeMode.system,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(),
            Row(
              children: [
                const Text(
                  "Default Sorting: ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortingMethods.contains(selectedSorting)
                      ? selectedSorting
                      : "A - Z",
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedSorting = newValue;
                      });
                      _saveSortingPreference(newValue); // Save selection
                    }
                  },
                  items: sortingMethods
                      .map<DropdownMenuItem<String>>((String method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(),
            Row(
              spacing: 5,
              children: [
                const Text(
                  "Backup Status : ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Make the Backup Button take remaining space
                ElevatedButton(
                    onPressed: () async {
                      await _backupData();
                    },
                    child: Text(backupStatus,
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold))),
                ElevatedButton(
                    onPressed: () async {
                      await _restoreData();
                    },
                    child: Text("Restore",
                        style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            SizedBox(),
            Row(
              children: [
                Text(
                  "Storage Usage : ",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatSize(storageSize),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecycleBin()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Recycle Bin",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HelpScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "Help",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Reset Theme to Light
                        final themeProvider =
                            Provider.of<ThemeProvider>(context, listen: false);
                        themeProvider.toggleTheme(false); // false = Light mode

                        // Reset Sorting to "A - Z"
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("default_sorting", "A - Z");

                        setState(() {
                          selectedSorting = "A - Z"; // Update UI
                        });

                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Settings restored to defaults!")),
                        );
                      },
                      child: Text(
                        "Restore Defaults",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeButton(BuildContext context,
      {required IconData icon,
      required String label,
      required ThemeMode themeMode}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isSelected = themeProvider.themeMode == themeMode;

    return GestureDetector(
      onTap: () {
        if (themeMode == ThemeMode.system) {
          themeProvider.setSystemTheme(); // ✅ Fix: Follow system theme
        } else {
          themeProvider.toggleTheme(themeMode == ThemeMode.dark);
        }
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 30,
              color:
                  isSelected ? Colors.white : Theme.of(context).iconTheme.color,
            ),
          ),
          Text(label,
              style: TextStyle(
                color: isSelected
                    ? Colors.blue
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
              )),
        ],
      ),
    );
  }
}
