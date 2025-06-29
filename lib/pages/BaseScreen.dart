import 'package:airline/ChatListPage.dart';
import 'package:airline/ChatPage.dart';
import 'package:airline/FlightSearchScreen.dart';
import 'package:airline/LoginPage.dart';
import 'package:airline/NoticePage.dart';
import 'package:airline/main.dart';
import 'package:airline/pages/BookingDetailPage.dart';
import 'package:airline/pages/HomePage.dart';
import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../BookingPage.dart';
import '../models/ChatRoom.dart';

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
    HomePage(),
    BookingPage(),
    Placeholder(), // 예비 자리
  ];

  void _onItemTapped(int index) {
    if (index == 4) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAdmin()) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatListPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChatPage(
                  chatRoom: ChatRoom(
                    roomId: "",
                    userName: authProvider.userName ?? 'Unknown',
                    lastMessage: "",
                    lastTimestamp: DateTime.now().toString(),
                  ),
                ),
          ),
        );
      }
    } else if (index != widget.selectedIndex) {
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
                icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(
                icon: Icon(	Icons.event_note),
                label: '예약현황',
            ),
            BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Icon(Icons.support_agent),
                    ],
                  ),
                label: '문의하기')
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
      ),
    );
  }
}
