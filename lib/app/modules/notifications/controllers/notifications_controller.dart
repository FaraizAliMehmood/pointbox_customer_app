import 'package:get/get.dart';
import 'package:pointbox_mobile/app/models/notification_model.dart';
import 'package:pointbox_mobile/app/services/api_service.dart';

class NotificationsController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    try {
      final response = await ApiService.getNotifications();

      if (response['success'] == true && response['data'] is List) {
        final notificationList = (response['data'] as List)
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();

        notifications.value = notificationList;
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);

      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsAsRead();

      notifications.value = notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      _updateUnreadCount();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await ApiService.deleteNotification(notificationId);

      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await ApiService.clearAllNotifications();

      notifications.clear();
      _updateUnreadCount();
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }
}
