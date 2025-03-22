import 'dart:convert';

import 'package:airline/utils/secure_storage.dart';
import 'package:http/http.dart' as http;

import '../config/Config.dart';
import '../models/flight_order.dart';

class BookingService {
  static final SecureStorage _secureStorage = SecureStorage();

  static Future<List<FlightOrder>> fetchUserBookings() async {
    final userInfo = await _secureStorage.getUserInfo();
    final String? userEmail = userInfo?['email'];
    print("userEmail $userEmail");
    if (userEmail == null) {
      print("유저 이메일을 찾을 수 없습니다");
      return [];
    }
    print("여기");
    final url = Uri.parse("${Config.baseUrl}/order/list?userEmail=$userEmail");
    final response = await http.get(
        url, headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      print("✅ 응답 바디: ${response.body}");
      List<dynamic> jsonResponse = jsonDecode(response.body);
      List<FlightOrder> flightOrders = jsonResponse.map((data) => FlightOrder.fromJson(data)).toList();
      return flightOrders;
    } else {
      print("❌ 예약 내역 불러오기 실패: ${response.body}");
      return [];
    }
  }
}