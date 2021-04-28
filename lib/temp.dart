import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_do/todo-item.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

typedef BoolCallback = bool Function();

class ToDoListController {
  VoidCallback deleteSelectedItems = () => {};
  VoidCallback toggleAllItems = () => {};
  VoidCallback cancelSelect = () => {};
  VoidCallback addItem = () => {};
  bool isSelectMode = false;
  List<int> checkedEntries = [];

  void dispose() {
    //Remove any data that's will cause a memory leak/render errors in here
    deleteSelectedItems = () => {};
    toggleAllItems = () => {};
    cancelSelect = () => {};
    addItem = () => {};
    isSelectMode = false;
    checkedEntries = [];
  }
}

class ToDoList extends StatefulWidget {
  // Widget Props
  final ToDoListController controller;

  // Widget Constructor
  ToDoList({required this.controller});

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  ToDoListController _controller = ToDoListController();
  List<String> _items = ['Item A', 'Item B', 'Item C'];
  List<int> _completedEntries = [];
  List<int> _checkedEntries = [];
  bool _isSelectMode = false;
  int _selectedIndex = 0;

  deleteSelectedItems() {
    setState(() => _items.removeWhere(
        (element) => _checkedEntries.contains(_items.indexOf(element))));
    setState(() => _checkedEntries = []);
    setState(() => _isSelectMode = false);
  }

  toggleAllItems() {
    if (_checkedEntries.length == _items.length) {
      setState(() => _checkedEntries = []);
    } else {
      setState(() =>
          _checkedEntries = [for (var i = 0; i < _items.length; i += 1) i]);
    }
  }

  cancelSelect() {
    setState(() {
      _checkedEntries = [];
      _isSelectMode = false;
    });
  }

  toggleCompleted(int index) {
    if (_isSelectMode) {
      if (_checkedEntries.contains(index)) {
        setState(() => {_checkedEntries.remove(index)});
        if (_checkedEntries.length == 0) {
          setState(() => _isSelectMode = false);
        }
      } else {
        setState(() => {_checkedEntries.add(index)});
      }
    } else {
      if (_completedEntries.contains(index)) {
        setState(() => {_completedEntries.remove(index)});
      } else {
        setState(() => {_completedEntries.add(index)});
      }
      print(_isSelectMode);
    }
  }

  selectItem(int index) {
    if (!_isSelectMode) {
      setState(() => _checkedEntries.add(index));
      setState(() => _isSelectMode = _checkedEntries.length > 0);
      setState(() => _controller.isSelectMode = _checkedEntries.length > 0);
    }
  }

  editItem(int index) async {
    setState(() => _selectedIndex = index);
    String? initialValue = _items[_selectedIndex];
    String? response = await prompt(
      context,
      title: Text('Edit item'),
      initialValue: initialValue,
      textOK: Text('Ok'),
      textCancel: Text('Cancel'),
      hintText: 'Enter an item description',
      minLines: 1,
      maxLines: 1,
      autoFocus: true,
      textCapitalization: TextCapitalization.words,
    );
    print(response is String ? response : '');
    if (response is String) {
      setState(() => _items[_selectedIndex] = response);
    }
  }

  addItem() async {
    String? response = await prompt(
      context,
      title: Text('New item'),
      initialValue: '',
      textOK: Text('Ok'),
      textCancel: Text('Cancel'),
      hintText: 'Enter an item description',
      minLines: 1,
      maxLines: 1,
      autoFocus: true,
      obscureText: false,
      obscuringCharacter: '•',
      textCapitalization: TextCapitalization.words,
    );
    print(response is String ? response : '');
    if (response is String) {
      setState(() => _items.add(response is String ? response : ''));
    }
  }

  bool isSelectMode() {
    return _isSelectMode;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.deleteSelectedItems = deleteSelectedItems;
    _controller.toggleAllItems = toggleAllItems;
    _controller.cancelSelect = cancelSelect;
    _controller.addItem = addItem;
    _controller.isSelectMode = isSelectMode();
    _controller.checkedEntries = _checkedEntries;
  }

  @override
  Widget build(BuildContext context) {
    return _items.length > 0
        ? ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: _items.length,
            itemBuilder: (BuildContext context, int index) {
              return ToDoItem(
                title: _items[index],
                isCompleted:
                    _completedEntries.contains(index) && !_isSelectMode,
                isSelected: _checkedEntries.contains(index) && _isSelectMode,
                isSelectMode: _isSelectMode,
                listIndex: index,
                toggleCompleted: toggleCompleted,
                selectItem: selectItem,
                editItem: editItem,
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 8.0),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.list,
                  color: Colors.grey[300],
                  size: 60.0,
                  semanticLabel: 'List Icon',
                ),
                const Text(
                  'No items',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          );
  }
}
