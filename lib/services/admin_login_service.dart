
import 'dart:convert';

import 'package:airline/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/Config.dart';

class AdminLoginService {
  final String baseUrl = "${Config.baseUrl}";

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login/admin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if(response.statusCode == 200){
        final responseData = jsonDecode(response.body);
        String token = responseData["token"];
        Map<String, dynamic> userInfo = responseData["user"];

        await SecureStorage().saveToken(token);
        await SecureStorage().saveUser(userInfo);
        return true;
      }
      return false;
    } catch (e) {
      print("관리자 로그인 오류: $e");
      return false;
    }
  }

}