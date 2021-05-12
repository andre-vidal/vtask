import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vtask/model/todo.dart';
import 'package:vtask/todo-item.dart';
import 'package:vtask/store/persistence.dart';

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
  final ValueChanged<bool> onSelectedItemsChange;

  // Widget Constructor
  ToDoList(
      {required this.controller,
      required Key key,
      this.isSelectMode: false,
      required this.onSelectModeChange,
      required this.onSelectedItemsChange})
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
  final _newItemDueTimeController = TextEditingController();
  final _editItemTitleController = TextEditingController();
  final _editItemDueDateController = TextEditingController();
  final _editItemDueTimeController = TextEditingController();

  deleteSelectedItems() {
    setState(() => _items.removeWhere(
        (element) => _checkedEntries.contains(_items.indexOf(element))));
    setState(() => _checkedEntries = []);
    saveData();
  }

  deleteSelectedItem() {
    setState(() {
      _items
          .removeWhere((element) => _items.indexOf(element) == _selectedIndex);
      _completedEntries.remove(_selectedIndex);
      _checkedEntries.remove(_selectedIndex);
    });
    if (_checkedEntries.length == 0) {
      setState(() => {widget.onSelectedItemsChange(false)});
    }
    saveData();
  }

  toggleAllItems() {
    if (_checkedEntries.length == _items.length) {
      setState(() {
        _checkedEntries = [];
        widget.onSelectedItemsChange(false);
      });
    } else {
      setState(() {
        _checkedEntries = [for (var i = 0; i < _items.length; i += 1) i];
        widget.onSelectedItemsChange(true);
      });
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
        setState(() {
          _checkedEntries.remove(index);
        });
        if (_checkedEntries.length == 0) {
          setState(() {
            widget.onSelectedItemsChange(false);
          });
        }
      } else {
        setState(() {
          _checkedEntries.add(index);
          widget.onSelectedItemsChange(true);
        });
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

  setDate() async {
    DateTime? response = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    return response is DateTime ? response.toString().split(' ')[0] : '';
  }

  setTime() async {
    TimeOfDay? response;

    if (this._editItemDueDateController.text.length > 0 ||
        this._newItemDueDateController.text.length > 0) {
      response = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    return response is TimeOfDay
        ? '${response.hourOfPeriod}:${response.minute} ${response.period.toString().split('.')[1]}'
        : '';
  }

  editItem(int index) async {
    setState(() => _selectedIndex = index);
    _editItemTitleController.text = _items[_selectedIndex].description;
    final currentDueDate = _items[_selectedIndex].dueDate;
    final currentDueTime = _items[_selectedIndex].dueTime;
    _editItemDueDateController.text =
        currentDueDate is String ? currentDueDate : '';
    _editItemDueTimeController.text =
        currentDueTime is String ? currentDueTime : '';

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
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _editItemDueDateController,
                                readOnly: true,
                                onTap: () async {
                                  final String dueDate = await setDate();
                                  if (_editItemDueDateController.text.length >
                                          0 &&
                                      dueDate.length == 0) {
                                  } else {
                                    setState(() => _editItemDueDateController
                                        .text = dueDate.toString());
                                  }
                                },
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Due Date'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _editItemDueTimeController,
                                readOnly: true,
                                onTap: () async {
                                  final String dueTime = await setTime();
                                  if (_editItemDueTimeController.text.length >
                                          0 &&
                                      dueTime.length == 0) {
                                  } else {
                                    setState(() => _editItemDueTimeController
                                        .text = dueTime.toString());
                                  }
                                },
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Time of Day'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text("Delete",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .errorColor
                                          .withAlpha(255))),
                              onPressed: () {
                                deleteSelectedItem();
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              onPressed: () {
                                setState(() {
                                  _editItemTitleController.clear();
                                  _editItemDueDateController.clear();
                                  _editItemDueTimeController.clear();
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              onPressed: () {
                                if (_editFormKey.currentState!.validate()) {
                                  _editFormKey.currentState!.save();
                                  final currentDescription =
                                      _editItemTitleController.text;
                                  final currentDueDate =
                                      _editItemDueDateController.text;
                                  final currentDueTime =
                                      _editItemDueTimeController.text;
                                  setState(() {
                                    _items[_selectedIndex].description =
                                        currentDescription;
                                    _items[_selectedIndex].dueDate =
                                        currentDueDate;
                                    _items[_selectedIndex].dueTime =
                                        currentDueTime;
                                    _editItemTitleController.clear();
                                    _editItemDueDateController.clear();
                                    _editItemDueTimeController.clear();
                                  });
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
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _newItemDueDateController,
                                readOnly: true,
                                onTap: () async {
                                  final String dueDate = await setDate();
                                  setState(() => _newItemDueDateController
                                      .text = dueDate.toString());
                                },
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Due Date'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(0.0),
                            child: SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _newItemDueTimeController,
                                readOnly: true,
                                onTap: () async {
                                  final String dueTime = await setTime();
                                  setState(() => _newItemDueTimeController
                                      .text = dueTime.toString());
                                },
                                decoration: InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Time of Day'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              onPressed: () {
                                setState(() {
                                  _newItemTitleController.clear();
                                  _newItemDueDateController.clear();
                                  _newItemDueTimeController.clear();
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: TextButton(
                              child: Text(
                                "Save",
                                style: TextStyle(
                                    color: Theme.of(context).accentColor),
                              ),
                              onPressed: () {
                                if (_addFormKey.currentState!.validate()) {
                                  _addFormKey.currentState!.save();
                                  final currentDescription =
                                      _newItemTitleController.text;
                                  final currentDueDate =
                                      _newItemDueDateController.text;
                                  final currentDueTime =
                                      _newItemDueTimeController.text;
                                  setState(() {
                                    _items.add(
                                      ToDo(
                                          currentDescription is String
                                              ? currentDescription
                                              : '',
                                          currentDueDate is String
                                              ? currentDueDate
                                              : '',
                                          currentDueTime is String
                                              ? currentDueTime
                                              : ''),
                                    );
                                    _newItemTitleController.clear();
                                    _newItemDueDateController.clear();
                                    _newItemDueTimeController.clear();
                                  });
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
                dueTime: _items[index].dueTime.toString(),
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
