import 'dart:async';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final StreamController<Map<String, dynamic>> _notificationController = 
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  // Simular notificações em tempo real
  Timer? _simulationTimer;

  void startNotificationSimulation() {
    if (_simulationTimer != null) return;
    
    print('🔔 Iniciando simulação de notificações...');
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Simular diferentes tipos de notificações
      final notifications = [
        {
          'type': 'document_approved',
          'title': '✅ Documentos Aprovados!',
          'message': 'Seus documentos foram aprovados. Sua conta está ativa!',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'type': 'document_rejected',
          'title': '📋 Documentos Rejeitados',
          'message': 'Seus documentos precisam ser reenviados. Verifique as observações.',
          'timestamp': DateTime.now().toIso8601String(),
        },
        {
          'type': 'new_document_pending',
          'title': '📄 Novo Documento Pendente',
          'message': 'Um novo documento foi enviado para análise.',
          'timestamp': DateTime.now().toIso8601String(),
        },
      ];
      
      // Enviar notificação aleatória
      if (notifications.isNotEmpty) {
        final randomNotification = notifications[DateTime.now().millisecond % notifications.length];
        _notificationController.add(randomNotification);
        print('🔔 Notificação enviada: ${randomNotification['title']}');
      }
    });
  }

  void stopNotificationSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    print('🔕 Simulação de notificações parada');
  }

  void sendNotification({
    required String type,
    required String title,
    required String message,
  }) {
    final notification = {
      'type': type,
      'title': title,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _notificationController.add(notification);
    print('🔔 Notificação manual enviada: $title');
  }

  // Notificações específicas do sistema
  void notifyDocumentApproved(String userName) {
    sendNotification(
      type: 'document_approved',
      title: '✅ Documentos Aprovados!',
      message: 'Parabéns $userName! Seus documentos foram aprovados.',
    );
  }

  void notifyDocumentRejected(String userName, String reason) {
    sendNotification(
      type: 'document_rejected',
      title: '📋 Documentos Rejeitados',
      message: 'Olá $userName, seus documentos foram rejeitados. Motivo: $reason',
    );
  }

  void notifyNewDocumentPending(String userName) {
    sendNotification(
      type: 'new_document_pending',
      title: '📄 Novo Documento Pendente',
      message: 'Documento de $userName está aguardando análise.',
    );
  }

  void dispose() {
    stopNotificationSimulation();
    _notificationController.close();
  }
}
