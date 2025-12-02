import 'package:flutter/foundation.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<dynamic> _orders = [];
  bool _isLoading = false;
  String? _error;
  
  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newOrder = await _orderService.createOrder(orderData);
      _orders.insert(0, newOrder);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadMyOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _orders = await _orderService.getMyOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadDriverOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _orders = await _orderService.getDriverOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> acceptOrder(int orderId) async {
    try {
      final updatedOrder = await _orderService.acceptOrder(orderId);
      final index = _orders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> confirmDelivery(int orderId) async {
    try {
      final updatedOrder = await _orderService.confirmDelivery(orderId);
      final index = _orders.indexWhere((o) => o['id'] == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

