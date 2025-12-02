class AppConstants {
  // Cores
  static const int primaryColor = 0xFF2196F3; // Azul
  static const int successColor = 0xFF4CAF50; // Verde
  static const int errorColor = 0xFFF44336; // Vermelho
  static const int warningColor = 0xFFFF9800; // Laranja
  
  // Status de Pedido
  static const String statusNew = 'NEW';
  static const String statusAssigned = 'ASSIGNED';
  static const String statusPicked = 'PICKED';
  static const String statusInTransit = 'IN_TRANSIT';
  static const String statusDelivered = 'DELIVERED';
  static const String statusCanceled = 'CANCELED';
  
  // Prioridades
  static const String priorityLow = 'LOW';
  static const String priorityNormal = 'NORMAL';
  static const String priorityHigh = 'HIGH';
  static const String priorityExpress = 'EXPRESS';
  
  // Tipos de Usuário
  static const String userTypeCliente = 'CLIENTE';
  static const String userTypeEntregador = 'ENTREGADOR';
  static const String userTypeAdmin = 'ADMIN';
}

