
import 'dart:typed_data';

import 'package:airline/FlightSearchScreen.dart';
import 'package:airline/pages/BaseScreen.dart';
import 'package:airline/pages/HomePage.dart';
import 'package:flutter/material.dart';

class ReservationSuccessPage extends StatelessWidget {
  final String tossOrderId;
  final String departure;
  final String destination;
  // final String? stayPeriod;
  final double price;
  final Uint8List qrBytes;

  const ReservationSuccessPage({
        super.key,
        required this.tossOrderId,
        required this.departure,
        required this.destination,
        required this.price,
        required this.qrBytes,
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("예약 완료"),
          centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // const Spacer(),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "예약확정",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                // 예약 ID
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    tossOrderId,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                // 출발지 - 도착지
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "[$departure] - [$destination]",
                    style: const TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),

                // 여행 기간
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "여행기간 2025.08.21 ~ 2025.08.27",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 8),

                // 결제 가격
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${price.toStringAsFixed(0)}원",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 20),

              if(qrBytes.isNotEmpty) ...[
                const Text(
                  "항공권 QR 코드",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Image.memory(
                  qrBytes,
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ],

              const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BaseScreen(selectedIndex: 2)),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "메인으로 돌아가기",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
