
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class LoginPage extends StatelessWidget {
  final FlutterAppAuth appAuth = FlutterAppAuth();

  Future<void> _authenticate() async {
    try {
      final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          '338194601174-ptqa8b5j4ealvvupkc5ffr8jnih6tb5s.apps.googleusercontent.com',
          'http://localhost:8081/login/oauth2/code/google',
          serviceConfiguration: AuthorizationServiceConfiguration(
              authorizationEndpoint: 'https://example.com/oauth2/authorize',
              tokenEndpoint:  'https://example.com/oauth2/token',
          ),
          scopes: ['openid','profile','email'],
        ),
      );

      if(result != null){
        print('Access Token: ${result.accessToken}');
        print('Refresh Token: ${result.refreshToken}');
        // todo 로그인 성공 처리
      }
    } catch (e) {
      print('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: _authenticate,
            child: Text('Login With OAuth2'),
      ),
      ),
    );
  }
}
