import 'dart:convert';
import 'dart:typed_data';
import 'package:airline/ReservationFailurePage.dart';
import 'package:airline/ReservationSuccessPage.dart';
import 'package:airline/utils/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/Config.dart';

class PaymentService {

  static final SecureStorage _secureStorage = SecureStorage();

  static Future<int?> createFlightOrder({
    required String tossOrderId,
    required int flightScheduleId,
    required int quantity,
    required double totalPrice,
}) async {
    final url = Uri.parse("${Config.baseUrl}/order/flight");

    final userInfo = await _secureStorage.getUserInfo();
    final String? userEmail = userInfo?['email'];

    if(userEmail == null){
      print("주문 실패! 로그인된 사용자를 찾을 수 없습니다!");
      return null;
    }

    final response = await http.post(
        url,
        headers: { "Content-Type": "application/json"},
        body: jsonEncode(
          {
            "tossOrderId" : tossOrderId,
            "flightScheduleId": flightScheduleId,
            "quantity": quantity,
            "totalPrice": totalPrice,
            "userEmail": userEmail,
          }
        ),
    );
    if(response.statusCode == 200){
      final responseData = jsonDecode(response.body);
      print("✅ 주문 생성 성공: ${responseData['flightOrderId']}");
      return responseData['flightOrderId'];
    } else {
      print("❌ 주문 생성 실패: ${response.body}");
      return null;
    }
  }

  static Future<void> sendPaymentConfirmation(BuildContext context, int orderId, String tossOrderId, double totalPrice, String departureAirport,String arrivalAirport) async {
    final url = Uri.parse("${Config.baseUrl}/order/confirm");

    final response = await http.post(
      url,
      headers: {"Content-Type" : "application/json"},
      body: jsonEncode({
        "flightOrderId": orderId,
        "status": "CONFIRMED",
      }),
    );
    print("response :${response}");

    // ✅ 서버 응답 상태 코드 확인
    print("📢 서버 응답 상태 코드: ${response.statusCode}");
    print("📢 서버 응답 바디: ${response.body}");


    if(response.statusCode == 200){
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String qrBase64 = data['qrCodeBase64'];
      final Uint8List qrBytes = base64Decode(qrBase64);
      print("✅ 결제 승인 완료: ${response.body}");
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>
              ReservationSuccessPage(
                tossOrderId: tossOrderId,
                departure: departureAirport,
                destination : arrivalAirport,
                price: totalPrice,
                qrBytes: qrBytes,
              ),
          ),
      );
    } else {
      print("❌ 결제 승인 실패: ${response.body}");
      Navigator.push(
        context,
          MaterialPageRoute(builder: (context)=>ReservationFailurePage(flightOrderId: orderId),
          ),
      );
    }
  }
}
