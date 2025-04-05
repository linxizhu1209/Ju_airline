import 'dart:convert';
import 'package:airline/config/Config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'models/ChatRoom.dart';

class ChatService {
  final String serverUrl = "${Config.baseUrl}/chat";

    StompClient? stompClient;
    Function(Map<String, dynamic>)? onMessageReceived;

    void connectStomp(String roomId, Function(Map<String, dynamic>) onMessage) {
      stompClient = StompClient(
      config: StompConfig(
      url: 'ws://10.0.2.2:8081/ws-chat',
      onConnect: (StompFrame frame){
        print("Stomp connected");

        print("🔎 구독 destination: /topic/chat/$roomId");
        stompClient!.subscribe(
          destination: "/topic/chat.room_$roomId",
          callback: (StompFrame frame) {
            if(frame.body != null){
              final message = jsonDecode(frame.body!);
              onMessage(message);
            }
          },
        );
      },
        onWebSocketError: (dynamic error) => print("❌ WebSocket Error: $error"),
        onStompError: (StompFrame frame) {
          print("❌ STOMP Error:");
          print("command: ${frame.command}");
          print("headers: ${frame.headers}");
          print("body: ${frame.body}");
        },
        onDisconnect: (frame) => print("🔌 STOMP Disconnected"),
        heartbeatIncoming: Duration(seconds: 5),
        heartbeatOutgoing: Duration(seconds: 5),
      ),
      );
      this.onMessageReceived = onMessage;
      stompClient!.activate();
  }

  void sendStompMessage(String roomId, String sender, String message){
      print("roomId $roomId");
      print("sender $sender");
      final msg = {
        "roomId": roomId,
        "sender": sender,
        "message": message,
        "timestamp": DateTime.now().toIso8601String()
      };
      stompClient?.send(destination: "/app/chat.sendMessage", body: jsonEncode(msg));
  }



    String generateRoomId(String sender){
      final now = DateTime.now();
      final datePart = DateFormat('yyMMdd').format(now);
      return "room_${datePart}_$sender";
    }


    Future<List<ChatRoom>> getChatRooms() async {
        final response = await http.get(
          Uri.parse("${Config.baseUrl}/chat/admin/chatrooms"),
        );
        print("response2 ${response.body}");
        if(response.statusCode == 200){
          List<dynamic> data = jsonDecode(response.body);
          return data.map((e)=> ChatRoom.fromJson(e)).toList();
        } else {
          print("채팅 목록 불러오기 실패: ${response.statusCode}");
          throw Exception("Failed to load chat rooms");
        }
    }

    Future<List<Map<String, dynamic>>> getMessagesForRoom(String roomId) async {
      final response = await http.get(Uri.parse("$serverUrl/messages/$roomId"));
      print("response $response");
      if(response.statusCode == 200){
        final List<dynamic> jsonList = jsonDecode(response.body);
        print("여기오나?");
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception("채팅 메시지를 불러오지 못했습니다.");
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

  Future<bool> checkRoomExists(String roomId) async {
      final response = await http.get(Uri.parse("$serverUrl/room/exists/$roomId"));
      print("roomId $roomId");
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return data["exists"] == true;
      } else {
        print("최초 생성되는 채팅방");
        return false;
      }
  }

  }