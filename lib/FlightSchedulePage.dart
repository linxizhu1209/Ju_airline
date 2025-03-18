import 'package:airline/payment_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'PaymentPage.dart';
import 'PaymentWebView.dart';

class FlightSchedulePage extends StatefulWidget {
  final List<Map<String, dynamic>> schedules;

  const FlightSchedulePage({super.key, required this.schedules});

  @override
  State<FlightSchedulePage> createState() => _FlightSchedulePageState();
}

  class _FlightSchedulePageState extends State<FlightSchedulePage> with SingleTickerProviderStateMixin {

    List<Map<String, dynamic>> selectedFlights = [];
    late AnimationController _animationController;
    late Animation<Offset> _slideAnimation;

    @override
    void initState() {
      super.initState();

      // 애니메이션 컨트롤러 설정
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(microseconds: 300),
      );

      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    // 체크박스 선택 핸들러
    void _toggleSelection(Map<String, dynamic> schedule) {
      setState(() {
        if (selectedFlights.contains(schedule)) {
          selectedFlights.remove(schedule);
        } else {
          selectedFlights.add(schedule);
        }

        if (selectedFlights.isNotEmpty) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("항공편 검색결과"),
        ),
        body: Stack(
          children: [
            ListView.builder(itemCount: widget.schedules.length,
              itemBuilder: (context, index) {
                final schedule = widget.schedules[index];
                bool isSelected = selectedFlights.contains(schedule);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleSelection(schedule),
                                  ),
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        schedule['airlineLogo']),
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    schedule['airlineName'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "\$${schedule['price']}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          if(schedule['direction'] == '출발') ...[
                            const Text(
                              "Onward",
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            _buildFlightInfo(
                              schedule['departureTime'],
                              schedule['arrivalTime'],
                              schedule['departureAirport'],
                              schedule['arrivalAirport'],
                              calculateDuration(schedule['departureTime'],
                                  schedule['arrivalTime']),
                            ),
                          ],
                          if(schedule['direction'] == '복귀') ...[
                            const Divider(),
                            const Text(
                              "Return",
                              style: TextStyle(fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            _buildFlightInfo(
                              schedule['departureTime'],
                              schedule['arrivalTime'],
                              schedule['arrivalAirport'],
                              schedule['departureAirport'],
                              calculateDuration(schedule['departureTime'],
                                  schedule['arrivalTime']),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: selectedFlights.isEmpty
                        ? null
                        : () async {
                      print("📌 선택된 항공편 리스트: $selectedFlights"); // ✅ 리
                      print("📌 첫 번째 항공편: ${selectedFlights.first}");
                      double totalAmount = selectedFlights.fold(
                        0, (sum, flight) => sum + (flight['price'] as double));
                      String tossOrderId = "order_${DateTime.now().millisecondsSinceEpoch}";
                      int? flightOrderId = await PaymentService.createFlightOrder(
                          tossOrderId: tossOrderId,
                          flightScheduleId: selectedFlights.first['scheduleId'],
                          quantity: selectedFlights.length,
                          totalPrice: totalAmount,
                      );

                      if(flightOrderId != null) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              PaymentPage(
                                  totalAmount: totalAmount,
                                  orderId: tossOrderId),
                          ),
                        );
                        if (result != null && result['status'] == "success") {
                          print("결제 성공 ! 주문 id : ${result['orderId']}");

                          String departureAirport = selectedFlights.first['departureAirport'];
                          String arrivalAirport = selectedFlights.first['arrivalAirport'];

                          await PaymentService.sendPaymentConfirmation(
                            context,
                            flightOrderId,
                            tossOrderId,
                            totalAmount,
                            departureAirport,
                            arrivalAirport,
                          );
                        } else {
                          print("결제 실패!");
                        }
                      }
                    },
                    child: Text(
                      "구매하기 (${selectedFlights.length}개 선택됨)",
                      style: const TextStyle(
                          color: Colors.purple, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildFlightInfo(String departureTime, String arrivalTime,
        String departureAirport, String arrivalAirport,
        String duration) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                departureTime,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                  departureAirport, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.flight_takeoff, color: Colors.green),
              Text(duration, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                arrivalTime,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(arrivalAirport, style: const TextStyle(color: Colors.grey)),
            ],
          )
        ],
      );
    }

    String calculateDuration(String departureTime, String arrivalTime) {
      // ✅ "HH:mm:ss" 형식을 DateTime 객체로 변환
      DateFormat format = DateFormat("HH:mm:ss");
      DateTime dep = format.parse(departureTime);
      DateTime arr = format.parse(arrivalTime);

      // ✅ 소요시간 계산
      Duration duration = arr.difference(dep);
      int hours = duration.inHours;
      int minutes = duration.inMinutes % 60;

      return "$hours hr $minutes min"; // ✅ "2 hr 30 min" 형태로 반환
    }
  }


