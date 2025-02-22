import 'package:airline/BaseScreen.dart';
import 'package:airline/FlightSearchScreen.dart';
import 'package:airline/ReservationLookupScreen.dart';
import 'package:flutter/material.dart';

import 'LoginPage.dart';
import 'NoticePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JuJu Airline App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BaseScreen(selectedIndex: 0),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ju's Airline App"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReservationLookupScreen()),
                );
              }, child: Text(
            '예약조회',
            style: TextStyle(color: Colors.black),
          ),
          ),
          TextButton(
              onPressed: (){
                  // todo 관리자와 채팅하기 페이지 예정
              },
              child: Text(
                '문의하기',
                style: TextStyle(color: Colors.black),
              ))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to the Ju's Airline!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => FlightSearchScreen()),
              );
            }, child: Text('Search Flights'),
            ),
          ],
        ),
      ),
    );
  }
}