import 'package:capstonesproject2024/admin/Inventoryroom/roomdashboard.dart';
import 'package:flutter/material.dart';
 // Correct import for InventoryDashboard
import 'package:capstonesproject2024/admin/Inventory_equipment/equipment_dashboard.dart';
import 'package:capstonesproject2024/admin/usermanagement/admin_dashboard_screen.dart';
import 'package:capstonesproject2024/Miscellaneous/miscellaneous.dart';
import 'package:capstonesproject2024/admin/Transfer/transfer.dart';
import 'package:capstonesproject2024/models.dart';
import 'login_screen.dart';

// Define all routes here
Map<String, WidgetBuilder> appRoutes = {
  '/inventory': (context) => RoomDashboard(
    profileImagePath: 'assets/ccswarriors.png',
    adminName: 'Admin Name', brandList: const [],
    onEquipmentAdded: () {  },
    equipmentTypes: [],
    roomList: [],
    roomTypes: [],
      onRoomAdded: () {  }, selectedRoomCode: '',
  ),
  '/login': (context) => LoginPage(),
  '/admin_dashboard': (context) => AdminDashboardScreen(
    profileImagePath: 'assets/ccswarriors.png',
    adminName: 'Admin Name',
  ),
  '/user-management': (context) => AdminDashboardScreen(
    profileImagePath: 'assets/ccswarriors.png',
    adminName: 'Admin Name',
  ),
  '/equipment': (context) => EquipmentDashboard(
    profileImagePath: 'assets/ccswarriors.png',
    adminName: 'Admin Name',
    brandList: const [],
    onEquipmentAdded: () {},
    equipmentTypes: [], roomList: [], onRoomAdded: () {  }, roomTypes: [],
  ),
  '/miscellaneous': (context) => MiscellaneousScreen(
    adminName: 'Admin Name',
    profileImagePath: 'assets/ccswarriors.png',
    onBrandsUpdated: (List<Brand> updateBrands) {},
    onEquipmentTypeUpdated: (List<EquipmentType> p1) {},
    onTypesUpdated: (List<Type> p1) {},
    onTypeUpdated: (List<Type> p1) {},
  ),
  '/transfer': (context) => TransferEquipmentScreen(
    adminName: 'Admin Name',
    profileImagePath: 'assets/ccswarriors.png',
    onBrandsUpdated: (List<Brand> p1) {},
    onScheduleAdded: (String schedule) {},
  ),
};

// Your MaterialApp widget should use appRoutes for the routes
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capstones Project 2024',
      initialRoute: '/admin_dashboard', // Set initial route to /admin_dashboard
      routes: appRoutes, // Use appRoutes for route definitions
    );
  }
}
