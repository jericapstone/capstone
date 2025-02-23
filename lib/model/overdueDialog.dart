import 'package:capstonesproject2024/model/borrowingModel.dart';
import 'package:capstonesproject2024/services/notifemailsevice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverdueDialog extends StatefulWidget {
  final Borrowing borrowing;
  final EmailServiceVer messageService;

  const OverdueDialog({
    Key? key,
    required this.borrowing,
    required this.messageService,
  }) : super(key: key);

  @override
  _OverdueDialogState createState() => _OverdueDialogState();
}

class _OverdueDialogState extends State<OverdueDialog> {
  DateTime? _newExpectedReturnTime;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill a default overdue message
    _messageController.text =
        "Hi ${widget.borrowing.borrowerName},\n\nYour borrowed item "
        "(Serial: ${widget.borrowing.serialNumber}) is overdue. "
        "Please return it or request an extension ASAP.\n\nThank you.";
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // Method to pick new extended date/time
  Future<void> _pickNewExpectedReturnTime() async {
    final now = DateTime.now();
    final DateTime? newDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (newDate != null) {
      final TimeOfDay? newTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (newTime != null) {
        setState(() {
          _newExpectedReturnTime = DateTime(
            newDate.year,
            newDate.month,
            newDate.day,
            newTime.hour,
            newTime.minute,
          );
        });
      }
    }
  }

  // Extend the borrow time in Firestore
  Future<void> _extendBorrowTime() async {
    if (_newExpectedReturnTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please pick a new Expected Return Time."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance
          .collection('borrowings')
          .doc(widget.borrowing.id) // Use the doc ID
          .update({
        'expectedReturn': Timestamp.fromDate(_newExpectedReturnTime!),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Borrow time extended successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // close the dialog
    } catch (e) {
      print("Error updating expectedReturn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to extend borrow time."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Send email to the borrower
  Future<void> _sendOverdueEmail() async {
    try {
      await widget.messageService.sendMailVerified(
        recipientEmail: widget.borrowing.borrowerEmail ?? "zerpstan@gmail.com",
        subject: "Overdue Notice - ${widget.borrowing.serialNumber}",
        message: _messageController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email sent successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(); // close the dialog
    } catch (e) {
      print("Error sending overdue email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send email."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Overdue Item - ${widget.borrowing.serialNumber}"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Extend Borrow Time
            const Text(
              "Extend Borrow Time",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              _newExpectedReturnTime == null
                  ? "No new time selected"
                  : "New Expected Return: "
                      "${DateFormat('yyyy-MM-dd – kk:mm').format(_newExpectedReturnTime!)}",
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _pickNewExpectedReturnTime,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text(
                "Pick New Date/Time",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const Divider(height: 20),

            // Overdue Email
            const Text(
              "Overdue Email Message",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text("Extend Borrow Time"),
          onPressed: _extendBorrowTime,
        ),
        ElevatedButton(
          child: const Text("Send Email"),
          onPressed: _sendOverdueEmail,
        ),
      ],
    );
  }
}
