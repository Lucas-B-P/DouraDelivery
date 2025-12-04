import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/user_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;
  
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _user = await _authService.login(email, password);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> registerData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authService.register(registerData);
      _error = null;
      return response;
    } catch (e) {
      _error = e.toString();
      return {'success': false, 'message': e.toString()};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
  
  Future<bool> checkAuth() async {
    return await _authService.isLoggedIn();
  }

  Widget getDashboardScreen() {
    if (_user == null) {
      return const LoginScreen();
    }
    
    final userType = _user!['userType'];
    if (userType == 'ADMIN') {
      return const AdminDashboardScreen();
    } else {
      return const UserDashboardScreen();
    }
  }
}

