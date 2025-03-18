import 'package:airline/FlightSearchScreen.dart';
import 'package:airline/LoginPage.dart';
import 'package:airline/NoticePage.dart';
import 'package:airline/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatefulWidget {

  final int selectedIndex;

  BaseScreen({required this.selectedIndex});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final List<Widget> _screens = [
    FlightSearchScreen(),
    LoginPage(),
    NoticePage(),
  ];

  void _onItemTapped(int index){
    if(index != widget.selectedIndex) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BaseScreen(selectedIndex: index),
          ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[widget.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: widget.selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.flight_takeoff),
                label: '항공 검색',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.login),
                label: '로그인',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: '공지사항',
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
      ),
    );
  }
}
