import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataProvider extends ChangeNotifier {
  DataProvider(
    this._token,
  );

  static final _prefs = SharedPreferences.getInstance();
  static const _prefsToken = "_prefsToken";

  String _token;
  String get token => _token;

  static Future<DataProvider> getInstance() async {
    return DataProvider((await getUserToken()));
  }

  static Future<String> getUserToken() async {
    return (await _prefs).getString(_prefsToken) ?? "";
  }

  void setUserToken(String value) async {
    _token = value;
    notifyListeners();
    (await _prefs).setString(_prefsToken, value);
  }
}
