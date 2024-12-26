class User {
  int? id; // Making it nullable to be set after insert
  final String username;
  final String email;
  String password; // Will store hashed password
  final String phoneNumber;
  String? token;

  User({
    this.id, // ID will be set after insertion
    required this.username,
    required this.email,
    required this.password,
    required this.phoneNumber,
    this.token,
  });

  // Method to convert the User object to a map (for MySQL insertion)
  Map<String, dynamic> toJson() => {
        'id': id, // It can be null before insertion, populated later by MySQL
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'token': token,
      };

  // Static method to create a User object from JSON
  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
        phoneNumber: json['phoneNumber'],
        token: json['token'],
      );
}
