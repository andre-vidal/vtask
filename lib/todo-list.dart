import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter-do/model/todo.dart';
import 'package:flutter-do/todo-item.dart';
import 'package:flutter-do/store/persistence.dart';

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
  AppStore _respository = new AppStore();
  ToDoListController _controller = ToDoListController();
  List<ToDo> _items = [];
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
    saveData();
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
        setState(() => {_items[index].completed = false});
        setState(() => {_completedEntries.remove(index)});
      } else {
        setState(() => {_items[index].completed = true});
        setState(() => {_completedEntries.add(index)});
      }
      saveData();
    }
  }

  editItem(int index) async {
    setState(() => _selectedIndex = index);
    _editItemTitleController.text = _items[_selectedIndex].description;
    final currentDueDate = _items[_selectedIndex].dueDate;
    _editItemDueDateController.text =
        currentDueDate is String ? currentDueDate : '';

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
                          maxLength: 40,
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
                            final String dueDate = await setDate();
                            if (_editItemDueDateController.text.length > 0 &&
                                dueDate.length == 0) {
                            } else {
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
                                if (_editFormKey.currentState!.validate()) {
                                  _editFormKey.currentState!.save();
                                  final currentDescription =
                                      _editItemTitleController.text;
                                  final currentDueDate =
                                      _editItemDueDateController.text;
                                  setState(() => _items[_selectedIndex]
                                      .description = currentDescription);
                                  setState(() => _items[_selectedIndex]
                                      .dueDate = currentDueDate);
                                  setState(
                                      () => _editItemTitleController.clear());
                                  setState(
                                      () => _editItemDueDateController.clear());
                                  saveData();
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
    return response is DateTime ? response.toString() : '';
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
                          maxLength: 40,
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
                            final String dueDate = await setDate();
                            setState(() => _newItemDueDateController.text =
                                dueDate.toString());
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
                                  final currentDescription =
                                      _newItemTitleController.text;
                                  final currentDueDate =
                                      _newItemDueDateController.text;
                                  setState(
                                    () => _items.add(
                                      ToDo(
                                          currentDescription is String
                                              ? currentDescription
                                              : '',
                                          currentDueDate is String
                                              ? currentDueDate
                                              : ''),
                                    ),
                                  );
                                  setState(
                                      () => _newItemTitleController.clear());
                                  setState(
                                      () => _newItemDueDateController.clear());
                                  saveData();
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

  loadData() async {
    final storedItems = await _respository.parseStringAsList('toDoList');
    setState(() {
      _items = storedItems;
    });
    _items.forEach((element) {
      if (element.completed) {
        setState(() {
          _completedEntries.add(_items.indexOf(element));
        });
      }
    });
  }

  saveData() async {
    await _respository.saveListAtString('toDoList', _items);
  }

  @override
  void initState() {
    super.initState();
    loadData();
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
                title: _items[index].description,
                dueDate: _items[index].dueDate.toString(),
                isCompleted: _items[index].completed && !widget.isSelectMode,
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
