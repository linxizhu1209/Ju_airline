import 'dart:convert';
import 'package:airline/ChatService.dart';
import 'package:airline/FlightSchedulePage.dart';
import 'package:airline/models/ChatRoom.dart';
import 'package:airline/pages/QRScanPage.dart';
import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'ChatListPage.dart';
import 'ChatPage.dart';
import 'config/Config.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  String tripType = 'Round-trip';
  String? departureCity;
  String? arrivalCity;
  DateTime? departureDate;
  DateTime? returnDate;
  int passengers = 1;
  int _unreadCount = 0;
  List<Map<String, dynamic>> airports = [];
  List<String> cities = [];
  List<String> arrivalCities = [];

  @override
  void initState() {
    super.initState();
    fetchAirports();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAdmin = authProvider.isAdmin();
      final userName = authProvider.userName ?? "Unknown";
      
      final count = await ChatService().getUnreadCount(userName);
      setState(() {
        _unreadCount = count;
      });
    });
  }

  Future<void> fetchAirports() async {
    final response = await http.get(
        Uri.parse("${Config.baseUrl}/airport/list"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print("🔹 데이터: $data");
      setState(() {
        airports = data.map((airport) =>
        {
          'id': airport['airportId'],
          'city': airport['city']
        }).toList();
        cities =
            data.map((airport) => airport['city'].toString()).toSet().toList();
      });
      print("🔹 공항 데이터 로드 완료: $airports");
    } else {
      throw Exception("Failed to load airports");
    }
  }

  /// 출발지를 선택하면 도착지 목록을 가져오기
  Future<void> fetchArrivalCities(String departureCity) async {
    print("airports $airports");
    final departureAirport = airports.firstWhere((airport) =>
    airport['city'] == departureCity, orElse: () => {});

    if (departureAirport.isEmpty) {
      print("❌ 출발 공항을 찾을 수 없음: $departureCity");
      return;
    }


    if (departureAirport.isNotEmpty) {
      final String departureAirportId = departureAirport['id'];
      print("✅ 선택한 출발 공항 ID: $departureAirportId");

      final response = await http.get(Uri.parse(
          "${Config.baseUrl}/flight/available-destination?departureAirportId=$departureAirportId"));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("🔹 API 응답 데이터: $data");
        setState(() {
          arrivalCities = data.map((airport) => airport['city'].toString())
              .toSet()
              .toList();
        });
      } else {
        throw Exception("Fail");
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          departureDate = picked;
        } else {
          returnDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple.shade300, Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Flight Booking',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.support_agent, size: 28),
                            onPressed: () {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              print("userName ${authProvider.userName}");
                              print("userinfo ${authProvider.userRole}");
                              if(authProvider.isAdmin()){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=> ChatListPage()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                          chatRoom: ChatRoom(
                                              roomId: "",
                                              userName: authProvider.userName ?? 'Unknown',
                                              lastMessage: "",
                                              lastTimestamp: DateTime.now().toString(),
                                          ),
                                      ),
                                    ));
                              }
                            },
                          ),
                          if(_unreadCount > 0)
                            Positioned(
                                right: 4,
                                top: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_unreadCount',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                )),
                          const SizedBox(width: 8),
                          Builder(
                              builder: (context) {
                                final authProvider = Provider.of<AuthProvider>(context,listen:  false);
                                if(authProvider.isAdmin()){
                                  return IconButton(
                                      icon: const Icon(Icons.qr_code_scanner, size: 28),
                                      onPressed: (){
                                        Navigator.push(
                                            context, 
                                            MaterialPageRoute(builder: (context) => const QRScanPage()),
                                        );
                                      },
                                  );
                                } else {
                                  return Container();
                                }
                              })
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'From'),
                          value: departureCity,
                          hint: const Text("출발지"),
                          items: cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              departureCity = value;
                              arrivalCity = null;
                              arrivalCities.clear();
                            });
                            fetchArrivalCities(value!);
                          },
                        ),
                        const SizedBox(width: 10),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'To'),
                          value: arrivalCity,
                          items: arrivalCities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => arrivalCity = value),
                          disabledHint: const Text("출발지를 먼저 선택하세요"),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                      labelText: 'Departure Date'),
                                  child: Text(
                                    departureDate == null
                                        ? 'Select Date'
                                        : DateFormat('yyyy-MM-dd').format(
                                        departureDate!),
                                  ),
                                ),
                              ),
                            ),
                            if (tripType == 'Round-trip')
                              const SizedBox(width: 10),
                            if (tripType == 'Round-trip')
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                        labelText: 'Return Date'),
                                    child: Text(
                                      returnDate == null
                                          ? 'Select Date'
                                          : DateFormat('yyyy-MM-dd').format(
                                          returnDate!),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                              labelText: 'Passengers'),
                          value: passengers,
                          items: List.generate(10, (index) => index + 1).map((
                              num) {
                            return DropdownMenuItem(
                              value: num,
                              child: Text('$num'),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => passengers = value!),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: searchFlights,
                            child: const Text(
                              'Search Flights',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BaseScreen(selectedIndex: -1),
    );
  }

  void searchFlights() async {
    if (departureCity == null || arrivalCity == null) {
      print("❌ 출발지와 도착지를 선택하세요!");
      return;
    }
    final departureAirport = airports.firstWhere((airport) =>
    airport['city'] == departureCity, orElse: () => {});
    final arrivalAirport = airports.firstWhere((airport) =>
    airport['city'] == arrivalCity, orElse: () => {});

    if (departureAirport.isEmpty || arrivalAirport.isEmpty) {
      print("공항 정보를 찾을 수 없습니다!");
      return;
    }

    final String departureAirportId = departureAirport['id'];
    final String arrivalAirportId = arrivalAirport['id'];

    final response = await http.get(Uri.parse(
        "${Config.baseUrl}/flight/schedule?departureAirportId=$departureAirportId&arrivalAirportId=$arrivalAirportId"));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print("검색된 항공편: $data");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>
            FlightSchedulePage(schedules: data.cast<Map<String, dynamic>>()),
        ),
      );
    } else {
      print("항공편 검색 실패");
    }
  }
}




