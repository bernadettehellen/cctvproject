// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:core';
import 'package:aplikasi/screens/main/history.dart';
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
      const CCTV(
        channel: "Put stream URL here",
        // channel: IOWebSocketChannel.connect("ws://127.0.0.1:8000"), // change this IP and port to target IP and port
      ),
      const HistoryScreen()
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
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: (){setState(() {
                  _selectedIndex = 3;
                });},
                child: const Icon(
                  Icons.history,
                  size: 26,
                )
              ),
            )
          ],
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