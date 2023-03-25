import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly/models/task.dart';

late double _deviceHeigh, _deviceWidth;

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() => _createState();
}

class _createState extends State<HomePage> {
  _createState();

  @override
  void initState() {
    super.initState();
  }

  String? _newTaskContent;
  Box? _box;

  @override
  Widget build(BuildContext context) {
    _deviceHeigh = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeigh * 0.15,
        title: const Text(
          "Taskly!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.amber,
      ),
      body: _taskView(),
      floatingActionButton: _addFloatingButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
        future: Hive.openBox("Tasks"),
        builder: (BuildContext _context, AsyncSnapshot _snapShot) {
          if (_snapShot.hasData) {
            _box = _snapShot.data;
            return _taskList();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext _context, int _index) {
          var task = Task.fromMap(tasks[_index]);

          return ListTile(
            title: SelectableText(
              task.content,
              style: TextStyle(
                  decoration:
                      task.done == false ? null : TextDecoration.lineThrough),
            ),
            subtitle: Text(task.timeStamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.amber,
            ),
            onTap: () {
              task.done = !task.done;
              _box!.putAt(_index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _displayDeletePopup(_index);
              setState(() {});
            },
            leading: GestureDetector(
              child: const Icon(Icons.content_copy),
              onTap: () {
                Clipboard.setData(ClipboardData(text: task.content));
                final snackBar = SnackBar(content: Text('Copied to clipboard'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
            isThreeLine: true,
          );
        });
  }

  FloatingActionButton _addFloatingButton() {
    return FloatingActionButton(
      onPressed: (() => _displayTaskPopup()),
      child: const Icon(Icons.add),
      backgroundColor: Colors.amber,
    );
  }

  void _displayDeletePopup(int index) {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("Delete Task!"),
            content: const Text('Are you sure?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _deleteTheTask(index),
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  void _deleteTheTask(int index) {
    _box!.deleteAt(index);
    setState(() {});
    Navigator.pop(context);
  }

  void _displayTaskPopup() {
    showDialog(
        context: context,
        builder: (BuildContext _context) {
          return AlertDialog(
            title: const Text("New Task"),
            content: TextField(
              onSubmitted: (_value) {
                _addNewTask();
              },
              onChanged: (_value) {
                setState(() {
                  _newTaskContent = _value;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _addNewTask(),
                child: const Text('OK'),
              )
            ],
          );
        });
  }

  void _addNewTask() {
    if (_newTaskContent != null) {
      Task _task = Task(
          content: _newTaskContent!, timeStamp: DateTime.now(), done: false);
      _box!.add(_task.toMap());
      setState(() {
        _newTaskContent = null;
        Navigator.pop(context);
      });
    }
  }
}
// if (_newTaskContent != null) {
//                 Task _task = Task(
//                     content: _newTaskContent!,
//                     timeStamp: DateTime.now(),
//                     done: false);
//                 _box!.add(_task.toMap());
//                 setState(() {
//                   _newTaskContent = null;
//                   Navigator.pop(context);
               
//           } );
// }