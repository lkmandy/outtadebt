import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleUser {
  final String uid;
  final String email;
  final String? displayName;

  const SimpleUser({
    required this.uid,
    required this.email,
    this.displayName,
  });
}

class AuthService {
  AuthService({required SharedPreferences prefs}) : _prefs = prefs {
    _loadSession();
  }

  final SharedPreferences _prefs;

  static const _sessionIdKey = 'auth_user_id';
  static const _sessionEmailKey = 'auth_user_email';
  static const _sessionNameKey = 'auth_user_name';

  final isLoggedIn = ValueNotifier<bool>(false);
  final userId = ValueNotifier<String?>(null);

  SimpleUser? _currentUser;
  SimpleUser? get currentUser => _currentUser;

  void _loadSession() {
    final id = _prefs.getString(_sessionIdKey);
    final email = _prefs.getString(_sessionEmailKey);
    if (id != null && email != null) {
      _currentUser = SimpleUser(
        uid: id,
        email: email,
        displayName: _prefs.getString(_sessionNameKey),
      );
      isLoggedIn.value = true;
      userId.value = id;
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final stored = _prefs.getString('user_${email.toLowerCase()}');
    if (stored == null) {
      throw Exception('No account found with this email');
    }
    final data = jsonDecode(stored) as Map<String, dynamic>;
    if (data['password'] != password) {
      throw Exception('Incorrect password');
    }
    _currentUser = SimpleUser(
      uid: data['id'] as String,
      email: email,
      displayName: data['name'] as String?,
    );
    await _saveSession();
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    final key = 'user_${email.toLowerCase()}';
    if (_prefs.getString(key) != null) {
      throw Exception('Email is already in use');
    }
    final id = email.toLowerCase();
    await _prefs.setString(
      key,
      jsonEncode({'id': id, 'name': name, 'password': password}),
    );
    _currentUser = SimpleUser(uid: id, email: email, displayName: name);
    await _saveSession();
  }

  Future<void> signOut() async {
    await _prefs.remove(_sessionIdKey);
    await _prefs.remove(_sessionEmailKey);
    await _prefs.remove(_sessionNameKey);
    _currentUser = null;
    isLoggedIn.value = false;
    userId.value = null;
  }

  Future<void> _saveSession() async {
    await _prefs.setString(_sessionIdKey, _currentUser!.uid);
    await _prefs.setString(_sessionEmailKey, _currentUser!.email);
    if (_currentUser!.displayName != null) {
      await _prefs.setString(_sessionNameKey, _currentUser!.displayName!);
    }
    isLoggedIn.value = true;
    userId.value = _currentUser!.uid;
  }

  void dispose() {
    isLoggedIn.dispose();
    userId.dispose();
  }
}
