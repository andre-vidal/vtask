class ToDo {
  String description;
  String? dueDate;
  String? dueTime;
  bool completed = false;

  ToDo(this.description, [this.dueDate, this.dueTime, this.completed = false]);

  @override
  String toString() {
    return '$description~$dueDate~$dueTime~$completed';
  }
}
