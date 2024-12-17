import 'package:flutter/material.dart';

class InventoryType extends StatefulWidget {
  final Function(String?) onSelect; // Callback to notify parent

  const InventoryType({Key? key, required this.onSelect}) : super(key: key);

  @override
  _InventoryTypeState createState() => _InventoryTypeState();
}

class _InventoryTypeState extends State<InventoryType> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft, // Align to the top left
      child: SizedBox(
        width: 2000, // Set the desired width of the card
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Inventory Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 300, // Adjust the dropdown width
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Inventory Type',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(child: Text('Room'), value: 'Room'),
                      DropdownMenuItem(child: Text('Equipment'), value: 'Equipment'),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                        widget.onSelect(value); // Notify parent widget of selection
                      });

                      // Navigate to the corresponding dashboard based on selection
                      if (value == 'Equipment') {
                        Navigator.of(context).pushNamed('/equipment');
                      } else if (value == 'Room') {
                        Navigator.of(context).pushNamed('/inventory');
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
