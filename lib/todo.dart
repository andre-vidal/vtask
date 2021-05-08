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
  final Function selectItem;
  final Function editItem;

  // Widget Constructor
  ToDoItem({
    required this.title,
    required this.listIndex,
    this.isCompleted = false,
    this.isSelected = false,
    this.isSelectMode = false,
    required this.selectItem,
    required this.editItem,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: isCompleted
            ? Colors.grey.withOpacity(0)
            : isSelectMode && isSelected
                ? Colors.red.withAlpha(150)
                : Colors.grey.withAlpha(100),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10)),
          ),
          title: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none)),
          selected: isSelected,
          onTap: () => {selectItem(listIndex)},
          leading: !isSelectMode
              ? null
              : IconButton(
                  padding: EdgeInsets.all(0.0),
                  iconSize: 20.0,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  disabledColor: Colors.grey[300],
                  tooltip: 'Edit Item',
                  icon: isSelected
                      ? const Icon(Icons.check_box)
                      : const Icon(Icons.check_box_outline_blank),
                  onPressed: () => {selectItem(listIndex)},
                ),
          trailing: !isSelectMode
              ? null
              : IconButton(
                  padding: EdgeInsets.all(4.0),
                  iconSize: 20.0,
                  color: isSelected ? Colors.white : Colors.grey[400],
                  disabledColor: Colors.grey[300],
                  tooltip: 'Edit Item',
                  icon: const Icon(Icons.edit),
                  onPressed: () => {editItem(listIndex)},
                ),
        ));
  }
}
