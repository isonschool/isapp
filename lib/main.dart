import 'package:flutter/material.dart';
import 'package:isapp/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences _prefs = await SharedPreferences.getInstance();

  runApp(IsonSchoolApp(_prefs));
}
