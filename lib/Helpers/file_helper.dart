import 'package:json_store/json_store.dart';

Future<Map<String, dynamic>?> loadFromStorage(String key) async {
  final store = JsonStore();
  final rolls = await store.getItem(key);
  return rolls;
}

Future<void> saveToStorage(String key, Map<String, dynamic> data) async {
  final store = JsonStore();
  await store.setItem(key, data);
}
