import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_do/todo-item.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class ToDoListController {
  VoidCallback deleteSelectedItems = () => {};
  VoidCallback toggleAllItems = () => {};
  VoidCallback startSelect = () => {};
  VoidCallback cancelSelect = () => {};
  VoidCallback addItem = () => {};

  void dispose() {
    //Remove any data that's will cause a memory leak/render errors in here
    deleteSelectedItems = () => {};
    toggleAllItems = () => {};
    startSelect = () => {};
    cancelSelect = () => {};
    addItem = () => {};
  }
}

class ToDoList extends StatefulWidget {
  // Widget Props
  final ToDoListController controller;
  final bool isSelectMode;
  final ValueChanged<bool> onSelectModeChange;

  // Widget Constructor
  ToDoList(
      {required this.controller,
      required Key key,
      this.isSelectMode: false,
      required this.onSelectModeChange})
      : super(key: key);

  @override
  ToDoListState createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  ToDoListController _controller = ToDoListController();
  List<String> _items = ['Item A', 'Item B', 'Item C'];
  List<int> _completedEntries = [];
  List<int> _checkedEntries = [];
  int _selectedIndex = 0;
  final _addFormKey = GlobalKey<FormState>();
  final _editFormKey = GlobalKey<FormState>();
  final _newItemTitleController = TextEditingController();
  final _newItemDueDateController = TextEditingController();
  final _editItemTitleController = TextEditingController();
  final _editItemDueDateController = TextEditingController();

  deleteSelectedItems() {
    setState(() => _items.removeWhere(
        (element) => _checkedEntries.contains(_items.indexOf(element))));
    setState(() => _checkedEntries = []);
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
      widget.onSelectModeChange(false);
    });
  }

  startSelect() {
    setState(() {
      _checkedEntries = [];
      widget.onSelectModeChange(true);
    });
  }

  selectItem(int index) {
    if (widget.isSelectMode) {
      if (_checkedEntries.contains(index)) {
        setState(() => {_checkedEntries.remove(index)});
      } else {
        setState(() => {_checkedEntries.add(index)});
      }
    } else {
      if (_completedEntries.contains(index)) {
        setState(() => {_completedEntries.remove(index)});
      } else {
        setState(() => {_completedEntries.add(index)});
      }
    }
  }

  editItem(int index) async {
    setState(() => _selectedIndex = index);
    _editItemTitleController.text = _items[_selectedIndex];
    _editItemDueDateController.text = new DateTime.now().toString();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Item"),
            titlePadding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            content: Stack(
              children: <Widget>[
                Form(
                  key: _editFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: _editItemTitleController,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: _editItemDueDateController,
                          readOnly: true,
                          onTap: () async {
                            final DateTime? dueDate = await setDate();
                            if (dueDate is DateTime) {
                              setState(() => _editItemDueDateController.text =
                                  dueDate.toString());
                            }
                          },
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Due Date'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text("cancel"),
                              onPressed: () {
                                setState(
                                    () => _editItemTitleController.clear());
                                setState(
                                    () => _editItemDueDateController.clear());
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text("save"),
                              onPressed: () {
                                if (_addFormKey.currentState!.validate()) {
                                  _addFormKey.currentState!.save();
                                  final currentValue =
                                      _editItemTitleController.text;
                                  setState(() =>
                                      _items[_selectedIndex] = currentValue);
                                  setState(
                                      () => _editItemTitleController.clear());
                                  setState(
                                      () => _editItemDueDateController.clear());
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  setDate() async {
    DateTime? response = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    return response;
  }

  addItem() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("New Item"),
            titlePadding: EdgeInsets.only(left: 20.0, top: 20.0, right: 20.0),
            contentPadding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
            content: Stack(
              children: <Widget>[
                Form(
                  key: _addFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: _newItemTitleController,
                          autofocus: true,
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Enter a description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: _newItemDueDateController,
                          readOnly: true,
                          onTap: () async {
                            final DateTime? dueDate = await setDate();
                            if (dueDate is DateTime) {
                              setState(() => _newItemDueDateController.text =
                                  dueDate.toString());
                            }
                          },
                          decoration: InputDecoration(
                              border: UnderlineInputBorder(),
                              labelText: 'Due Date'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text("cancel"),
                              onPressed: () {
                                setState(() => _newItemTitleController.clear());
                                setState(
                                    () => _newItemDueDateController.clear());
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text("save"),
                              onPressed: () {
                                if (_addFormKey.currentState!.validate()) {
                                  _addFormKey.currentState!.save();
                                  final currentValue =
                                      _newItemTitleController.text;
                                  setState(() => _items.add(
                                      currentValue is String
                                          ? currentValue
                                          : ''));
                                  setState(
                                      () => _newItemTitleController.clear());
                                  setState(
                                      () => _newItemDueDateController.clear());
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  addItem2() async {
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
    if (response is String) {
      setState(() => _items.add(response is String ? response : ''));
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.deleteSelectedItems = deleteSelectedItems;
    _controller.toggleAllItems = toggleAllItems;
    _controller.startSelect = startSelect;
    _controller.cancelSelect = cancelSelect;
    _controller.addItem = addItem;
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
                    _completedEntries.contains(index) && !widget.isSelectMode,
                isSelected:
                    _checkedEntries.contains(index) && widget.isSelectMode,
                isSelectMode: widget.isSelectMode,
                listIndex: index,
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
                  'Nothing to do',
                  style: TextStyle(color: Colors.grey),
                )
              ],
            ),
          );
  }
}
