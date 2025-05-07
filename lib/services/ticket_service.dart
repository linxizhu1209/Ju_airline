
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/Config.dart';

class TicketService {
  Future<Map<String, dynamic>> fetchTicketInfo(String reservationId) async {
    final response = await http.get(
      Uri.parse("${Config.baseUrl}/ticket/detail?reservationId=$reservationId"),
      headers: {"Content-Type": "application/json"},
    );

    if(response.statusCode == 200){
      return jsonDecode(response.body);
    } else {
      throw Exception('탑승권 정보 가져오기 실패: ${response.body}');
    }
  }
}
