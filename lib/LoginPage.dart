
import 'dart:math';

import 'package:airline/login_service.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginService loginService = LoginService();
  String? userEmail;
  String? userName;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await loginService.isAuthenticated();
    if(loggedIn) {
      final userInfo = await loginService.getUserInfo();
      if(userInfo != null){
          setState(() {
            userName = userInfo['username'];
            userEmail = userInfo['email'];
            isLoggedIn = true;
          });
        }
      }
    }

  /// google oauth2 로그인 처리
  Future<void> loginWithGoogle() async {
  bool success = await loginService.authenticateWithGoogle();
  if(success){
    final token = await loginService.getToken();
    print("token $token");
    if(token != null){
      final userInfo = await loginService.getUserInfo();
      print("userInfo $userInfo");
      if(userInfo != null) {
        print("userInfo $userInfo");
        setState(() {
          userName = userInfo['username'];
          userEmail = userInfo['email'];
          isLoggedIn = true;
        });
      }
    }
  }}

  Future<void> logout() async {
    await loginService.logout();
    setState(() {
      userName = null;
      userEmail = null;
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: Text("Google Login"),
          actions: [
            if(isLoggedIn)
              IconButton(
                  onPressed: logout,
                  icon: Icon(Icons.logout)
              )
          ],
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(isLoggedIn && userEmail != null)
              Column(
                children: [
                  Text("Welcome, $userName", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Email: $userEmail", style: TextStyle(fontSize: 16)),
                ],
              ),
            SizedBox(height: 20),
            if(!isLoggedIn)
            ElevatedButton(
              onPressed: loginWithGoogle,
              child: Text("Login with Google"),
            ),
          ],
        ),
      ),
    );
  }
}