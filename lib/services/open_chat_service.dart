import 'dart:convert';

import 'package:airline/utils/secure_storage.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import '../config/Config.dart';
import 'package:http/http.dart' as http;

class OpenChatService {
  final String serverUrl = "${Config.baseUrl}/open-chat";
  StompClient? stompClient;
  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, List<Map<String, dynamic>>>> fetchGroupedChatRooms() async {
    final response = await http.get(Uri.parse('$serverUrl/grouped'));
    if(response.statusCode == 200){
      final Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes));
      return jsonMap.map((destination, roomsJson){
        print("📦 destination: $destination");
        print("📦 roomsJson: $roomsJson");
        final List<Map<String, dynamic>> rooms = (roomsJson as List).map((e) {
          return {
            'id' : e['id'],
            'roomName': e['roomName'],
            'imageUrl': e['imageUrl'],
            'destination': e['destination'],
            'lastMessage': e['lastMessage'],
            'lastTimestamp': e['lastTimestamp'],
            'participantCount': e['participantCount'],
          };
        }).toList();

        return MapEntry(destination, rooms);
      });
    } else {
      throw Exception('오픈 채팅 데이터를 불러오는 데 실패했습니다.');
    }
  }

  Future<Map<String, dynamic>?> fetchParticipant({required String roomId, required String username}) async {
    final response = await http.get(Uri.parse('$serverUrl/$roomId/participant/$username'));
    if(response.statusCode == 200){
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else return null;
  }

  Future<List<Map<String, dynamic>>> fetchMessagesSince({
    required String roomId,
    required String since,
    required String username
  }) async {
    final response = await http.get(Uri.parse(
        "$serverUrl/$roomId/messages?since=$since&username=$username"
    ));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception("메시지 불러오기 실패");
    }
  }

  Future<void> connect({
    required String roomId,
    required String nickname,
    required void Function(Map<String, dynamic> message) onNewMessage,
    required void Function(String messageId, int updatedCount) onUnreadCountUpdated,
  }) async {
    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: "${Config.baseUrl}/ws-chat",
        onConnect: (StompFrame frame) {
          print("Stomp 연결됨 : $frame");

          stompClient?.subscribe(
            destination: '/topic/chat.room.$roomId',
            callback: (frame) async {
              if (frame.body != null) {
                final msg = jsonDecode(frame.body!);

                if (msg['type'] == 'TALK') {
                  onNewMessage(msg); // 메시지 UI에 추가
                  // 내가 보낸 메시지가 아니라면 → 읽음 처리
                  if (msg['sender'] != nickname) {
                    await markMessageAsRead(
                      roomId: roomId,
                      messageId: msg['id'],
                      username: nickname,
                    );

                    // 서버에서 unreadCount 가져오기
                    final count = await fetchUnreadCount(roomId, msg['id']);
                    onUnreadCountUpdated(msg['id'], count);
                  }
                }

                else if (msg['type'] == 'READ') {
                  final count = await fetchUnreadCount(roomId, msg['messageId']);
                  onUnreadCountUpdated(msg['messageId'], count);
                }
              }
            },
          );

          sendMessage(
            roomId: roomId,
            nickname: nickname,
            content: "$nickname님이 입장했습니다.",
            type: "ENTER",
          );
        },
        onWebSocketError: (dynamic error) => print('WebSocket 오류: $error'),
        onStompError: (frame) => print("STOMP 오류: ${frame.body}"),
        onDisconnect: (frame) => print("연결 종료: $frame"),
      ),
    );

    stompClient?.activate();
  }

    void sendMessage({
      required String roomId,
      required String nickname,
      required String content,
      required String type,
    }) async {
      final token = await _secureStorage.getToken();
      final msg = {
        "roomId": roomId,
        "sender": nickname,
        "content": content,
        "type": type,
        "token": token,
      };

    stompClient?.send(
      destination: '/app/open-chat.sendMessage',
      body: jsonEncode(msg),
    );
    }

  void disconnect(){
    stompClient?.deactivate();
  }

  Future<int> fetchUnreadCount(String roomId, String messageId) async {
    final token = await _secureStorage.getToken();
    final response = await http.get(
      Uri.parse("${Config.baseUrl}/open-chat/unread-count?roomId=$roomId&messageId=$messageId"),
      headers: {
        'Authorization' : 'Bearer $token',
      },
    );

    if(response.statusCode == 200){
      return int.tryParse(response.body) ?? 0;
    } else {
      print("unreadcount 로드 실패: ${response.statusCode}");
      return 0;
    }
  }
  
  Future<String?> fetchLastReadMessageId(String roomId, String username) async {
    final response = await http.get(
      Uri.parse('$serverUrl/$roomId/last-read?username=$username'),
    );
    if(response.statusCode == 200){
      return utf8.decode(response.bodyBytes);
    }
    return null;
  }

  Future<void> markMessageAsRead({
    required String roomId,
    required String messageId,
    required String username,
}) async {
    final response = await http.post(
      Uri.parse("$serverUrl/read"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'roomId':roomId,
        'messageId': messageId,
        'username': username,
      }),
    );

    if(response.statusCode != 200){
      print("읽음 처리 실패: ${response.statusCode}");
    }
  }

  void sendReadNotification({
    required String roomId,
    required String messageId,
    required String username,
}) {
    final msg = {
      'roomId': roomId,
      'id': messageId,
      'sender': username,
      'type': 'READ'
    };

    stompClient?.send(
      destination: '/app/open-chat.readMessage',
      body: jsonEncode(msg),
    );
  }

}