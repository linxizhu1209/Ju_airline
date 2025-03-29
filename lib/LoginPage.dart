
import 'dart:math';

import 'package:airline/admin_login_page.dart';
import 'package:airline/login_service.dart';
import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
          title: Text("Google Login"),
          actions: [
            if(authProvider.isLoggedIn)
              IconButton(
                  onPressed: authProvider.logout,
                  icon: Icon(Icons.logout),
              )
          ],
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(authProvider.isLoggedIn && authProvider.userEmail != null)
              Column(
                children: [
                  Text("Welcome, ${authProvider.userName}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Email: ${authProvider.userEmail}", style: TextStyle(fontSize: 16)),
                ],
              ),
            SizedBox(height: 20),
            if(!authProvider.isLoggedIn)
            ElevatedButton(
              onPressed: authProvider.loginWithGoogle,
              child: Text("Login with Google"),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminLoginPage()),
                );
              },
              child: Text(
                "관리자로 로그인",
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            )
          ],
        ),
      ),
    );
  }
}