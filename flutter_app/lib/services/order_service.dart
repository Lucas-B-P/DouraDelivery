import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show Colors, Color;
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  // Criar novo pedido
  Future<Map<String, dynamic>> createOrder({
    required int clientId,
    required double originLat,
    required double originLon,
    required double destinationLat,
    required double destinationLon,
    String? originAddress,
    String? destinationAddress,
    required double weight,
    double volume = 0.0,
    String priority = 'NORMAL',
    String? description,
    DateTime? timeWindowStart,
    DateTime? timeWindowEnd,
  }) async {
    try {
      final data = {
        'clientId': clientId,
        'originLat': originLat,
        'originLon': originLon,
        'destinationLat': destinationLat,
        'destinationLon': destinationLon,
        'originAddress': originAddress,
        'destinationAddress': destinationAddress,
        'weight': weight,
        'volume': volume,
        'priority': priority,
        'description': description,
        if (timeWindowStart != null) 'timeWindowStart': timeWindowStart.toIso8601String(),
        if (timeWindowEnd != null) 'timeWindowEnd': timeWindowEnd.toIso8601String(),
      };

      final response = await _apiService.dio.post('/api/orders', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data ?? {'success': false, 'message': 'Erro no servidor'};
      }
      return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': 'Erro inesperado: $e'};
    }
  }

  // Buscar pedidos do cliente
  Future<List<Map<String, dynamic>>> getOrdersByClient(int clientId) async {
    try {
      final response = await _apiService.dio.get('/api/orders/client/$clientId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar pedidos do cliente: ${e.message}');
      return [];
    }
  }

  // Buscar todos os pedidos (admin)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _apiService.dio.get('/api/orders');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar todos os pedidos: ${e.message}');
      return [];
    }
  }

  // Buscar pedidos disponíveis (para entregadores)
  Future<List<Map<String, dynamic>>> getAvailableOrders() async {
    try {
      final response = await _apiService.dio.get('/api/orders/available');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar pedidos disponíveis: ${e.message}');
      return [];
    }
  }

  // Buscar pedidos do entregador
  Future<List<Map<String, dynamic>>> getOrdersByDriver(int driverId) async {
    try {
      final response = await _apiService.dio.get('/api/orders/driver/$driverId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('Erro ao buscar pedidos do entregador: ${e.message}');
      return [];
    }
  }

  // Buscar pedido por ID
  Future<Map<String, dynamic>?> getOrderById(int orderId) async {
    try {
      final response = await _apiService.dio.get('/api/orders/$orderId');
      return response.data;
    } on DioException catch (e) {
      print('Erro ao buscar pedido: ${e.message}');
      return null;
    }
  }

  // Atualizar status do pedido
  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _apiService.dio.put(
        '/api/orders/$orderId/status',
        data: {'status': status},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data ?? {'success': false, 'message': 'Erro no servidor'};
      }
      return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
    }
  }

  // Atribuir entregador ao pedido (admin)
  Future<Map<String, dynamic>> assignDriverToOrder(int orderId, int driverId) async {
    try {
      final response = await _apiService.dio.put('/api/orders/$orderId/assign/$driverId');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data ?? {'success': false, 'message': 'Erro no servidor'};
      }
      return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
    }
  }

  // Excluir pedido (admin)
  Future<Map<String, dynamic>> deleteOrder(int orderId) async {
    try {
      final response = await _apiService.dio.delete('/api/orders/$orderId');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data ?? {'success': false, 'message': 'Erro no servidor'};
      }
      return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
    }
  }

  // Calcular distância do pedido
  Future<Map<String, dynamic>?> getOrderDistance(int orderId) async {
    try {
      final response = await _apiService.dio.get('/api/orders/$orderId/distance');
      return response.data;
    } on DioException catch (e) {
      print('Erro ao calcular distância: ${e.message}');
      return null;
    }
  }

  // Função auxiliar para calcular distância local (Haversine)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Raio da Terra em km
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
        (sin(dLon / 2) * sin(dLon / 2));
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Função para formatar status em português
  String getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return 'Novo';
      case 'ASSIGNED':
        return 'Atribuído';
      case 'PICKED':
        return 'Coletado';
      case 'IN_TRANSIT':
        return 'Em Trânsito';
      case 'DELIVERED':
        return 'Entregue';
      case 'CANCELED':
        return 'Cancelado';
      default:
        return status;
    }
  }

  // Função para obter cor do status
  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'NEW':
        return Colors.blue;
      case 'ASSIGNED':
        return Colors.orange;
      case 'PICKED':
        return Colors.purple;
      case 'IN_TRANSIT':
        return Colors.amber;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Função para formatar prioridade
  String getPriorityText(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return 'Baixa';
      case 'NORMAL':
        return 'Normal';
      case 'HIGH':
        return 'Alta';
      case 'EXPRESS':
        return 'Expressa';
      default:
        return priority;
    }
  }
}