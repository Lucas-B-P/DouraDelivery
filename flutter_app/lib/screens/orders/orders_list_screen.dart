import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import 'create_order_screen.dart';
import 'order_detail_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  final OrderService _orderService = OrderService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String _filter = 'ALL'; // ALL, NEW, ASSIGNED, IN_TRANSIT, DELIVERED

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = await authProvider.authService.getUserId();
      final userType = await authProvider.authService.getUserType();

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      List<Map<String, dynamic>> orders = [];

      if (userType == 'ADMIN') {
        orders = await _orderService.getAllOrders();
      } else if (userType == 'DRIVER') {
        orders = await _orderService.getOrdersByDriver(userId);
      } else {
        orders = await _orderService.getOrdersByClient(userId);
      }

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao carregar pedidos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_filter == 'ALL') {
      return _orders;
    }
    return _orders.where((order) => order['status'] == _filter).toList();
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    try {
      final response = await _orderService.updateOrderStatus(orderId, newStatus);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrders(); // Recarregar lista
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${response['message'] ?? 'Erro ao atualizar status'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro inesperado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStatusUpdateDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualizar Status - Pedido #${order['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.new_releases, color: Colors.blue),
              title: const Text('Novo'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'NEW');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.orange),
              title: const Text('Atribuído'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'ASSIGNED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.purple),
              title: const Text('Coletado'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'PICKED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.amber),
              title: const Text('Em Trânsito'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'IN_TRANSIT');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Entregue'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'DELIVERED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelado'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus(order['id'], 'CANCELED');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'NEW';
    final statusColor = _orderService.getStatusColor(status);
    final statusText = _orderService.getStatusText(status);
    final priority = order['priority'] ?? 'NORMAL';
    final priorityText = _orderService.getPriorityText(priority);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(orderId: order['id']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ID e Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pedido #${order['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Origem e Destino
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['originAddress'] ?? 'Origem não informada',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order['destinationAddress'] ?? 'Destino não informado',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informações adicionais
              Row(
                children: [
                  // Peso
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fitness_center, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${order['weight'] ?? 0}kg',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Prioridade
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.priority_high, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          priorityText,
                          style: const TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Botão de ações
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'update_status') {
                        _showStatusUpdateDialog(order);
                      } else if (value == 'details') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(orderId: order['id']),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16),
                            SizedBox(width: 8),
                            Text('Ver Detalhes'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'update_status',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Atualizar Status'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              
              // Data de criação
              if (order['createdAt'] != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Criado em: ${_formatDate(order['createdAt'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Meus Pedidos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'ALL', child: Text('🔍 Todos')),
              const PopupMenuItem(value: 'NEW', child: Text('🆕 Novos')),
              const PopupMenuItem(value: 'ASSIGNED', child: Text('📋 Atribuídos')),
              const PopupMenuItem(value: 'IN_TRANSIT', child: Text('🚚 Em Trânsito')),
              const PopupMenuItem(value: 'DELIVERED', child: Text('✅ Entregues')),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando pedidos...'),
                ],
              ),
            )
          : _filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filter == 'ALL' 
                            ? 'Nenhum pedido encontrado'
                            : 'Nenhum pedido com este filtro',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Que tal criar seu primeiro pedido?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateOrderScreen(),
                            ),
                          );
                          if (result == true) {
                            _loadOrders();
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _buildOrderCard(_filteredOrders[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateOrderScreen(),
            ),
          );
          if (result == true) {
            _loadOrders();
          }
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
