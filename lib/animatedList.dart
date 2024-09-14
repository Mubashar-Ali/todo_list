import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoAppAnimatedList extends StatefulWidget {
  const TodoAppAnimatedList({super.key});

  @override
  State<TodoAppAnimatedList> createState() => _TodoAppAnimatedListState();
}

class _TodoAppAnimatedListState extends State<TodoAppAnimatedList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var listButton = ['All', 'Completed', 'Uncomplete'];
  int _selectedIndex = 0;
  List<Todo> list = [];
  bool isCheck = false;
  var textController = TextEditingController();
  var textFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    getter();
  }

  void getter() async {
    final sp = await SharedPreferences.getInstance();
    List<String> savedTodos = sp.getStringList('todos') ?? [];

    list = savedTodos.map((todoString) {
      Map<String, dynamic> todoMap = jsonDecode(todoString);
      return Todo(title: todoMap['title'], isCheck: todoMap['isCheck']);
    }).toList();

    setState(() {});
  }

  void savedTodos() async {
    final sp = await SharedPreferences.getInstance();

    List<String> todoString = list.map((todo) {
      return jsonEncode({'title': todo.title, 'isCheck': todo.isCheck});
    }).toList();

    sp.setStringList('todos', todoString);
    setState(() {});
  }

  void addItem() async {
    String txt = textController.text;
    if (txt.isNotEmpty) {
      list.add(Todo(title: txt));
      textController.clear();
      textFocus.requestFocus();
      savedTodos();

      _listKey.currentState?.insertItem(list.length - 1);
    }
  }

  void btnDelete(int index) {
    var removedItem = list[index];

    list.removeAt(index);
    savedTodos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task Deleted'),
        duration: Duration(seconds: 1),
      ),
    );

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedTile(removedItem, index, animation),
    );
  }

  void btnEdit(int index) {
    textFocus.requestFocus();
    textController.text = list[index].title;
    btnDelete(index);
    savedTodos();
  }

  void _clearAll() {
    list.clear();
    savedTodos();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todo List App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    focusNode: textFocus,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter Item',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.add, color: Colors.teal.shade700),
                        onPressed: addItem,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              // spacing: 20,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                listButton.length,
                (index) => ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index != 3 ? index : _selectedIndex;
                      if (index == 3) {
                        _clearAll();
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIndex == index
                        ? Colors.teal.shade700
                        : Colors.white,
                    foregroundColor:
                        _selectedIndex == index ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    listButton[index],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
            const Divider(height: 30, color: Colors.teal, thickness: .4),
            Expanded(
              child: list.isNotEmpty
                  ? AnimatedList(
                      key: _listKey,
                      initialItemCount: list.length,
                      itemBuilder: (context, index, animation) {
                        if (_selectedIndex == 0 ||
                            (_selectedIndex == 1 && list[index].isCheck) ||
                            (_selectedIndex == 2 && !list[index].isCheck)) {
                          return _buildAnimatedTile(
                              list[index], index, animation);
                        }
                        return const SizedBox();
                      },
                    )
                  : Center(
                      child: Text(
                        'No Tasks!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: _clearAll,
        child: const Text(
          'Delete All',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAnimatedTile(Todo todo, int index, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        ),
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: MyTile(
            todo: todo,
            onCheck: (value) {
              setState(() {
                list[index].isCheck = value;
                savedTodos();
              });
            },
            onEdit: () => btnEdit(index),
            onDelete: () => btnDelete(index),
          ),
        ),
      ),
    );
  }
}

class MyTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged onCheck;

  const MyTile({
    super.key,
    required this.todo,
    required this.onCheck,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: todo.isCheck,
        onChanged: onCheck,
        activeColor: Colors.teal.shade700,
      ),
      title: Text(
        todo.title,
        style: TextStyle(
          color: todo.isCheck ? Colors.black54 : Colors.black,
          decoration:
              todo.isCheck ? TextDecoration.lineThrough : TextDecoration.none,
          decorationColor: Colors.black54,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: Colors.blue.shade900),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class Todo {
  String title;
  bool isCheck;

  Todo({required this.title, this.isCheck = false});
}
