import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToDoItem extends StatelessWidget {
  // Widget Props
  final String title;
  final int listIndex;
  final bool isCompleted;
  final bool isSelected;
  final bool isSelectMode;
  // Widget Functions
  final Function toggleCompleted;
  final Function selectItem;
  final Function editItem;

  // Widget Constructor
  ToDoItem({
    required this.title,
    required this.listIndex,
    this.isCompleted = false,
    this.isSelected = false,
    this.isSelectMode = false,
    required this.toggleCompleted,
    required this.selectItem,
    required this.editItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none)),
      tileColor: isCompleted ? Colors.green[200] : Colors.grey[200],
      selectedTileColor: Colors.blue[100],
      selected: isSelected,
      onTap: () => {toggleCompleted(listIndex)},
      onLongPress: () => {selectItem(listIndex)},
      leading: !isSelectMode
          ? null
          : Icon(
              isSelected
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank,
              color: isSelected ? Colors.blue[400] : Colors.grey[400],
              size: 24.0,
              semanticLabel: 'Select',
            ),
      trailing: !isSelectMode
          ? null
          : IconButton(
              padding: EdgeInsets.all(4.0),
              iconSize: 24.0,
              color: isSelected ? Colors.blue[400] : Colors.grey[400],
              disabledColor: Colors.grey[300],
              tooltip: 'Edit Item',
              icon: const Icon(Icons.edit),
              onPressed: () => {editItem(listIndex)},
            ),
    );
  }
}
