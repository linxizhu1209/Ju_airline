

import 'package:flutter/material.dart';

class ReservationFailurePage extends StatelessWidget {
  final int flightOrderId;

  const ReservationFailurePage({super.key, required this.flightOrderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("예약 실패")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              "예약이 실패하였습니다",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
                onPressed: (){
                  Navigator.popUntil(context, (route) => route.isFirst);
                }, child: const Text("메인으로 돌아가기"),
            ),
          ],
        ),
      ),
    );
  }
}
