import 'package:flutter/material.dart';
import 'package:pengelolaan_keuangan_masjid/constans/constans.dart';
import 'package:pengelolaan_keuangan_masjid/launcher.dart';
import 'package:pengelolaan_keuangan_masjid/pages/login.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Buku Keuangan Digital Masjid Al-Muhajirin',
    home: Launcher(),
    theme: ThemeData(primaryColor: Colors.white),
    routes: <String, WidgetBuilder>{
      SPLASH_SCREEN: (BuildContext context) => Launcher(),
      HOME_SCREEN: (BuildContext context) => Login(),
    },
  ));
}
