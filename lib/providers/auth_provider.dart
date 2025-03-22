
import 'dart:math';

import 'package:airline/login_service.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final LoginService loginService;
  String? userEmail;
  String? userName;
  bool isLoggedIn = false;

  AuthProvider(this.loginService){
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await loginService.isAuthenticated();
    if(loggedIn){
      final userInfo = await loginService.getUserInfo();
      if(userInfo != null){
        userName = userInfo['username'];
        userEmail = userInfo['email'];
        isLoggedIn = true;
        notifyListeners();
      }
    }
  }
  Future<void> loginWithGoogle() async {
    bool success = await loginService.authenticateWithGoogle();
    if(success) {
      final userInfo = await loginService.getUserInfo();
      if(userInfo != null){
        userName = userInfo['username'];
        userEmail = userInfo['email'];
        isLoggedIn = true;
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await loginService.logout();
    userName = null;
    userEmail = null;
    isLoggedIn = false;
    notifyListeners();
  }
}