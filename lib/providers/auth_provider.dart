
import 'dart:convert';
import 'dart:math';

import 'package:airline/login_service.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import '../config/Config.dart';
import '../services/admin_login_service.dart';
import '../utils/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final LoginService loginService;
  final SecureStorage _secureStorage = SecureStorage();
  final String serverUrl = "${Config.baseUrl}/auth";
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


  Future<bool> loginWithKakao() async {
    try {
      // 카카오톡 설치 여부 확인
      bool installed = await isKakaoTalkInstalled();
      OAuthToken token;
      if (installed) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
        print("token $token");
      }

      final response = await http.post(
        Uri.parse('$serverUrl/login/kakao'),
        headers: {'Content-Type' : 'application/json'},
        body: jsonEncode({'accessToken': token.accessToken}),
      );

      if (response.statusCode == 200){
        print('✅ 카카오 로그인 성공');
        final responseData = jsonDecode(response.body);
        print("responseData $responseData");
        final String token = responseData["jwt"];
        final Map<String, dynamic> user = responseData["user"];

        print("✅ 로그인 성공: 유저 정보 저장");
        print("responseData[user] $user");
        print("token $token");
        await _secureStorage.saveToken(token);
        await _secureStorage.saveUser(user);
        userName = user['nickname'];
        userEmail = user['email'];
        userRole = user['role'];
        isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        print("서버 인증 실패 : ${response.body}");
        return false;
      }
    } catch (e) {
      print('❌ 카카오 로그인 실패: $e');
      return false;
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