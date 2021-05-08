// import 'dart:typed_data';

abstract class Repository {
  Future<bool> saveString(String key, String value);

  // Future<String> saveImage(String key, Uint8List image);

  // void saveObject(String key, Map<String, dynamic> object);

  Future<String> getString(String key);

  // Future<Uint8List> getImage(String key);

  // Future<Map<String, dynamic>> getObject(String key);

  // Future<void> removeString(String key);

  // Future<void> removeImage(String key);

  // Future<void> removeObject(String key);
}
