import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<dynamic> loadJsonData(String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename.json';

  // Check if the file exists
  final file = File(filePath);
  final fileExists = await file.exists();

  if (fileExists) {
    String data = await file.readAsString();
    final jsonResult = jsonDecode(data);
    return jsonResult;
  }

  return Null;
}

Future<void> writeJsonData(Map<String, dynamic> data, String filename) async {
  final jsonData = json.encode(data);

  // Get the documents directory path
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename.json';

  // Write the JSON data to the file
  final file = File(filePath);
  await file.writeAsString(jsonData);
}
