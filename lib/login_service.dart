import 'dart:convert';

import 'package:airline/utils/secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final String clientId;
  final String backendUrl;
  late final GoogleSignIn _googleSignIn;
  final SecureStorage _secureStorage = SecureStorage();

  LoginService()
      : clientId = dotenv.env['SERVER_CLIENT_ID'] ?? "",
        backendUrl = dotenv.env['BACKEND_URL'] ?? "" {
    _googleSignIn = GoogleSignIn(
      serverClientId: clientId,
      scopes: ['email', 'profile'],
    );
  }


  Future<bool> authenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser == null) return false;
      print("유저가져오기");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if(idToken == null) return false;
      print("유저토큰가져오기");
      // 서버로 로그인 요청하여 jwt 받기
      final bool loginSuccess = await _sendIdTokenToServer(idToken);
      print("??여긴?");
      return loginSuccess;
    } catch (error) {
      print("Google Sign-In Error: $error");
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchUserInfo(String idToken) async {
    final response = await http.get(
      Uri.parse("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=$idToken"),
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<bool> _sendIdTokenToServer(String idToken) async {
    final response = await http.post(
      Uri.parse("$backendUrl/auth/login"),
      body: jsonEncode({"idToken": idToken}),
      headers: {"Content-Type": "application/json"},
    );

    if(response.statusCode == 200){
      final responseData = jsonDecode(response.body);
      final String token = responseData["token"];
      final Map<String, dynamic> user = responseData["user"];

      print("✅ 로그인 성공: 유저 정보 저장");
      print("responseData[user] $user");;

      await _secureStorage.saveToken(token);
      await _secureStorage.saveUser(user);
      return true;
    }
    return false;
  }

  Future<String?> getToken() async {
    return await _secureStorage.getToken();
  }

  Future<void> logout() async {
    await _secureStorage.deleteToken();
    await _secureStorage.logoutUser();
    await _googleSignIn.signOut();
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    return await _secureStorage.getUserInfo();
  }

}