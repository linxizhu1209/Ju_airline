import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../config/Config.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller){
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      _isProcessing = true;

      final scannedCode = scanData.code;
      print("스캔된 qr 데이터: $scannedCode");

      try {
        final response = await http.post(
          Uri.parse("${Config.baseUrl}/api/qr/decode"),
          headers: {"Content-Type" : "application/json"},
          body : jsonEncode({
            "encryptedData": scannedCode,
          })
        );

        if(response.statusCode == 200){
          final responseData = jsonDecode(response.body);
          final reservationId = responseData['reservationId'];
          print("복호화 성공! 예약번호: $reservationId");

          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('예약 확인'),
                content: Text('예약번호: $reservationId'),
                actions: [
                  TextButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      child: const Text('확인'),
                  ),
                ],
              ),
          );
        } else {
          print("복호화 실패 : ${response.body}");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('qr 복호화 실패')),
          );
        }
      } catch (e) {
        print("네트워크 오류 : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('네트워크 오류')),
        );
      }

      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title : const Text('QR 코드 스캔'),
        backgroundColor: Colors.purple,
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      )
    );
  }
}
