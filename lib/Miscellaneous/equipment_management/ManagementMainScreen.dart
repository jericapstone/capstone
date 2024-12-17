// import 'package:flutter/material.dart';
// import 'package:capstonesproject2024/models.dart' as models;
// import 'package:capstonesproject2024/services/firestore_service.dart';
// import 'package:capstonesproject2024/sidebar.dart';
// import 'brand_management_screen.dart';
// import 'EquipmentTypeManagementScreen.dart';
//
// class ManagementMainScreen extends StatefulWidget {
//   final String profileImagePath;
//   final String adminName;
//
//   const ManagementMainScreen({
//     Key? key,
//     required this.profileImagePath,
//     required this.adminName,
//   }) : super(key: key);
//
//   @override
//   _ManagementMainScreenState createState() => _ManagementMainScreenState();
// }
//
// class _ManagementMainScreenState extends State<ManagementMainScreen> {
//   final FirestoreService firestoreService = FirestoreService();
//
//   // Callback function to update brands
//   void onBrandsUpdated(List<models.Brand> brands) {
//     // Handle brand updates if needed
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           Sidebar(
//             profileImagePath: widget.profileImagePath,
//             adminName: widget.adminName,
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Miscellaneous',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   // Brand Management Section
//                   BrandManagementScreen(
//                     profileImagePath: widget.profileImagePath,
//                     adminName: widget.adminName,
//                     onBrandsUpdated: onBrandsUpdated,
//                   ),
//                   const SizedBox(height: 32), // Add some space between sections
//                   // Equipment Type Management Section
//                   EquipmentTypeManagementScreen(
//                     profileImagePath: widget.profileImagePath,
//                     adminName: widget.adminName,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
