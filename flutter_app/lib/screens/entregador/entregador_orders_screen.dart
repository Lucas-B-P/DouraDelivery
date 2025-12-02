import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/telemetry_service.dart';
import '../../services/order_service.dart';
import '../../services/websocket_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../login_screen.dart';

class EntregadorOrdersScreen extends StatefulWidget {
  @override
  _EntregadorOrdersScreenState createState() => _EntregadorOrdersScreenState();
}

class _EntregadorOrdersScreenState extends State<EntregadorOrdersScreen> {
  final TelemetryService _telemetryService = TelemetryService();
  final WebSocketService _webSocketService = WebSocketService();
  bool _isTracking = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
      Provider.of<OrderProvider>(context, listen: false).loadDriverOrders();
    });
  }
  
  Future<void> _initializeWebSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final userType = prefs.getString('user_type');
    
    if (userId != null && userType != null) {
      await _webSocketService.connect(userId, userType);
    }
  }
  
  @override
  void dispose() {
    _telemetryService.stop();
    _webSocketService.disconnect();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos Atribuídos'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Row(
              children: [
                Text('GPS', style: TextStyle(fontSize: 12)),
                Switch(
                  value: _isTracking,
                  onChanged: (value) {
                    setState(() {
                      _isTracking = value;
                    });
                    if (value) {
                      _telemetryService.start().catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao iniciar rastreamento: $e')),
                        );
                        setState(() => _isTracking = false);
                      });
                    } else {
                      _telemetryService.stop();
                    }
                  },
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              _telemetryService.stop();
              _webSocketService.disconnect();
              await Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return LoadingWidget();
          }
          
          if (provider.error != null) {
            return ErrorDisplayWidget(
              error: provider.error!,
              onRetry: () => provider.loadDriverOrders(),
            );
          }
          
          if (provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum pedido atribuído'),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.loadDriverOrders(),
            child: ListView.builder(
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.local_shipping, color: Colors.green),
                    title: Text('Pedido #${order['id']}'),
                    subtitle: Text('Status: ${order['status']}\nPeso: ${order['weight']}kg'),
                    trailing: _buildActionButton(order, provider),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActionButton(Map<String, dynamic> order, OrderProvider provider) {
    final status = order['status'];
    
    if (status == 'ASSIGNED') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () => _acceptOrder(order['id'], provider),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => _rejectOrder(order['id'], provider),
          ),
        ],
      );
    } else if (status == 'PICKED' || status == 'IN_TRANSIT') {
      return ElevatedButton(
        onPressed: () => _confirmDelivery(order['id'], provider),
        child: Text('Entregar'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      );
    }
    
    return Chip(label: Text(status));
  }
  
  Future<void> _acceptOrder(int orderId, OrderProvider provider) async {
    await provider.acceptOrder(orderId);
    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido aceito!')),
      );
    }
  }
  
  Future<void> _rejectOrder(int orderId, OrderProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recusar Pedido'),
        content: Text('Tem certeza que deseja recusar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Recusar'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final orderService = OrderService();
        await orderService.rejectOrder(orderId);
        await provider.loadDriverOrders();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido recusado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }
  
  Future<void> _confirmDelivery(int orderId, OrderProvider provider) async {
    await provider.confirmDelivery(orderId);
    if (provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entrega confirmada!')),
      );
    }
  }
}
