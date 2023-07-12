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
    loadJsonData("mapper1").then((jsonData) {
      if (jsonData == Null) {
        Session session = Session();
        session.getCookies().then(
              (value) => session.login().then(
                    (value) => session.getUserMapping().then(
                      (value) {
                        value["DataList"].forEach(
                          (member) {
                            print(member);
                            _data.addAll(
                              {
                                member["MemberDisplay"].split(" - ")[1]:
                                    member["MemberDisplay"]
                              },
                            );
                            writeJsonData(_data, "mapper1");

                            for (MapEntry<String, String> element
                                in _data.entries) {
                              _reversedData
                                  .addAll({element.value: element.key});
                            }
                          },
                        );
                      },
                    ),
                  ),
            );
      } else {
        _data = Map<String, String>.from(jsonData);
        for (MapEntry<String, String> element in _data.entries) {
          _reversedData.addAll({element.value: element.key});
        }
        print(_data);
      }
    });
  }
}
