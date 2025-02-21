
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReservationLookupScreen extends StatelessWidget {
  const ReservationLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservation Lookup'),
      ),
      body: Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '회원 예약 조회',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '회원 ID',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: '예약 번호',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: () {

          },
              child: Text('Submit'),
          ),
          SizedBox(height: 20),
          Text(
            '비회원 예약 조회',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: '예약자 성함',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: '예약 번호',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
              onPressed: (){

              },
              child: Text('Submit'),
          ),
        ],
      ),),
    );
  }
}
