import 'package:cadets/Helpers/file_helper.dart';
import '../Helpers/network_helper.dart';

class UserMappings {
  static Map<String, String> _data = {};
  static final Map<String, String> _reversedData = {};

  static String getName(String id) => _data[id] ?? "";
  static String getId(String name) => _reversedData[name] ?? "";

  static Set<String> getAllIds() => _data.keys.toSet();
  static Set<String> getAllNames() => _data.values.toSet();

  UserMappings() {
    loadFromStorage("mappings").then((jsonData) {
      if (jsonData == null) {
        syncOnline();
      } else {
        _data = Map<String, String>.from(jsonData);
      }

      for (MapEntry<String, String> element in _data.entries) {
        _reversedData.addAll({element.value: element.key});
      }
    });
  }

  static Future<void> syncOnline() async {
    Session session = Session.instance;
    session.checkLogin().then((value) async {
      if (!value) return;

      Map<dynamic, dynamic> mappings = await session.getUserMapping();

      mappings["DataList"].forEach((member) => _data.addAll(
            {member["MemberDisplay"].split(" - ")[1]: member["MemberDisplay"]},
          ));

      saveToStorage("mappings", _data);
    });
  }
}
