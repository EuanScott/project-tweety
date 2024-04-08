import 'package:shared_preferences/shared_preferences.dart';

class TrivialStorage {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  TrivialStorage();

  // TODO: Can I get away with needing to make this a type `Future`?
  // setup() async {
  //   prefs = await SharedPreferences.getInstance();
  // }

  setInt(String key, int value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setInt(key, value);
  }

  getInt(String key) async {
    final SharedPreferences prefs = await _prefs;
    prefs.getInt(key);
  }
}
