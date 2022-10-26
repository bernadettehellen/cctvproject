// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:core';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../globals/preferences.dart';
import '../authentication/login.dart';

import 'cctv.dart';
import 'input_photo.dart';
import 'list_photo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.initialIndex, this.imageFromCamera}) : super(key: key);
  final int initialIndex;
  final String? imageFromCamera;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;
  late var _screen = <Widget>[];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screen = <Widget>[
      InputPhoto(imageFromCamera: (widget.imageFromCamera != null) ? widget.imageFromCamera : null),
      const ListPhoto(),
      const CCTV(),
    ];
  }

  void _onGButtonTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onLogOut() {
    logOut().then((value) => {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const SignInScreen())
      )
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SEGURO'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: IconButton(
              onPressed: _onLogOut,
              icon: const Icon(
                Icons.logout,
              )
          )
        ),
        body: _screen.elementAt(_selectedIndex),
        bottomNavigationBar: GNav(
          gap: 8,
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.photo_library,
              text: 'My Picture',
            ),
            GButton(
              icon: Icons.remove_red_eye,
              text: 'CCTV',
            )
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onGButtonTapped,
        )
    );
  }
}