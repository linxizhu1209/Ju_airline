import 'dart:convert';

import '../config/Config.dart';
import 'package:http/http.dart' as http;

class OpenChatService {
  final String serverUrl = "${Config.baseUrl}/open-chat";

  Future<Map<String, List<Map<String, dynamic>>>> fetchGroupedChatRooms() async {
    final response = await http.get(Uri.parse('$serverUrl/grouped'));
    if(response.statusCode == 200){
      final Map<String, dynamic> jsonMap = json.decode(utf8.decode(response.bodyBytes));
      return jsonMap.map((destination, roomsJson){
        final List<Map<String, dynamic>> rooms = (roomsJson as List).map((e) {
          return {
            'id' : e['_id'],
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

}