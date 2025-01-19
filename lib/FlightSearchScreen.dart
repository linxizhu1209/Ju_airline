import 'package:airline/SeatSelectionScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {

  String tripType = 'Round-trip';
  String departureCity = '';
  String arrivalCity = '';
  DateTime? departureDate;
  DateTime? returnDate;
  int passengers = 1;

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
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trip Type'),
          Row(
            children: [
              Expanded(child: RadioListTile(
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
                Expanded(child: RadioListTile(
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

    Text('Arrival City:'),
    DropdownButton<String>(
    value: arrivalCity.isEmpty ? null : arrivalCity,
    hint: Text('Select Arrival City'),
    items: ['서울','부산','인천'].map((city){
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
        SizedBox(height: 16),

    Row(
    children: [
      Expanded(child: Column(
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
    child: Text(
    returnDate == null
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

void main() => runApp(MaterialApp(
  home: FlightSearchScreen(),
));
