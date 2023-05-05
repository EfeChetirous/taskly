import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:taskly/models/task.dart';

import '../helper/ad_manager.dart';

late double _deviceHeigh, _deviceWidth;

class HomePage extends StatefulWidget {
  HomePage();

  @override
  State<StatefulWidget> createState() => _createState();
}

class _createState extends State<HomePage> {
  _createState();
  final adManager = AdManager();
  @override
  void initState() {
    super.initState();
    adManager.addAds(false, true, false);
  }

  late BannerAd _bannerAd;
  String? _newTaskContent;
  Box? _box;
  BannerAd? ad;
  // List<String> testDeviceIds = ['6422E3359E034E96B533F13D183BF66B'];
  @override
  Widget build(BuildContext context) {
    // RequestConfiguration configuration =
    //     RequestConfiguration(testDeviceIds: testDeviceIds);
    // MobileAds.instance.updateRequestConfiguration(configuration);
    adManager.loadBannerAd();
    _deviceHeigh = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _bannerAd = adManager.getBannerAd();
    return Scaffold(
      bottomNavigationBar: Container(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd),
      ),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: _deviceHeigh * 0.10,
        title: Column(
          children: const [
            Text(
              "Taskly,",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 25),
            ),
            Text(
              "It's easy to take notes!",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 15),
            ),
          ],
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
            title: Text(
              task.content,
              style: TextStyle(
                  decoration:
                      task.done == false ? null : TextDecoration.lineThrough),
            ),
            subtitle: Text(task.timeStamp.toString()),
            trailing: _createPopupMenuButtons(
                task), //const Icon(Icons.more_vert), // const Icon(Icons.content_copy),
            // onTap: () {
            //   _createPopupMenuButtons(task);

            //   setState(() {});
            //   // Clipboard.setData(ClipboardData(text: task.content));
            //   // const snackBar = SnackBar(content: Text('Copied to clipboard'));
            //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
            // },
            onLongPress: () {
              _displayDeletePopup(_index);
              setState(() {});
            },
            leading: GestureDetector(
              child: Icon(
                task.done
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank_outlined,
                color: Colors.amber,
              ), //const Icon(Icons.content_copy),
              onTap: () {
                task.done = !task.done;
                _box!.putAt(_index, task.toMap());
                setState(() {});
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

  PopupMenuButton _createPopupMenuButtons(task) {
    return PopupMenuButton(
      onSelected: (value) {
        // your logic
      },
      icon: const Icon(Icons.more_vert),
      itemBuilder: (BuildContext bc) {
        return [
          PopupMenuItem(
            child: const Text("Copy"),
            value: '/hello',
            onTap: () {
              Clipboard.setData(ClipboardData(text: task.content));
              const snackBar = SnackBar(content: Text('Copied to clipboard'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          ),
          const PopupMenuItem(
            child: Text("Set Alarm"),
            value: '/about',
          )
        ];
      },
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
              keyboardType: TextInputType.multiline,
              maxLines: null,
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
      String formattedDate =
          DateFormat('yyyy-MM-dd hh:mm:ss aaa').format(DateTime.now());
      Task _task = Task(
          content: _newTaskContent!, timeStamp: formattedDate, done: false);
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