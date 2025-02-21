import 'dart:convert';

import 'package:airline/SeatSelectionScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  List<String> cities = []; // 서버에서 가져온 도시 목록

  @override
  void initState(){
    super.initState();
    fetchAirports();
  }
  Future<void> fetchAirports() async {
    final response = await http.get(Uri.parse("http://10.0.2.2:8081/airport/list"));
    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}"); // ✅ 응답 데이터 확인
    if(response.statusCode == 200){
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
    if (picked != null){
      setState(() {
        if(isDeparture){
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
      appBar: AppBar(
        title: Text('Search Flights'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trip Type'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                  title: Text('Round-trip'),
                  value: 'Round-trip',
                  groupValue: tripType,
                  onChanged: (value) {
                    setState(() {
                      tripType = value.toString();
                      });
                      },
                    ),
                  ),
                Expanded(
                  child: RadioListTile(
                    title: Text('One-way'),
                    value: 'One-way',
                    groupValue: tripType,
                    onChanged: (value) {
                    setState(() {
                      tripType = value.toString();
                    });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Departure City:'),
                      DropdownButton<String>(
                          isExpanded: true,
                          value: departureCity,
                          hint: Text('Select Departure City'),
                          items: cities.map((city){
                            return DropdownMenuItem(
                                value: city,
                                child: Text(city),
                            );
                          }).toList(),
                        onChanged: (value) {
                          setState(() {
                            departureCity = value!;
                          });
                        },
                        ),
                     ],
                      ),
                  ),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Arrival City:'),
            DropdownButton<String>(
              isExpanded: true,
              value: arrivalCity,
              hint: Text('Select Arrival City'),
              items: cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  arrivalCity = value!;
                });
              },
            ),
          ],
        ))
      ],
    ),
    Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Departure Date:'),
                TextButton(onPressed: ()=> _selectDate(context,true),
                  child: Text(departureDate == null
                        ? 'Select Date'
                          : '${departureDate!.year}-${departureDate!.month}-${departureDate!.day}',
                  ),
                ),
              ],
              ),
          ),
                if(tripType == 'Round-trip')
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Return Date:'),
                      TextButton(
                        onPressed: ()=> _selectDate(context,false),
                        child: Text(returnDate == null
                      ? 'Select Date'
                      : '${returnDate!.year}-${returnDate!.month}-${returnDate!.day}',
                      ),
                    ),
                  ],
                ),
              ),
            ],
    ),

          SizedBox(height: 16),

          // Passenger Selection
          Text('Passengers:'),
          DropdownButton<int>(
            value: passengers,
            items: List.generate(10, (index) => index + 1).map((num) {
              return DropdownMenuItem(
                value: num,
                child: Text('$num'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                passengers = value!;
              });
            },
          ),

          SizedBox(height: 32),

          // Search Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Handle search logic here
                Navigator.push(context, MaterialPageRoute(builder: (context) => SeatSelectionScreen()),
                );
                },
              child: Text('Search Flights'),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
