import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = "Alex Rivers";
  String _role = "Zen Master Member";

  String get name => _name;
  String get role => _role;

  void updateProfile(String name, String role) {
    _name = name;
    _role = role;
    notifyListeners();
  }
}
