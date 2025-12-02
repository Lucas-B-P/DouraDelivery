import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WebSocketService {
  static const String baseUrl = 'wss://douradelivery-production.up.railway.app';
  WebSocketChannel? _channel;
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
    
    _isInitialized = true;
  }
  
  Future<void> connect(int userId, String userType) async {
    await initialize();
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return;
    
    final url = userType == 'ENTREGADOR' 
        ? '$baseUrl/ws/queue/driver/$userId'
        : '$baseUrl/ws/queue/client/$userId';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (message) {
          _handleNotification(message.toString());
        },
        onError: (error) {
          print('WebSocket error: $error');
          // Reconectar após 5 segundos
          Future.delayed(Duration(seconds: 5), () {
            connect(userId, userType);
          });
        },
        onDone: () {
          print('WebSocket disconnected');
        },
      );
    } catch (e) {
      print('Erro ao conectar WebSocket: $e');
    }
  }
  
  void _handleNotification(String message) {
    try {
      // Parse JSON básico (em produção, use jsonDecode)
      if (message.contains('NEW_ORDER')) {
        _showNotification('Novo Pedido', 'Você recebeu um novo pedido!');
      } else if (message.contains('ORDER_UPDATE')) {
        _showNotification('Pedido Atualizado', 'Seu pedido foi atualizado');
      } else if (message.contains('ROUTE_UPDATE')) {
        _showNotification('Rota Atualizada', 'Sua rota foi atualizada');
      }
    } catch (e) {
      print('Erro ao processar notificação: $e');
    }
  }
  
  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'douradelivery_channel',
      'DouraDelivery Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
    );
  }
  
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}

