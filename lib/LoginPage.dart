
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
      backgroundColor: Color(0xFFF4F0FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF8A56AC),
        title: Text("Login", style: TextStyle(color: Colors.white)),
        actions: [
          if(authProvider.isLoggedIn)
            IconButton(
                onPressed: authProvider.logout,
                icon: Icon(Icons.logout, color: Colors.white),
            )
        ],
    ),
      body: Center(
        child: authProvider.isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_circle, size: 80, color: Color(0xFF8A56AC)),
                  SizedBox(height: 10),
                  Text(
                      "Welcome, ${authProvider.userName}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  if(authProvider.userEmail != null)
                    Text("Email: ${authProvider.userEmail}", style: TextStyle(fontSize: 16)),
                ],
            )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "SNS 계정으로 로그인",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: authProvider.loginWithGoogle,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            'assets/images/google_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Google", style: TextStyle(color: Colors.black87))
                    ],
                  ),
                  SizedBox(width: 30),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: authProvider.loginWithKakao,
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.asset(
                            'assets/images/kakao_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Kakao", style: TextStyle(color:Colors.black87))
                    ],
                  )
                ],
              ),
              SizedBox(height: 40),
              Divider(height: 1, thickness: 1, indent: 40, endIndent: 40),
              SizedBox(height: 20),
              Text("관리자이신가요?", style: TextStyle(fontSize: 16)),
              SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8A56AC),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AdminLoginPage()),
                  );
                },
                icon: Icon(Icons.admin_panel_settings),
                label: Text("관리자 로그인"),
              ),
            ],
        ),
      ),
    );
  }
}