import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(initSettings);
  }

  static Future<void> showOrderStatus(String orderId, String status) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'order_status',
        'Order Status',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    await _plugin.show(
      orderId.hashCode,
      'Pedido #$orderId',
      'Estado actualizado a: $status',
      details,
    );
  }
}
