
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/flight_order.dart';

class BookingDetailPage extends StatelessWidget {

  final FlightOrder booking;
  final Uint8List qrBytes;

  const BookingDetailPage({super.key, required this.booking, required this.qrBytes});

  @override
  Widget build(BuildContext context) {
    final formattedDepartureTime = DateFormat('yyyy-MM-dd HH:mm').format(booking.departureTime);
    final formattedArrivalTime = DateFormat('yyyy-MM-dd HH:mm').format(booking.arrivalTime);

    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
        title: const Text("항공권 상세", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    qrBytes,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          booking.departureAirport,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.flight_takeoff, size:30),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          booking.arrivalAirport,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 30, thickness: 1.5),

                  _infoRow("항공사명", booking.airlineName),
                  _infoRow("좌석 번호", "3C"),
                  _infoRow("출발 시간", formattedDepartureTime),
                  _infoRow("도착 시간", formattedArrivalTime),
                  _infoRow("예약 상태", booking.orderStatus),
                  const SizedBox(height: 10),
                  const Divider(height: 30, thickness: 1.5),

                ],
              ),
          ),
        ),
      )
    );
  }
}
// 재사용 가능한 항목 위젯
Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
