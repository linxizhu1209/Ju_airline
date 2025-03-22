import 'dart:convert';
import 'package:airline/config/Config.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final String serverUrl = "${Config.baseUrl}/chat";
    // final String serverUrl = "http://10.0.2.2:8081/chat";

    Future<String> sendRequest(String requestType) async {
      try {
        final response = await http.post(
          Uri.parse(serverUrl),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"requestType": requestType}),
        );

        if(response.statusCode == 200){
          final responseData = jsonDecode(response.body);
          return responseData["message"] ?? "서버에서 응답이 없습니다.";
        } else {
          return "서버 응답 오류 (${response.statusCode})";
        }
      } catch (e) {
        return "네트워크 오류: ${e.toString()}";
      }
    }
  }