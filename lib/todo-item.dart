import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ToDoItem extends StatelessWidget {
  // Widget Props
  final String title;
  final String dueDate;
  final String dueTime;
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
    this.dueTime = '-',
    required this.listIndex,
    this.isCompleted = false,
    this.isSelected = false,
    this.isSelectMode = false,
    required this.selectItem,
    required this.editItem,
  });

  Widget remainingDays() {
    String result = '';
    Color textColor = Colors.white.withAlpha(50);

    if (!isSelectMode && this.dueDate.length > 0) {
      final today = DateTime.now().millisecondsSinceEpoch;
      final due = DateTime.parse(this.dueDate).millisecondsSinceEpoch;
      final difference = due - today;
      final numberOfDays = (difference / (1000 * 60 * 60 * 24)).ceil();
      final prefix = '';
      final absNumberOfDays = numberOfDays.abs();
      final postFix = numberOfDays < 0 ? 'ago' : '';
      final dayText = absNumberOfDays < 2 ? 'day' : 'days';
      textColor = numberOfDays < 0
          ? Colors.orange.withAlpha(180)
          : Colors.white.withAlpha(50);

      switch (numberOfDays) {
        case 0:
          final timeDisplay =
              this.dueTime.length > 1 ? '@ ${this.dueTime}' : '';
          result = 'Today $timeDisplay';
          textColor = Colors.yellow.withAlpha(180);
          break;
        case 1:
          result = 'Tomorrow';
          break;
        case -1:
          result = 'Yesterday';
          break;
        default:
          result = '$prefix $absNumberOfDays $dayText $postFix';
          break;
      }
    }
    return Text(result,
        style: TextStyle(
            color: isCompleted ? Colors.white.withAlpha(50) : textColor,
            decoration: isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none));
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
              : Theme.of(context).accentColor.withAlpha(30),
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            topLeft: Radius.circular(10)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 15, right: isSelectMode ? 0 : 15),
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10), topRight: Radius.circular(10)),
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
            !isSelectMode
                ? remainingDays()
                : Container(
                    margin: EdgeInsets.only(left: 0),
                    padding: EdgeInsets.all(0),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(8)),
                    child: IconButton(
                      padding: EdgeInsets.only(right: 0),
                      iconSize: 24.0,
                      color: isSelected ? Colors.white : Colors.grey[400],
                      disabledColor: Colors.grey[300],
                      tooltip: 'Edit Item',
                      icon: const Icon(Icons.edit),
                      onPressed: () => {editItem(listIndex)},
                    ),
                  ),
          ],
        ),
        selected: isSelected,
        onTap: () => {selectItem(listIndex)},
        onLongPress: () => {editItem(listIndex)},
      ),
    );
  }
}
