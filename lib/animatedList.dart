import 'package:flutter/material.dart';

class TodoAppAnimatedList extends StatefulWidget {
  const TodoAppAnimatedList({super.key});

  @override
  State<TodoAppAnimatedList> createState() => _TodoAppAnimatedListState();
}

class _TodoAppAnimatedListState extends State<TodoAppAnimatedList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  var listButton = ['All', 'Completed', 'Uncomplete', 'Delete All'];
  int _selectedIndex = 0;
  List<Todo> list = [];
  bool isCheck = false;
  var textController = TextEditingController();
  var textFocus = FocusNode();

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
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            setState(() {
                              _addItem(Todo(title: textController.text));
                              textController.clear();
                              textFocus.requestFocus();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
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
                    backgroundColor: index == 3
                        ? Colors.red.shade700
                        : _selectedIndex == index
                            ? Colors.teal.shade700
                            : Colors.white,
                    foregroundColor: index == 3 || _selectedIndex == index
                        ? Colors.white
                        : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                  child: Text(listButton[index]),
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
    );
  }

  void _addItem(Todo todo) {
    list.add(todo);
    _listKey.currentState?.insertItem(list.length - 1);
  }

  void _removeItem(int index) {
    var removedItem = list[index];
    list.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildAnimatedTile(removedItem, index, animation),
    );
  }

  void _clearAll() {
    for (int i = list.length - 1; i >= 0; i--) {
      _removeItem(i);
    }
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
              });
            },
            onEdit: () => btnEdit(index),
            onDelete: () => _removeItem(index),
          ),
        ),
      ),
    );
  }

  void btnEdit(int index) {
    setState(() {
      textFocus.requestFocus();
      textController.text = list[index].title;
      _removeItem(index);
    });
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
