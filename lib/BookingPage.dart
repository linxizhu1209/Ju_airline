import 'package:airline/pages/BookingDetailPage.dart';
import 'package:airline/services/booking_service.dart';
import 'package:flutter/material.dart';

import 'models/flight_order.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<FlightOrder> bookings = [];
  String selectedFilter = "예약일자순";

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    List<FlightOrder> fetchedBookings = await BookingService.fetchUserBookings();

    setState(() {
      bookings = fetchedBookings;
      _sortBookings();
    });
  }

  void _sortBookings() {
    setState(() {
      if(selectedFilter == "예약일자순"){
        bookings.sort((a,b) => b.bookingDate.compareTo(a.bookingDate));
      } else if(selectedFilter == "가격순") {
        bookings.sort((a,b) => b.totalPrice.compareTo(a.totalPrice));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("항공권 예약 조회")),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("총 ${bookings.length}건"),
                  DropdownButton(
                      value: selectedFilter,
                      items: ["예약일자순", "가격순"]
                            .map((filter) => DropdownMenuItem(value: filter, child: Text(filter)))
                            .toList(),
                      onChanged: (newValue){
                        setState(() {
                          selectedFilter = newValue!;
                          _sortBookings();
                        });
                      })
                ],
              ),
          ),

          Expanded(
              child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index){
                    final booking = bookings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          "${booking.departureAirport} → ${booking.arrivalAirport}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("여행 날짜: ${booking.departureTime}"),
                            Text("항공사: ${booking.airlineName}"),
                            Text("총 가격: ${booking.totalPrice} 원", style: const TextStyle(color: Colors.red)),
                            Text("예약 상태: ${booking.orderStatus}"),
                          ],
                        ),
                        onTap: () async {
                          final qrBytes = await BookingService.fetchQrCode(booking.tossOrderId);
                          if(qrBytes != null){
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookingDetailPage(
                                        booking: booking,
                                        qrBytes: qrBytes,
                                    ),
                                ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('QR코드를 가져오는 데 실패했습니다.')),
                            );
                          }
                        },
                      ),
                    );
                  }
                  )
          )
        ],
      ),
    );
  }
}
