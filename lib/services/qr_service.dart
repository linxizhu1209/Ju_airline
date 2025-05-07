import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/Config.dart';
import '../pages/TicketDetailPage.dart';

class QrService {
  static Future<void> decodeQrAndHandleResult(BuildContext context, String encryptedData) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/qr/decode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'encryptedData': encryptedData}),
      );

      if(response.statusCode == 200){
        final Map<String, dynamic> body = jsonDecode(response.body);
        final reservationId = body['reservationId'];

        if(reservationId != null){
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TicketDetailPage(reservationId: reservationId),
          ),
          );
        }
      } else if (response.statusCode == 400){
        final Map<String, dynamic> body = jsonDecode(response.body);
        final error = body['error'];

        if(error == 'expired_qr'){
          showErrorDialog(context, 'QR 코드가 만료되었습니다!\n새로고침 해주세요.');
        } else if (error == 'invalid_qr'){
          showErrorDialog(context, '잘못된 QR 코드입니다.');
        } else {
          showErrorDialog(context, '비정상적인 접근입니다');
        }
      } else {
        showErrorDialog(context, '알 수 없는 오류가 발생했습니다.');
      }
    } catch (e) {
      print('네트워크 오류: $e');
      showErrorDialog(context, '네트워크 오류가 발생했습니다.');
    }
  }

  static void showErrorDialog(BuildContext context, String message){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('에러', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
            ),
          ],
        ),
    );
  }

}