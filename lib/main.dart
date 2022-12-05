import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'screens/authentication/login.dart';
import 'screens/main/main_screen.dart';

import 'globals/preferences.dart';
import 'globals/database.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  cameras = await availableCameras();
  dbn.database = openDatabase(
      join(await getDatabasesPath(), 'notification_database.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE notification(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, message TEXT, type INTEGER, date INTEGER)'
        );
      },
      version: 2
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]
  ).then((_) =>
    runApp(const MyApp())
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    isLoggedIn().then((value) {
      setState(() {
        _isLoggedIn = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: (_isLoggedIn == false) ?
        const SignInScreen() :
        const HomeScreen(),
    );
  }
}
