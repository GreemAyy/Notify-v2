import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../store/store.dart';

void setUser(int id, String hash) async {
  var prefs = await SharedPreferences.getInstance();
  prefs.setInt('id', id);
  prefs.setString('hash', hash);
  store.unType.mapMultiSet({
    "id": id,
    "hash": hash
  });
  store.onType;
}
//Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
void cleanUser() async {
  var prefs = await SharedPreferences.getInstance();
  prefs.remove('id');
  prefs.remove('hash');
  store.unType.mapMultiSet({
    "id": null,
    "hash": null
  });
  store.onType;
}