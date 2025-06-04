import 'dart:convert';
import 'package:airline/config/Config.dart';
import 'package:airline/utils/secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'models/ChatRoom.dart';

class ChatService {
  final String serverUrl = "${Config.baseUrl}/chat";
  final _secureStorage = SecureStorage();
    StompClient? stompClient;
    Function(Map<String, dynamic>)? onMessageReceived;

    Future<void> connectStomp(String roomId, Function(Map<String, dynamic>) onMessage) async {

      final token = await _secureStorage.getToken();

      stompClient = StompClient(
        config: StompConfig(
        url: 'ws://10.0.2.2:8081/ws-chat',
        beforeConnect: () async {
          final token = await _secureStorage.getToken();
          print("연결 전 토큰: $token");
        },
        stompConnectHeaders: {
          'token' : token ?? '',
        },
        webSocketConnectHeaders: {
          "token": token, // 중요!
        },
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

  Future<void> sendStompMessage(String roomId, String sender, String message) async {
      final token = await _secureStorage.getToken();

      print("roomId $roomId");
      print("sender $sender");
      final msg = {
        "roomId": roomId,
        "sender": sender,
        "message": message,
        "timestamp": DateTime.now().toIso8601String(),
        "unread": true,
        "token" : token
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
      final token = await _secureStorage.getToken();
      final response = await http.get(
          Uri.parse("$serverUrl/messages/$roomId"),
          headers: {
            'Authorization' : 'Bearer $token',
          });
      print("response $response");
      if(response.statusCode == 200){
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        throw Exception("채팅 메시지를 불러오지 못했습니다.");
      }
    }

    Future<int> getUnreadCount(String userName) async {
      // todo sender가 상대방이면서 내가 unread한 메시지의 개수를 가져와야함
      final token = await _secureStorage.getToken();
      final roomId = generateRoomId(userName);
      final uri = Uri.parse('${Config.baseUrl}/chat/unread/count?roomId=$roomId');

      final response = await http.get(
          uri,
          headers: {
            'Authorization' : 'Bearer $token',
            'Content-Type': 'applicaation/json',
          });

      if(response.statusCode == 200){
        final body = jsonDecode(response.body);
        return body['count'] ?? 0;
      } else {
        throw Exception("Failed to load unread count");
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