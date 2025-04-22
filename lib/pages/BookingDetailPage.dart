
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/flight_order.dart';

class BookingDetailPage extends StatelessWidget {

  final FlightOrder booking;
  final Uint8List qrBytes;

  const BookingDetailPage({super.key, required this.booking, required this.qrBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
        title: const Text("항공권 상세"),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.memory(
                    qrBytes,
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    "${booking.departureAirport} -> ${booking.arrivalAirport}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 10),

                  Text(
                    "출발일: ${booking.departureTime}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "항공사: ${booking.airlineName}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  // if (booking.seatNumber != null)
                    Text(
                    "좌석: 3C",
                    style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height:20),
                ],
              ),
          ),
        ),
      )
    );
  }
}
