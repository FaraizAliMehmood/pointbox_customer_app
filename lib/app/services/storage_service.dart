import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  static const String _notificationsKey = 'notifications';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    return await _prefs.clear();
  }

  // Notifications storage methods
  Future<bool> saveNotifications(List<Map<String, dynamic>> notifications) async {
    final jsonString = jsonEncode(notifications);
    return await _prefs.setString(_notificationsKey, jsonString);
  }

  List<Map<String, dynamic>> getNotifications() {
    final jsonString = _prefs.getString(_notificationsKey);
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addNotification(Map<String, dynamic> notification) async {
    final notifications = getNotifications();
    notifications.insert(0, notification); // Add to beginning
    return await saveNotifications(notifications);
  }

  int getUnreadNotificationCount() {
    final notifications = getNotifications();
    return notifications.where((n) => n['isRead'] != true).length;
  }
}

