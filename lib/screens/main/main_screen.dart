// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:core';
import 'package:seguro/screens/main/history.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

import '../../globals/preferences.dart';
import '../authentication/login.dart';

import 'menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _onGButtonTapped(int index) {
    switch (index) {
      case 1: {
        Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const HistoryScreen())
        );
        break;
      }
      case 2: {
        _onLogOut();
        break;
      }
    }
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
        ),
      body: const Menu(),
      bottomNavigationBar: GNav(
        backgroundColor: Colors.blue,
        color: Colors.white,
        activeColor: Colors.white,
        tabs: const [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.history,
                  text: 'History',
                ),
                GButton(
                  icon: Icons.logout,
                  text: 'Log Out',
                ),
              ],
        selectedIndex: 0,
        onTabChange: _onGButtonTapped,
      ),
    );
    // return Scaffold(
    //     appBar: AppBar(
    //       title: const Text('SEGURO'),
    //       centerTitle: true,
    //       automaticallyImplyLeading: false,
    //       leading: IconButton(
    //           onPressed: _onLogOut,
    //           icon: const Icon(
    //             Icons.logout,
    //           )
    //       ),
    //       actions: [
    //         Padding(
    //           padding: const EdgeInsets.only(right: 20.0),
    //           child: GestureDetector(
    //             onTap: (){setState(() {
    //               _selectedIndex = 3;
    //             });},
    //             child: const Icon(
    //               Icons.history,
    //               size: 26,
    //             )
    //           ),
    //         )
    //       ],
    //     ),
    //     body: _screen.elementAt(_selectedIndex),
    //     bottomNavigationBar: GNav(
    //       gap: 8,
    //       backgroundColor: Colors.black,
    //       color: Colors.white,
    //       activeColor: Colors.white,
    //       tabs: const [
    //         GButton(
    //           icon: Icons.home,
    //           text: 'Home',
    //         ),
    //         GButton(
    //           icon: Icons.photo_library,
    //           text: 'My Picture',
    //         ),
    //         GButton(
    //           icon: Icons.remove_red_eye,
    //           text: 'CCTV',
    //         ),
    //         GButton(
    //           icon: Icons.chat,
    //           text: 'Chatbot',
    //         )
    //       ],
    //       selectedIndex: _selectedIndex,
    //       onTabChange: _onGButtonTapped,
    //     )
    // );
  }
}