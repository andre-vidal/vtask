import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToDoItem extends StatelessWidget {
  // Widget Props
  final String title;
  final String dueDate;
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
    this.dueDate = '-',
    required this.listIndex,
    this.isCompleted = false,
    this.isSelected = false,
    this.isSelectMode = false,
    required this.selectItem,
    required this.editItem,
  });

  String remainingDays() {
    String result = '';

    if (!isSelectMode && this.dueDate.length > 0) {
      final today = DateTime.now().millisecondsSinceEpoch;
      final due = DateTime.parse(this.dueDate).millisecondsSinceEpoch;
      final difference = due - today;
      final numberOfDays = difference / (1000 * 60 * 60 * 24);
      final prefix = '';
      final postFix = numberOfDays < 0 ? 'ago' : '';
      final absNumberOfDays = numberOfDays.floor().abs();
      result = '$prefix $absNumberOfDays days $postFix';
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0,
        margin: EdgeInsets.only(left: 10, right: 10),
        color: isCompleted
            ? Colors.grey.withOpacity(0)
            : isSelectMode && isSelected
                ? Theme.of(context).errorColor
                : Colors.grey.withAlpha(100),
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              topLeft: Radius.circular(10)),
        ),
        child: ListTile(
          tileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(10)),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
                ),
              ),
              Text(
                remainingDays(),
                style: TextStyle(
                    color: Colors.white.withAlpha(50),
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
              ),
            ],
          ),
          selected: isSelected,
          onTap: () => {selectItem(listIndex)},
          onLongPress: () => {editItem(listIndex)},
          // leading: !isSelectMode
          //     ? null
          //     : IconButton(
          //         padding: EdgeInsets.all(0.0),
          //         iconSize: 20.0,
          //         color: isSelected ? Colors.white : Colors.grey[400],
          //         disabledColor: Colors.grey[300],
          //         tooltip: 'Select Item',
          //         icon: isSelected
          //             ? const Icon(Icons.check_box)
          //             : const Icon(Icons.check_box_outline_blank),
          //         onPressed: () => {selectItem(listIndex)},
          //       ),
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
