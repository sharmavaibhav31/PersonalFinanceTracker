import 'package:flutter/material.dart';
import 'package:expense_manager/models/expense_model.dart';
import 'package:expense_manager/utils/storage_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  budgetExceeded,
  budgetWarning,
  spendingAlert,
  achievement,
  reminder,
}

class NotificationController extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];
  final StorageService _storageService = StorageService();

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationController() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationsData = await _storageService.getSetting('notifications', []) as List;
      _notifications.clear();
      for (final data in notificationsData) {
        _notifications.add(NotificationItem(
          id: data['id'],
          title: data['title'],
          message: data['message'],
          timestamp: DateTime.parse(data['timestamp']),
          type: NotificationType.values.firstWhere(
            (e) => e.name == data['type'],
            orElse: () => NotificationType.reminder,
          ),
          isRead: data['isRead'] ?? false,
        ));
      }
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final notificationsData = _notifications.map((n) => {
        'id': n.id,
        'title': n.title,
        'message': n.message,
        'timestamp': n.timestamp.toIso8601String(),
        'type': n.type.name,
        'isRead': n.isRead,
      }).toList();
      await _storageService.saveSetting('notifications', notificationsData);
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> checkBudgetAlerts(List<Expense> recentExpenses) async {
    final budget = await _storageService.getSetting('monthly_budget', 0.0) as double;
    if (budget <= 0) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final monthlyExpenses = recentExpenses
        .where((e) => e.date.isAfter(startOfMonth))
        .fold(0.0, (sum, e) => sum + e.amount);

    final budgetRatio = monthlyExpenses / budget;

    // Remove existing budget alerts
    _notifications.removeWhere((n) => 
        n.type == NotificationType.budgetExceeded || 
        n.type == NotificationType.budgetWarning);

    // Add new budget alerts
    if (budgetRatio > 1.0) {
      await addNotification(
        title: 'Budget Exceeded!',
        message: 'You have spent ₹${monthlyExpenses.toStringAsFixed(0)} this month, which is ${(budgetRatio * 100).toStringAsFixed(0)}% of your ₹${budget.toStringAsFixed(0)} budget.',
        type: NotificationType.budgetExceeded,
      );
    } else if (budgetRatio > 0.8) {
      await addNotification(
        title: 'Budget Warning',
        message: 'You have used ${(budgetRatio * 100).toStringAsFixed(0)}% of your monthly budget. Only ₹${(budget - monthlyExpenses).toStringAsFixed(0)} remaining.',
        type: NotificationType.budgetWarning,
      );
    }
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );

    _notifications.insert(0, notification);
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }
}
