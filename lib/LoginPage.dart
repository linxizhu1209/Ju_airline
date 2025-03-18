
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

  /// google oauth2 로그인 처리
  Future<void> loginWithGoogle() async {
  final idToken = await loginService.authenticateWithGoogle();
  if(idToken != null){
    final userInfo = await loginService.fetchUserInfo(idToken);
    if(userInfo != null){
      print("userInfo $userInfo");
      setState(() {
        userName = userInfo['name'];
        userEmail = userInfo['email'];
      });
    }
  }}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Google OAuth2 Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(userEmail != null)
              Column(
                children: [
                  Text("Welcome, $userName"),
                  Text("Email: $userEmail"),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: loginWithGoogle,
                child: Text("Login with Google"),
            ),
          ],
        ),
      ),
    );
  }
}