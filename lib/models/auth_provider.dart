import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:healtime_app/models/user.dart';
import 'package:healtime_app/utils/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { patient, doctor, admin }

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userName;
  UserRole? _role;
  String? _userId;
  String? _token;
  User? _user;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  UserRole? get role => _role;
  String? get userId => _userId;
  String? get token => _token;
  User? get user => _user;

  AuthProvider() {
    autoLogin();
  }

  Future<void> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('userData')) {
      final userData =
          json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
      _isAuthenticated = true;
      _userId = userData['userId'];
      _userName = userData['userName'];
      _role = userData['role'] == 'doctor'
          ? UserRole.doctor
          : (userData['role'] == 'admin' ? UserRole.admin : UserRole.patient);
      _token = userData['token'];
      if (userData['userObj'] != null) {
        _user = User.fromMap(userData['userObj'] as Map<String, dynamic>);
      }
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });

      if (response != null) {
        _isAuthenticated = true;
        _userId = response['id']?.toString();
        _userName = response['name']?.toString();
        final roleStr = response['role']?.toString() ?? 'patient';
        _role = roleStr == 'doctor'
            ? UserRole.doctor
            : (roleStr == 'admin' ? UserRole.admin : UserRole.patient);
        _token = response['token']?.toString() ?? 'dummy_token';
        _user = User.fromMap(response);

        if (_userId == null) {
          debugPrint('Auth Error: ID is null in response');
          _isAuthenticated = false;
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'userName': _userName,
          'role': roleStr,
          'userObj': _user?.toMap(),
        });
        prefs.setString('userData', userData);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });

      if (response != null) {
        _isAuthenticated = true;
        _userId = response['id']?.toString();
        _userName = response['name']?.toString();
        final roleStr = response['role']?.toString() ?? 'patient';
        _role = roleStr == 'doctor'
            ? UserRole.doctor
            : (roleStr == 'admin' ? UserRole.admin : UserRole.patient);
        _token = response['token']?.toString() ?? 'dummy_token';
        _user = User.fromMap(response);

        if (_userId == null) {
          debugPrint('Registration Error: ID is null in response');
          _isAuthenticated = false;
          return false;
        }

        final prefs = await SharedPreferences.getInstance();
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'userName': _userName,
          'role': roleStr,
          'userObj': _user?.toMap(),
        });
        prefs.setString('userData', userData);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _user = updatedUser;
    _userName = updatedUser.name;

    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode({
      'token': _token,
      'userId': _userId,
      'userName': _userName,
      'role': _role == UserRole.doctor
          ? 'doctor'
          : (_role == UserRole.admin ? 'admin' : 'patient'),
      'userObj': _user?.toMap(),
    });
    await prefs.setString('userData', userData);

    notifyListeners();
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userName = null;
    _role = null;
    _userId = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}
