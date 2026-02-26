//Ahmed Bilal
//2380224
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// DATA_MODEL
class TodoItem {
  final String id;
  String title;
  bool isCompleted;

  TodoItem({required this.id, required this.title, this.isCompleted = false});
}

/// Manages the list of [TodoItem]s and notifies listeners of changes.
class TodoListData extends ChangeNotifier {
  final List<TodoItem> _todos;

  /// Initializes the To-Do list with some sample items.
  TodoListData()
    : _todos = [TodoItem(id: '1', title: 'walk', isCompleted: true)];

  List<TodoItem> get todos => List<TodoItem>.unmodifiable(_todos);

  /// Adds a new To-Do item to the list.

  void addTodo(String title) {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return;

    final TodoItem newTodo = TodoItem(
      // Generate a simple unique ID based on the current timestamp.
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: trimmedTitle,
    );
    _todos.add(newTodo);
    notifyListeners();
  }

  /// Toggles the completion status of a To-Do item identified by its ID.
  void toggleTodoStatus(String id) {
    final int todoIndex = _todos.indexWhere((TodoItem todo) => todo.id == id);
    if (todoIndex != -1) {
      _todos[todoIndex].isCompleted = !_todos[todoIndex].isCompleted;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider<TodoListData>(
      create: (BuildContext context) => TodoListData(),
      builder: (BuildContext context, Widget? child) => const MyTodoApp(),
    ),
  );
}

class MyTodoApp extends StatelessWidget {
  const MyTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Todo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
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
  final TextEditingController _todoInputController = TextEditingController();

  @override
  void dispose() {
    _todoInputController.dispose();
    super.dispose();
  }

  /// Handles adding a new To-Do item based on the text field's content.
  void _addTodoItem() {
    final String newTodoTitle = _todoInputController.text;
    if (newTodoTitle.isNotEmpty) {
      Provider.of<TodoListData>(context, listen: false).addTodo(newTodoTitle);
      _todoInputController.clear(); // Clear the text field after adding
      FocusScope.of(context).unfocus(); // Dismiss the keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Consumer<TodoListData>(
              builder:
                  (
                    BuildContext context,
                    TodoListData todoListData,
                    Widget? child,
                  ) {
                    if (todoListData.todos.isEmpty) {
                      return const Center(
                        child: Text('No todo items yet! Add some below.'),
                      );
                    }
                    return ListView.builder(
                      itemCount: todoListData.todos.length,
                      itemBuilder: (BuildContext context, int index) {
                        final TodoItem todo = todoListData.todos[index];
                        return TodoItemWidget(todo: todo);
                      },
                    );
                  },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _todoInputController,
                    decoration: const InputDecoration(
                      hintText: 'Add a new todo item',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                    ),
                    onSubmitted: (String value) => _addTodoItem(),
                    textInputAction:
                        TextInputAction.done, // Shows 'Done' button on keyboard
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _addTodoItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A stateless widget that displays a single To-Do item.
class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;

  const TodoItemWidget({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        todo.title,
        style: TextStyle(
          decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          color: todo.isCompleted ? Colors.grey : null,
        ),
      ),
      trailing: Checkbox(
        value: todo.isCompleted,
        onChanged: (bool? newValue) {
          // newValue will be non-null since tristate is not enabled for Checkbox.
          if (newValue != null) {
            Provider.of<TodoListData>(
              context,
              listen: false,
            ).toggleTodoStatus(todo.id);
          }
        },
      ),
    );
  }
}
