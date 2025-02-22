import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

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

  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    fetchAirports();
  }

  Future<void> fetchAirports() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8081/airport/list"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        cities = data.map((airport) => airport['city'].toString()).toSet().toList();
      });
    } else {
      throw Exception("Failed to load airports");
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
                      IconButton(icon: const Icon(Icons.support_agent,size:28),
                      onPressed: (){
                        //todo
                      },)
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
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'From'),
                                value: departureCity,
                                items: cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => departureCity = value!),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'To'),
                                value: arrivalCity,
                                items: cities.map((city) {
                                  return DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => arrivalCity = value!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: InputDecorator(
                                  decoration: const InputDecoration(labelText: 'Departure Date'),
                                  child: Text(
                                    departureDate == null
                                        ? 'Select Date'
                                        : DateFormat('yyyy-MM-dd').format(departureDate!),
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
                                    decoration: const InputDecoration(labelText: 'Return Date'),
                                    child: Text(
                                      returnDate == null
                                          ? 'Select Date'
                                          : DateFormat('yyyy-MM-dd').format(returnDate!),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Passengers'),
                          value: passengers,
                          items: List.generate(10, (index) => index + 1).map((num) {
                            return DropdownMenuItem(
                              value: num,
                              child: Text('$num'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => passengers = value!),
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
                            onPressed: () {},
                            child: const Text(
                              'Search Flights',
                              style: TextStyle(color: Colors.white, fontSize: 16),
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
}

