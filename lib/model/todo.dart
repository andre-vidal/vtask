class ToDo {
  String description;
  String? dueDate;
  bool completed = false;

  ToDo(this.description, [this.dueDate, this.completed = false]);

  @override
  String toString() {
    return '$description:$dueDate:$completed';
  }
}
