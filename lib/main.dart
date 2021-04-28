// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_do/todo-list.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

GlobalKey<ToDoListState> toDoListKey = GlobalKey();
void main() => runApp(const MyApp());

/// This is the main application widget.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Do';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  ToDoListController toDoListController = ToDoListController();
  bool _isSelectMode = false;

  void _handleIsSelectModeChange(bool newValue) {
    setState(() {
      _isSelectMode = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Do'),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: <Widget>[
              IconButton(
                  iconSize: 30.0,
                  color: Colors.blue[400],
                  disabledColor: Colors.grey[300],
                  tooltip: 'Select All',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: !_isSelectMode
                      ? null
                      : () {
                          toDoListController.cancelSelect();
                        }),
              Spacer(),
              IconButton(
                  iconSize: 30.0,
                  color: Colors.blue[400],
                  disabledColor: Colors.grey[300],
                  tooltip: 'Select All',
                  icon: const Icon(Icons.select_all),
                  onPressed: !_isSelectMode
                      ? null
                      : () {
                          toDoListController.toggleAllItems();
                        }),
              Spacer(),
              Spacer(),
              Spacer(),
              Spacer(),
              IconButton(
                  iconSize: 30.0,
                  color: Colors.red[400],
                  disabledColor: Colors.grey[300],
                  tooltip: 'Delete Item(s)',
                  icon: const Icon(Icons.delete),
                  onPressed: !_isSelectMode
                      ? null
                      : () async {
                          if (await confirm(
                            context,
                            title: Text('Confirm'),
                            content: Text(
                                'Would you like to remove the selected item(s)?'),
                            textOK: Text('Yes'),
                            textCancel: Text('No'),
                          )) {
                            toDoListController.deleteSelectedItems();
                            return;
                          }
                          return;
                        }),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              toDoListController.addItem();
            },
            tooltip: 'Add Item',
            child: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: ToDoList(
            controller: toDoListController,
            key: toDoListKey,
            isSelectMode: _isSelectMode,
            onSelectModeChange: _handleIsSelectModeChange));
  }
}
