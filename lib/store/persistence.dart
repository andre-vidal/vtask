import 'package:flutter_do/model/todo.dart';
import 'package:flutter_do/store/repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore implements Repository {
  Future<bool> saveListAtString(String key, List<ToDo> value) async {
    String payload = '';
    value.forEach((element) {
      int index = value.indexOf(element);
      bool isLast = index == value.length - 1;
      payload += '${element.toString()}${isLast ? "" : ";"}';
    });
    print(payload);
    return saveString(key, payload);
  }

  Future<List<ToDo>> parseStringAsList(String key) async {
    String payload = await getString(key);
    List<String> stringList = payload.split(';');
    List<ToDo> toDoList = [];
    stringList.forEach((element) {
      List<String> values = element.split(':');
      if (values.length > 0) {
        String description = values[0];
        String dueDate = values.length > 1 ? values[1] : '';
        bool completed = values.length > 2 ? values[2] == 'true' : false;
        ToDo newToDo = ToDo(description, dueDate, completed);
        toDoList.add(newToDo);
      }
    });
    return Future.value(toDoList);
  }

  @override
  Future<bool> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    return true;
  }

  @override
  Future<String> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);
    return value is String ? value : '';
  }
}
