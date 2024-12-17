class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String accountType;
  final String status;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accountType,
    required this.status,
  });

  // Convert Firestore document to User object
  factory User.fromDocument(Map<String, dynamic> data, String id) {
    return User(
      id: id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      accountType: data['accountType'] ?? 'Administrator',
      status: data['status'] ?? 'Active',
    );
  }
}
