import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_models.dart';
import '../config/app_config.dart';
import 'api_client.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthToken? _token;
  UserRole? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AuthToken? get token => _token;
  UserRole? get selectedRole => _selectedRole;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _token != null && !_token!.isExpired;

  late SharedPreferences _prefs;
  late ApiClient _apiClient;

  AuthProvider() {
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    _prefs = await SharedPreferences.getInstance();
    _apiClient = ApiClient();
    await tryAutoLogin();
  }

  void setSelectedRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.post(
        '/api/token/',
        data: {
          'email': email,
          'password': password,
        },
      );

      final tokenData = AuthToken.fromJson(response.data);
      final userData = User.fromJson(response.data['user']);

      _token = tokenData;
      _user = userData;

      // Store token and user in SharedPreferences
      await _prefs.setString('access_token', tokenData.accessToken);
      if (tokenData.refreshToken != null) {
        await _prefs.setString('refresh_token', tokenData.refreshToken!);
      }
      await _prefs.setString('user', jsonEncode(userData.toJson()));
      await _prefs.setString('token_expires_at', tokenData.expiresAt.toIso8601String());

      // Update API client with token
      _apiClient.setAuthToken(tokenData.accessToken);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final role = _selectedRole?.toString().split('.').last ?? 'buyer';

      final response = await _apiClient.post(
        '/api/register/',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
          'phone': phone,
          'role': role,
        },
      );

      final tokenData = AuthToken.fromJson(response.data);
      final userData = User.fromJson(response.data['user']);

      _token = tokenData;
      _user = userData;

      // Store token and user in SharedPreferences
      await _prefs.setString('access_token', tokenData.accessToken);
      if (tokenData.refreshToken != null) {
        await _prefs.setString('refresh_token', tokenData.refreshToken!);
      }
      await _prefs.setString('user', jsonEncode(userData.toJson()));
      await _prefs.setString('token_expires_at', tokenData.expiresAt.toIso8601String());

      // Update API client with token
      _apiClient.setAuthToken(tokenData.accessToken);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = _parseError(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      final accessToken = _prefs.getString('access_token');
      final userJson = _prefs.getString('user');
      final expiresAtStr = _prefs.getString('token_expires_at');

      if (accessToken == null || userJson == null || expiresAtStr == null) {
        return false;
      }

      final expiresAt = DateTime.parse(expiresAtStr);
      final user = User.fromJson(jsonDecode(userJson));

      _token = AuthToken(
        accessToken: accessToken,
        refreshToken: _prefs.getString('refresh_token'),
        expiresAt: expiresAt,
      );
      _user = user;

      // Update API client with token
      _apiClient.setAuthToken(accessToken);

      // Check if token is expiring soon and refresh if needed
      if (_token!.isExpiringSoon && !_token!.isExpired) {
        await _refreshToken();
      }

      notifyListeners();
      return isAuthenticated;
    } catch (e) {
      debugPrint('Auto login failed: $e');
      return false;
    }
  }

  Future<void> _refreshToken() async {
    try {
      final refreshToken = _prefs.getString('refresh_token');
      if (refreshToken == null) {
        await logout();
        return;
      }

      final response = await _apiClient.post(
        '/api/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final tokenData = AuthToken.fromJson(response.data);
      _token = tokenData;

      await _prefs.setString('access_token', tokenData.accessToken);
      await _prefs.setString('token_expires_at', tokenData.expiresAt.toIso8601String());

      _apiClient.setAuthToken(tokenData.accessToken);
      notifyListeners();
    } catch (e) {
      debugPrint('Token refresh failed: $e');
      await logout();
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _selectedRole = null;
    _errorMessage = null;

    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
    await _prefs.remove('user');
    await _prefs.remove('token_expires_at');

    _apiClient.clearAuthToken();
    notifyListeners();
  }

  String _parseError(dynamic error) {
    if (error is String) {
      return error;
    }
    // Handle DIO errors or other exceptions
    return 'Une erreur s\'est produite. Veuillez réessayer.';
  }
}
