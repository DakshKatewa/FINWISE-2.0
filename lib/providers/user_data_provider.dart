import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserDataProvider extends ChangeNotifier {
  static UserDataProvider? _instance;
  static UserDataProvider get instance {
    _instance ??= UserDataProvider._();
    return _instance!;
  }

  UserDataProvider._();

  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _transactions = [];
  String _username = 'User';
  bool _isLoading = true;

  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>> get transactions => _transactions;
  String get username => _username;
  bool get isLoading => _isLoading;

  // Initialize with prefetched data
  static Future<void> initialize({
    Map<String, dynamic>? userData,
    List<dynamic>? transactions,
    String? username,
  }) async {
    instance._userData = userData;
    instance._transactions = transactions?.cast<Map<String, dynamic>>() ?? [];
    instance._username = username ?? 'User';
    instance._isLoading = false;

    // Cache data for offline use
    await _cacheData(userData, transactions, username);

    instance.notifyListeners();
  }

  // Cache data in shared preferences
  static Future<void> _cacheData(
    Map<String, dynamic>? userData,
    List<dynamic>? transactions,
    String? username,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (userData != null) {
        await prefs.setString('cached_user_data', jsonEncode(userData));
      }

      if (transactions != null) {
        await prefs.setString('cached_transactions', jsonEncode(transactions));
      }

      if (username != null) {
        await prefs.setString('cached_username', username);
      }

      await prefs.setBool('has_cached_data', true);
    } catch (e) {
      print('Error caching data: $e');
    }
  }

  // Load cached data if available
  Future<bool> loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCachedData = prefs.getBool('has_cached_data') ?? false;

      if (!hasCachedData) return false;

      final cachedUserDataString = prefs.getString('cached_user_data');
      final cachedTransactionsString = prefs.getString('cached_transactions');
      final cachedUsername = prefs.getString('cached_username');

      if (cachedUserDataString != null) {
        _userData = jsonDecode(cachedUserDataString);
      }

      if (cachedTransactionsString != null) {
        final decoded = jsonDecode(cachedTransactionsString);
        _transactions = (decoded as List).cast<Map<String, dynamic>>();
      }

      if (cachedUsername != null) {
        _username = cachedUsername;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error loading cached data: $e');
      return false;
    }
  }

  // Refresh data from Firebase
  Future<void> refreshData() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get user doc
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (userDoc.exists) {
        _userData = userDoc.data();
        _username = _userData?['username'] ?? 'User';
      }

      // Get transactions
      final transactionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('transactions')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .get();

      _transactions =
          transactionsSnapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Include document ID
            return data;
          }).toList();

      // Cache the refreshed data
      await _cacheData(_userData, _transactions, _username);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error refreshing data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set up listeners for real-time updates
  void setupListeners(String userId) {
    // Listen to user document changes
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.exists) {
            _userData = snapshot.data();
            _username = _userData?['username'] ?? 'User';
            notifyListeners();

            // Update cache
            _cacheData(_userData, _transactions, _username);
          }
        });

    // Listen to transaction changes
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          _transactions =
              snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              }).toList();
          notifyListeners();

          // Update cache
          _cacheData(_userData, _transactions, _username);
        });
  }
}
