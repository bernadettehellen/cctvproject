// user preference data
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUID(String? x) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('uid', x ?? "");
}

Future<String> getUID() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('uid') ?? "";
}

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('uid') == "") {
    return false;
  }
  return true;
}

Future<void> logOut() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('uid', "");
}