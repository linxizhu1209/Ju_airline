import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminLoginPage extends StatefulWidget {

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}


class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("관리자 로그인"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "이메일"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "비밀번호"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  bool success = await authProvider.adminLogin(
                    emailController.text,
                    passwordController.text,
                  );
                  if(success){
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("로그인 실패")),
                    );
                  }
                },
                child: Text("로그인"),
            ),
          ],
        ),
      ),
    );
  }
}
