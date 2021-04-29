// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    return MaterialApp(
        title: _title,
        home: MyStatefulWidget(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Define the default brightness and colors.
          brightness: Brightness.dark,
          primaryColor: Colors.cyan[600],
          accentColor: Colors.cyan[600],

          // Define the default font family.
          fontFamily: 'Roboto',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ));
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

  Future<bool> _onWillPop() {
    bool result = false;
    if (_isSelectMode) {
      setState(() {
        _isSelectMode = false;
      });
    } else {
      result = true;
    }
    return Future.value(result);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Do'),
          backgroundColor: Theme.of(context).primaryColor,
          backwardsCompatibility: false,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.black,
              // statusBarColor: Theme.of(context).primaryColor,
              statusBarIconBrightness: Brightness.light),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          child: Row(
            children: <Widget>[
              IconButton(
                  iconSize: 30.0,
                  color: Theme.of(context).accentColor,
                  disabledColor: Colors.grey.withOpacity(.3),
                  tooltip: 'Cancel Select',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: !_isSelectMode
                      ? null
                      : () {
                          toDoListController.cancelSelect();
                        }),
              Spacer(),
              IconButton(
                  iconSize: 30.0,
                  color: Theme.of(context).accentColor,
                  disabledColor: Colors.grey.withOpacity(.3),
                  tooltip: 'Select All',
                  icon: const Icon(Icons.select_all_outlined),
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
                  color: Colors.amber[900],
                  disabledColor: Colors.grey.withOpacity(.3),
                  tooltip: 'Delete Item(s)',
                  icon: const Icon(Icons.delete_outline),
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
            onSelectModeChange: _handleIsSelectModeChange),
      ),
    );
  }
}
