import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/websocket_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';
import '../login_screen.dart';

class ClienteOrdersScreen extends StatefulWidget {
  @override
  _ClienteOrdersScreenState createState() => _ClienteOrdersScreenState();
}

class _ClienteOrdersScreenState extends State<ClienteOrdersScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebSocket();
      Provider.of<OrderProvider>(context, listen: false).loadMyOrders();
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
    _webSocketService.disconnect();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Pedidos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
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
              onRetry: () => provider.loadMyOrders(),
            );
          }
          
          if (provider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum pedido ainda'),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => provider.loadMyOrders(),
            child: ListView.builder(
              itemCount: provider.orders.length,
              itemBuilder: (context, index) {
                final order = provider.orders[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Icon(Icons.local_shipping, color: Colors.blue),
                    title: Text('Pedido #${order['id']}'),
                    subtitle: Text('Status: ${order['status']}\nPeso: ${order['weight']}kg'),
                    trailing: Chip(
                      label: Text(order['priority'] ?? 'NORMAL'),
                      backgroundColor: _getPriorityColor(order['priority']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateOrderScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
  
  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'EXPRESS':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'NORMAL':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

