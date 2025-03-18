import 'dart:convert';
import 'package:airline/ReservationFailurePage.dart';
import 'package:airline/ReservationSuccessPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config/Config.dart';

class PaymentService {

  static Future<int?> createFlightOrder({
    required String tossOrderId,
    required int flightScheduleId,
    required int quantity,
    required double totalPrice,
}) async {
    final url = Uri.parse("${Config.baseUrl}/order/flight");
    final response = await http.post(
        url,
        headers: { "Content-Type": "application/json"},
        body: jsonEncode(
          {
            "tossOrderId" : tossOrderId,
            "flightScheduleId": flightScheduleId,
            "quantity": quantity,
            "totalPrice": totalPrice,
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
      print("✅ 결제 승인 완료: ${response.body}");
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=>
              ReservationSuccessPage(
                tossOrderId: tossOrderId,
                departure: departureAirport,
                destination : arrivalAirport,
                price: totalPrice,
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
