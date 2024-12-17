import 'package:flutter/material.dart';

class InventoryDropdown extends StatefulWidget {
  final Function(String?) onSelect; // Callback for when a value is selected
  final Function(String) onItemSelected; // Callback for handling selected item actions

  const InventoryDropdown({
    Key? key,
    required this.onSelect,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _InventoryDropdownState createState() => _InventoryDropdownState();
}

class _InventoryDropdownState extends State<InventoryDropdown> {
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 400,
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
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Inventory Type',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedType,
                  items: const [
                    DropdownMenuItem(child: Text('Room'), value: 'Room'),
                    DropdownMenuItem(child: Text('User'), value: 'User'),
                    DropdownMenuItem(child: Text('Equipment'), value: 'Equipment'),
                    DropdownMenuItem(
                        child: Text('Borrowing'), value: 'Borrowing'),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                      widget.onSelect(value); // Trigger the onSelect callback
                      if (value != null) {
                        widget.onItemSelected(value); // Trigger onItemSelected
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
