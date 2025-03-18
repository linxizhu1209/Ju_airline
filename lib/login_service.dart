import 'dart:convert';

// import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final String clientId;
  final String backendUrl;
  late final GoogleSignIn _googleSignIn;

  LoginService()
      : clientId = dotenv.env['SERVER_CLIENT_ID'] ?? "",
        backendUrl = dotenv.env['BACKEND_URL'] ?? "" {
    _googleSignIn = GoogleSignIn(
      serverClientId: clientId,
      scopes: ['email', 'profile'],
    );
  }


  Future<String?> authenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if(googleUser == null){
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      print("idToken: $idToken");
      return idToken;
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
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

}