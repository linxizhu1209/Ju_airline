
import 'dart:math';

import 'package:airline/login_service.dart';
import 'package:flutter/material.dart';

import '../services/admin_login_service.dart';

class AuthProvider with ChangeNotifier {
  final LoginService loginService;
  String? userEmail;
  String? userName;
  bool isLoggedIn = false;
  String? userRole;

  AuthProvider(this.loginService){
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    bool loggedIn = await loginService.isAuthenticated();
    print("로그인 $loggedIn");
    if(loggedIn){
      final userInfo = await loginService.getUserInfo();
      print("userInfo ${userInfo}");
      if(userInfo != null){
        userName = userInfo['username'];
        userEmail = userInfo['email'];
        userRole = userInfo['role'];
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
        userRole = userInfo['role'];
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

  Future<bool> adminLogin(String email, String password) async {
    bool success = await AdminLoginService().login(email,password);
    if(success) {
      await _checkLoginStatus();
      notifyListeners();
    }
    return success;
  }

  bool isAdmin() {
    return userRole == "ADMIN";
  }

}