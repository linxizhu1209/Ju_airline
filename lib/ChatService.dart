import 'dart:convert';
import 'package:airline/config/Config.dart';
import 'package:http/http.dart' as http;

import 'models/ChatRoom.dart';

class ChatService {
  final String serverUrl = "${Config.baseUrl}/chat";

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

    Future<void> sendChatMessage(String sender, String message) async {
      try {
        final response = await http.post(
          Uri.parse("$serverUrl/send"),
          headers: {"Content-Type" : "application/json"},
          body: jsonEncode({
            "sender": sender,
            "message": message,
            "timestamp": DateTime.now().toString()
          }),
        );
        if(response.statusCode == 200){
          print("메시지 전송 성공: ${response.body}");
        } else {
          print("메시지 전송 실패: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        print("네트워크 오류: $e");
      }
    }

    Future<List<ChatRoom>> getChatRooms() async {
        final response = await http.get(
          Uri.parse("${Config.baseUrl}/chat/admin/chatrooms"),
        );
        if(response.statusCode == 200){
          List<dynamic> data = jsonDecode(response.body);
          return data.map((e)=> ChatRoom.fromJson(e)).toList();
        } else {
          print("채팅 목록 불러오기 실패: ${response.statusCode}");
          throw Exception("Failed to load chat rooms");
        }
    }

    static Stream<int> getUnreadChatCountStream() async* {
      while(true){
        final response = await http.get(Uri.parse("${Config.baseUrl}/unreadCount"));
        if(response.statusCode == 200){
          yield int.parse(response.body);
        } else {
          yield 0;
        }
        await Future.delayed(Duration(seconds: 2));
      }
    }

  }