import 'package:capstonesproject2024/Miscellaneous/BorrowingManagement/BorrowedEquipment.dart';
import 'package:capstonesproject2024/admin/Borrowing_Transaction/BorrowingTransactionScreen.dart';
import 'package:flutter/material.dart';
import 'package:capstonesproject2024/admin/Transfer/transfer.dart'; // Import your Transfer screen
import 'package:capstonesproject2024/admin/usermanagement/admin_dashboard_screen.dart';
import 'package:capstonesproject2024/admin/Inventoryroom/inventorydashboard.dart';
import 'package:capstonesproject2024/admin/inventory_equipment/equipment_dashboard.dart';
import 'package:capstonesproject2024/Miscellaneous/miscellaneous.dart' as misc;
import 'package:capstonesproject2024/admin/Schedule/Schedule.dart';
import 'package:capstonesproject2024/models.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';


// Firebase configuration
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBNQ6_wYFtfTMu-uEHEhZF_leFlyOnxZM",
  authDomain: "capstones2024.firebaseapp.com",
  projectId: "capstones2024",
  storageBucket: "capstones2024.appspot.com",
  messagingSenderId: "54753276247",
  appId: "1:54753276247:web:42a56523231cb1a0edce12",
  measurementId: "G-NDT9BNEXGG",
);

const String profileImagePath = 'assets/ccswarriors.png';
const String adminName = 'Admin Name';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: firebaseConfig);
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var selectedScheduleCode = ''; // Initialize or get this value appropriately
    var onScheduleAdded = (String scheduleCode) {
      print("Schedule added: $scheduleCode");
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Capstone Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/': (context) => AdminDashboardScreen(
          profileImagePath: profileImagePath,
          adminName: adminName,
        ),
        '/user-management': (context) => AdminDashboardScreen(
          profileImagePath: profileImagePath,
          adminName: adminName,
        ),
        '/inventory': (context) => InventoryDashboard(
            profileImagePath: profileImagePath,
            adminName: adminName
        ),
        '/equipment': (context) => EquipmentDashboard(
          profileImagePath: profileImagePath,
          adminName: adminName,
          brandList: const [],
          onEquipmentAdded: () {}, equipmentTypes: [],
        ),
        '/miscellaneous': (context) => misc.MiscellaneousScreen(
          profileImagePath: profileImagePath,
          adminName: adminName,
          onBrandsUpdated: (List<Brand> p1) {  },
          onEquipmentTypeUpdated: (List<EquipmentType> p1) {  },
          onTypesUpdated: (List<Type> p1) {  }, onTypeUpdated: (List<Type> p1) {  },
        ),
        '/login': (context) => LoginPage(),
        '/borrowing': (context) => BorrowingTransactionScreen(
          profileImagePath: profileImagePath,
          adminName: adminName,
          onTransactionsUpdated: (transactions) {},
        ),
        '/transfer': (context) => TransferEquipmentScreen(
          selectedScheduleCode: selectedScheduleCode,
          adminName: adminName,
          profileImagePath: profileImagePath,
          onScheduleAdded: onScheduleAdded, onBrandsUpdated: (List<Brand> p1) {  },
        ),
        '/schedule': (context) => SchedulingDetails(
          adminName: adminName,
          profileImagePath: profileImagePath,
          onScheduleUpdated: (schedules) {},
        ),

        '/borrowed-equipment': (context) => BorrowedEquipmentManagementScreen(
          profileImagePath: profileImagePath,
          adminName: adminName,
          onEquipmentUpdated: (List<BorrowedEquipment> updatedEquipment) {},
        ),
      },
    );
  }
}
