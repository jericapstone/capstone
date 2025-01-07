import 'package:flutter/material.dart';

class MTCL1Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MTCL 1'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0), // Increased padding for larger spacing
        child: Column(
          children: [
            // TextField for subject and time input (outside of the cards)
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Subject and Time (Start - End)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            SizedBox(height: 32), // Spacing between text field and cards
            // Row style with two larger cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLargeCardWithDays('Teacher Schedule'),  // First card with the title "Teacher Schedule"
                _buildLargeCardWithDays('Lab Assistant Schedule'),  // Second card with the title "Lab Assistant Schedule"
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Function to create a larger card with a table-like structure inside
  Widget _buildLargeCardWithDays(String title) {
    return Flexible(
      child: Card(
        elevation: 6, // Slightly higher elevation for a bigger effect
        child: Container(
          color: Colors.grey[200], // Optional: background color for the card
          padding: EdgeInsets.all(32), // Increased padding for more space inside the card
          height: 800, // Increased height for the card
          width: 1000,  // Increased width for the card
          child: Column(
            children: [
              // Title for the card
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Title color
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16), // Spacing between title and table
              // Header Row for the days of the week
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTableCell('Time'),
                  _buildTableCell('Monday'),
                  _buildTableCell('Tuesday'),
                  _buildTableCell('Wednesday'),
                  _buildTableCell('Thursday'),
                  _buildTableCell('Friday'),
                  _buildTableCell('Saturday'),
                ],
              ),
              // Empty Row just for visual structure
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                ],
              ),
              // Empty Row (you can add more as necessary)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                  _buildTableCell(''),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to create a table cell that adjusts to available space with a border
  Widget _buildTableCell(String text) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),  // Border around the cell
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
