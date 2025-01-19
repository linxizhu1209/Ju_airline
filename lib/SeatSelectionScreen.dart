import 'package:flutter/material.dart';

class SeatSelectionScreen extends StatefulWidget {
  const SeatSelectionScreen({super.key});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {

  final List<List<bool>> seats = List.generate(
      5,
      (row) => List.generate(
        6,
          (col) => false,
      ),
  );

  void toggleSeat(int row, int col){
    setState(() {
      seats[row][col] = !seats[row][col];
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Seat'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                  child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                  ),
                      itemCount: seats.length * seats[0].length,
                      itemBuilder: (context, index){
                        final row = index ~/ 6;
                        final col = index % 6;

                        return GestureDetector(
                          onTap: () => toggleSeat(row,col),
                          child: Container(
                            decoration: BoxDecoration(
                              color: seats[row][col] ? Colors.grey : Colors.white,
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        );
                      },
                  ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                  onPressed: (){
                    List<String> selectedSeats = [];
                    for(int row = 0; row< seats.length; row++) {
                      for (int col = 0; col < seats[row].length; col++){
                        if(seats[row][col]){
                          selectedSeats.add('Row ${row + 1}, Seat ${col + 1}');
                        }
                      }
                    }
                    if(selectedSeats.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No seats selected!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected ${selectedSeats.join(', ')}')),
                      );
                    }
                  }, child: Text('Confirm Selection'),
              )
            ],
          ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: SeatSelectionScreen(),
));
