// Import library Flutter untuk UI components
import 'package:flutter/material.dart';

// Model class untuk Task = blueprint/template untuk objek Task
class Task {
  String title;
  bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  void toggle() {
    isCompleted = !isCompleted;
  }

  @override
  String toString() {
    return 'Task{title: $title, isCompleted: $isCompleted}';
  }
}

// Function utama yang dijalankan pertama kali
void main() {
  runApp(const MyApp());
}

// Deklarasi class MyApp yang extends (turunan dari) StatelessWidget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App Pemula',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  // 🔧 Helper function untuk menampilkan SnackBar
  void _showSnackBar(String message, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            if (icon != null) const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _addTask() {
    String newTaskTitle = _taskController.text.trim();

    if (newTaskTitle.isEmpty) {
      _showSnackBar(
        "Task tidak boleh kosong!",
        Colors.orange,
        icon: Icons.warning,
      );
      return;
    }

    bool isDuplicate = _tasks.any(
      (task) => task.title.toLowerCase() == newTaskTitle.toLowerCase(),
    );
    if (isDuplicate) {
      _showSnackBar(
        'Task "$newTaskTitle" sudah ada!',
        Colors.blue,
        icon: Icons.info,
      );
      return;
    }

    if (newTaskTitle.length > 100) {
      _showSnackBar(
        "Task terlalu panjang! Maksimal 100 karakter.",
        Colors.red,
        icon: Icons.error,
      );
      return;
    }

    setState(() {
      _tasks.add(Task(title: newTaskTitle));
    });

    _taskController.clear();

    _showSnackBar(
      'Task "$newTaskTitle" berhasil ditambahkan!',
      Colors.green,
      icon: Icons.check_circle,
    );

    debugPrint('Task ditambahkan: $newTaskTitle');
  }

  void _removeTask(int index) async {
    Task taskToDelete = _tasks[index];

    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah kamu yakin ingin menghapus task ini?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '"${taskToDelete.title}"',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _tasks.removeAt(index);
      });
      _showSnackBar(
        'Task "${taskToDelete.title}" dihapus',
        Colors.red,
        icon: Icons.delete,
      );
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].toggle();
    });

    Task task = _tasks[index];
    if (task.isCompleted) {
      _showSnackBar(
        'Selamat! Task "${task.title}" selesai! 🎉',
        Colors.green,
        icon: Icons.celebration,
      );
    } else {
      _showSnackBar(
        'Task "${task.title}" ditandai belum selesai',
        Colors.blue,
        icon: Icons.undo,
      );
    }
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ===== Input Form =====
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _taskController,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'Ketik task baru di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.edit),
                      counterText: '',
                      helperText: 'Maksimal 100 karakter',
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addTask,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Add Task',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Statistik =====
            if (_tasks.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Statistik Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          'Total',
                          _tasks.length,
                          Icons.list,
                          Colors.blue,
                        ),
                        _buildStatItem(
                          'Selesai',
                          _tasks.where((task) => task.isCompleted).length,
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatItem(
                          'Belum',
                          _tasks.where((task) => !task.isCompleted).length,
                          Icons.pending,
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ===== List Tasks =====
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada task',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tambahkan task pertamamu di atas!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          Task task = _tasks[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: task.isCompleted
                                  ? Colors.green[50]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: task.isCompleted
                                  ? Border.all(
                                      color: Colors.green[200]!,
                                      width: 2,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: task.isCompleted ? 0.7 : 1.0,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: task.isCompleted
                                      ? Colors.green[100]
                                      : Colors.blue[100],
                                  child: task.isCompleted
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green[700],
                                        )
                                      : Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: Colors.blue[700],
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: task.isCompleted
                                        ? Colors.grey[600]
                                        : Colors.black87,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Text(
                                  task.isCompleted
                                      ? 'Selesai ✅'
                                      : 'Belum selesai',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: task.isCompleted
                                        ? Colors.green[600]
                                        : Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        task.isCompleted
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: task.isCompleted
                                            ? Colors.green[600]
                                            : Colors.grey[400],
                                      ),
                                      onPressed: () => _toggleTask(index),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: Colors.red[400],
                                      ),
                                      onPressed: () => _removeTask(index),
                                    ),
                                  ],
                                ),
                                onTap: () => _toggleTask(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
