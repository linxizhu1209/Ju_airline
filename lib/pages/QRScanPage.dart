import 'dart:convert';

import 'package:airline/services/qr_service.dart';
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

      await QrService.decodeQrAndHandleResult(context, scannedCode!);

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
