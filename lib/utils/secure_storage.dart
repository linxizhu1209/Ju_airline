
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: "jwt_token", value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "jwt_token");
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: "jwt_token");
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: "user_info", value: jsonEncode(user));
  }

  Future<void> logoutUser() async {
    await _storage.delete(key: "user_info");
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    String? userData = await _storage.read(key: "user_info");
    if(userData != null){
      return jsonDecode(userData);
    }
    return null;
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: "user_info");
  }
}