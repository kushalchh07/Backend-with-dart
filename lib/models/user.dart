import 'dart:convert';

class User {
  final int id;
  final String username;
  final String email;
  final String password;

  User({required this.id, required this.username, required this.email, required this.password});

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        email: json['email'],
        password: json['password'],
      );
}
