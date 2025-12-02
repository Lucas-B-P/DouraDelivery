import 'package:dio/dio.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _apiService.dio.post(
        '/api/cliente/pedidos',
        data: orderData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao criar pedido: ${e.response?.data ?? e.message}');
    }
  }
  
  Future<List<dynamic>> getMyOrders() async {
    try {
      final response = await _apiService.dio.get('/api/cliente/pedidos');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao carregar pedidos: ${e.response?.data ?? e.message}');
    }
  }
  
  Future<List<dynamic>> getDriverOrders() async {
    try {
      final response = await _apiService.dio.get('/api/entregador/pedidos');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao carregar pedidos: ${e.response?.data ?? e.message}');
    }
  }
  
  Future<Map<String, dynamic>> acceptOrder(int orderId) async {
    try {
      final response = await _apiService.dio.post(
        '/api/entregador/pedidos/$orderId/aceitar',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao aceitar pedido: ${e.response?.data ?? e.message}');
    }
  }
  
  Future<void> rejectOrder(int orderId) async {
    try {
      await _apiService.dio.post('/api/entregador/pedidos/$orderId/recusar');
    } on DioException catch (e) {
      throw Exception('Erro ao recusar pedido: ${e.response?.data ?? e.message}');
    }
  }
  
  Future<Map<String, dynamic>> confirmDelivery(int orderId) async {
    try {
      final response = await _apiService.dio.post(
        '/api/entregador/pedidos/$orderId/entregar',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Erro ao confirmar entrega: ${e.response?.data ?? e.message}');
    }
  }
}

