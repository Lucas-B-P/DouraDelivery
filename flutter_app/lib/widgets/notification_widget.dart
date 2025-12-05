import 'package:flutter/material.dart';
import 'dart:async';
import '../services/notification_service.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  final NotificationService _notificationService = NotificationService();
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _startListening();
    _notificationService.startNotificationSimulation();
  }

  void _startListening() {
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) {
        if (mounted) {
          setState(() {
            _notifications.insert(0, notification);
            // Manter apenas as últimas 10 notificações
            if (_notifications.length > 10) {
              _notifications = _notifications.take(10).toList();
            }
          });
          _showNotificationSnackBar(notification);
        }
      },
    );
  }

  void _showNotificationSnackBar(Map<String, dynamic> notification) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification['title'] ?? 'Notificação',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(notification['message'] ?? ''),
          ],
        ),
        backgroundColor: _getNotificationColor(notification['type']),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'document_approved':
        return Colors.green;
      case 'document_rejected':
        return Colors.orange;
      case 'new_document_pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'document_approved':
        return Icons.check_circle;
      case 'document_rejected':
        return Icons.cancel;
      case 'new_document_pending':
        return Icons.pending;
      default:
        return Icons.notifications;
    }
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    _notificationService.stopNotificationSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Stack(
        children: [
          const Icon(Icons.notifications),
          if (_notifications.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${_notifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      itemBuilder: (context) {
        if (_notifications.isEmpty) {
          return [
            const PopupMenuItem(
              value: 'empty',
              child: Text('Nenhuma notificação'),
            ),
          ];
        }

        return _notifications.map((notification) {
          return PopupMenuItem<String>(
            value: notification['timestamp'],
            child: ListTile(
              leading: Icon(
                _getNotificationIcon(notification['type']),
                color: _getNotificationColor(notification['type']),
              ),
              title: Text(
                notification['title'] ?? 'Notificação',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['message'] ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(notification['timestamp']),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              dense: true,
            ),
          );
        }).toList();
      },
      onSelected: (value) {
        if (value != 'empty') {
          // Aqui você pode implementar ação ao clicar na notificação
        }
      },
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Agora';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m atrás';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h atrás';
      } else {
        return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return timestamp;
    }
  }
}
