import 'package:flutter/material.dart';
import 'package:capstonesproject2024/models.dart';
import 'package:capstonesproject2024/services/firestore_service.dart';

class BrandManagementScreen extends StatefulWidget {
  final void Function(List<Brand>) onBrandsUpdated;

  const BrandManagementScreen({
    Key? key,
    required this.onBrandsUpdated, required String adminName, required String profileImagePath,
  }) : super(key: key);

  @override
  _BrandManagementScreenState createState() => _BrandManagementScreenState();
}

class _BrandManagementScreenState extends State<BrandManagementScreen> {
  final TextEditingController brandController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _isBrandTableVisible = false;
  bool _isEditing = false;
  late Brand _editingBrand;
  List<Brand> brands = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      final fetchedBrands = await _firestoreService.getBrands();
      setState(() {
        brands = fetchedBrands;
      });
      widget.onBrandsUpdated(brands); // Notify parent widget
    } catch (e) {
      print('Error fetching brands: $e');
    }
  }

  Future<void> addBrand() async {
    if (brandController.text.isEmpty || descriptionController.text.isEmpty) {
      print('Brand and Description fields cannot be empty');
      return;
    }

    final newBrand = Brand(
      id: DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      name: brandController.text,
      description: descriptionController.text,
    );

    try {
      await _firestoreService.addBrand(newBrand);
      setState(() {
        brands.add(newBrand);
        brandController.clear();
        descriptionController.clear();
      });
    } catch (e) {
      print('Error saving brand: $e');
    }
  }

  void deleteBrand(String id) async {
    try {
      await _firestoreService.deleteBrand(id);
      setState(() {
        brands.removeWhere((brand) => brand.id == id);
      });
    } catch (e) {
      print('Error deleting brand: $e');
    }
  }

  void startEditing(Brand brand) {
    setState(() {
      _isEditing = true;
      _editingBrand = brand;
      brandController.text = brand.name;
      descriptionController.text = brand.description;
    });
  }

  void cancelEditing() {
    setState(() {
      _isEditing = false;
      brandController.clear();
      descriptionController.clear();
    });
  }

  void saveEditing() async {
    if (_editingBrand.name == brandController.text &&
        _editingBrand.description == descriptionController.text) {
      setState(() {
        _isEditing = false;
      });
      return;
    }

    final updatedBrand = Brand(
      id: _editingBrand.id,
      name: brandController.text.trim(),
      description: descriptionController.text.trim(),
    );

    try {
      await _firestoreService.updateBrand(updatedBrand);
      await fetchBrands();
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      print('Error updating brand: $e');
    }
  }

  void _toggleBrandTableVisibility() {
    setState(() {
      _isBrandTableVisible = !_isBrandTableVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Brand Management',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildBrandForm(),
              const SizedBox(height: 16),
              _buildBrandTableToggle(),
              const SizedBox(height: 16),
              if (_isBrandTableVisible) _buildBrandTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandForm() {
    return Container(
      width: 480, // Set the width of the card here
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandInputRow(),
              const SizedBox(height: 16),
              _buildDescriptionInputRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandInputRow() {
    return Row(
      children: [
        Container(
          width: 200,
          child: TextField(
            controller: brandController,
            decoration: const InputDecoration(
              labelText: 'Brand Name',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.save, color: Colors.green),
          onPressed: addBrand,
        ),
      ],
    );
  }

  Widget _buildDescriptionInputRow() {
    return Row(
      children: [
        Container(
          width: 200,
          child: TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () {
            descriptionController.clear();
          },
        ),
      ],
    );
  }

  Widget _buildBrandTableToggle() {
    return Row(
      children: [
        const Text(
          'View Brands',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _toggleBrandTableVisibility,
          child: Icon(
            _isBrandTableVisible ? Icons.arrow_drop_down : Icons.arrow_drop_up,
          ),
        ),
      ],
    );
  }

  Widget _buildBrandTable() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20), // Padding inside the card
        child: Container(
          width: 440, // Set a fixed width for the card (adjust as needed)
          height: 300, // Set a fixed height for the card (adjust as needed)
          child: SingleChildScrollView( // Make the DataTable scrollable
            scrollDirection: Axis.horizontal,
            // Horizontal scrolling for the table
            child: SingleChildScrollView( // Vertical scrolling for the DataTable
              scrollDirection: Axis.vertical,
              child: DataTable(
                columnSpacing: 30,
                dataRowHeight: 50,
                headingRowColor: MaterialStateProperty.all(Colors.black),
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
                border: TableBorder.all(color: Colors.black, width: 3),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Brand Name')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: brands.map((brand) {
                  return DataRow(cells: [
                    DataCell(Text(brand.id)),
                    DataCell(Text(brand.name)),
                    DataCell(Text(brand.description)),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.green),
                          onPressed: () => startEditing(brand),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteBrand(brand.id),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
