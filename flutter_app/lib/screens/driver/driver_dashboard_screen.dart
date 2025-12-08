import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/telemetry_service.dart';
import '../orders/order_detail_screen.dart';
import '../login_screen.dart';
import 'route_planning_screen.dart';
import 'telemetry_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final OrderService _orderService = OrderService();
  final TelemetryService _telemetryService = TelemetryService();
  List<Map<String, dynamic>> _availableOrders = [];
  List<Map<String, dynamic>> _myOrders = [];
  bool _isLoading = true;
  bool _isTelemetryActive = false;
  String _driverName = '';
  int _driverId = 0;

  @override
  void initState() {
    super.initState();
    _loadDriverInfo();
    _loadOrders();
  }

  @override
  void dispose() {
    if (_isTelemetryActive) {
      _telemetryService.stop();
    }
    super.dispose();
  }

  Future<void> _loadDriverInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (mounted) {
      setState(() {
        _driverName = prefs.getString('user_name') ?? 'Entregador';
        _driverId = prefs.getInt('user_id') ?? 0;
      });
    }
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Carregar pedidos disponíveis (simulados por enquanto)
      _availableOrders = _getSimulatedAvailableOrders();
      
      // Carregar meus pedidos
      if (_driverId > 0) {
        final myOrders = await _orderService.getDriverOrders(_driverId);
        if (mounted) {
          setState(() {
            _myOrders = List<Map<String, dynamic>>.from(myOrders);
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
      // Em caso de erro, usar dados simulados
      _availableOrders = _getSimulatedAvailableOrders();
      _myOrders = _getSimulatedMyOrders();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getSimulatedAvailableOrders() {
    return [
      {
        'id': 101,
        'status': 'NEW',
        'priority': 'HIGH',
        'weight': 3.2,
        'volume': 0.2,
        'originAddress': 'Shopping Iguatemi - Faria Lima',
        'destinationAddress': 'Rua Oscar Freire, 500 - Jardins',
        'description': 'Produtos eletrônicos',
        'distance': 4.5,
        'estimatedEarnings': 25.50,
        'createdAt': DateTime.now().subtract(Duration(minutes: 15)).toIso8601String(),
        'client': {
          'id': 1,
          'name': 'Maria Silva',
          'phone': '(11) 99999-1234'
        }
      },
      {
        'id': 102,
        'status': 'NEW',
        'priority': 'NORMAL',
        'weight': 1.5,
        'volume': 0.1,
        'originAddress': 'Mercado Municipal - Centro',
        'destinationAddress': 'Av. Paulista, 1000 - Bela Vista',
        'description': 'Produtos frescos',
        'distance': 3.2,
        'estimatedEarnings': 18.75,
        'createdAt': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
        'client': {
          'id': 2,
          'name': 'João Santos',
          'phone': '(11) 98888-5678'
        }
      },
    ];
  }

  List<Map<String, dynamic>> _getSimulatedMyOrders() {
    return [
      {
        'id': 201,
        'status': 'IN_TRANSIT',
        'priority': 'EXPRESS',
        'weight': 2.1,
        'volume': 0.15,
        'originAddress': 'Rua Augusta, 200 - Consolação',
        'destinationAddress': 'Rua dos Jardins, 150 - Jardins',
        'description': 'Documentos importantes',
        'distance': 2.8,
        'estimatedEarnings': 32.00,
        'createdAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
        'client': {
          'id': 3,
          'name': 'Ana Costa',
          'phone': '(11) 97777-9999'
        }
      },
    ];
  }

  Future<void> _acceptOrder(Map<String, dynamic> order) async {
    try {
      await _orderService.acceptOrder(order['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedido aceito com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recarregar listas
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aceitar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelivery(Map<String, dynamic> order) async {
    try {
      await _orderService.confirmDelivery(order['id']);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Entrega confirmada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Recarregar listas
        _loadOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao confirmar entrega: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleTelemetry() async {
    try {
      if (_isTelemetryActive) {
        _telemetryService.stop();
        setState(() {
          _isTelemetryActive = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Telemetria desativada'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await _telemetryService.start();
        setState(() {
          _isTelemetryActive = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Telemetria ativada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro na telemetria: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - $_driverName'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTelemetryActive ? Icons.gps_fixed : Icons.gps_off),
            onPressed: _toggleTelemetry,
            tooltip: _isTelemetryActive ? 'Desativar GPS' : 'Ativar GPS',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: 24),
                    _buildAvailableOrdersSection(),
                    const SizedBox(height: 24),
                    _buildMyOrdersSection(),
                    const SizedBox(height: 24),
                    _buildQuickActionsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isTelemetryActive ? Icons.directions_car : Icons.car_repair,
                  color: _isTelemetryActive ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${_isTelemetryActive ? "Online" : "Offline"}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isTelemetryActive 
                            ? 'Disponível para entregas'
                            : 'Toque no GPS para ficar online',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Pedidos Ativos', '${_myOrders.length}', Colors.blue),
                _buildStatItem('Disponíveis', '${_availableOrders.length}', Colors.orange),
                _buildStatItem('Hoje', 'R\$ 125,50', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pedidos Disponíveis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_availableOrders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Nenhum pedido disponível no momento',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...(_availableOrders.map((order) => _buildAvailableOrderCard(order))),
      ],
    );
  }

  Widget _buildAvailableOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '#${order['id']} - ${order['priority']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'R\$ ${order['estimatedEarnings']?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['originAddress'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['destinationAddress'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order['distance']?.toStringAsFixed(1) ?? '0.0'} km • ${order['weight']?.toStringAsFixed(1) ?? '0.0'} kg',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _acceptOrder(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Aceitar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meus Pedidos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (_myOrders.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Você não tem pedidos ativos',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          )
        else
          ...(_myOrders.map((order) => _buildMyOrderCard(order))),
      ],
    );
  }

  Widget _buildMyOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'NEW';
    Color statusColor = Colors.grey;
    String statusText = status;
    
    switch (status) {
      case 'ASSIGNED':
        statusColor = Colors.orange;
        statusText = 'Aceito';
        break;
      case 'IN_TRANSIT':
        statusColor = Colors.blue;
        statusText = 'Em Trânsito';
        break;
      case 'DELIVERED':
        statusColor = Colors.green;
        statusText = 'Entregue';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order['id']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['originAddress'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.flag, size: 16, color: Colors.green),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order['destinationAddress'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailScreen(orderId: order['id']),
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Detalhes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black87,
                  ),
                ),
                if (status == 'IN_TRANSIT')
                  ElevatedButton.icon(
                    onPressed: () => _confirmDelivery(order),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Confirmar Entrega'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações Rápidas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Planejar Rota',
                    Icons.route,
                    Colors.orange,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoutePlanningScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Telemetria',
                    Icons.gps_fixed,
                    Colors.purple,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelemetryScreen(
                            telemetryService: _telemetryService,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Suporte',
                    Icons.support_agent,
                    Colors.teal,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Suporte: (11) 99999-0000'),
                          backgroundColor: Colors.teal,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Configurações',
                    Icons.settings,
                    Colors.grey,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configurações em desenvolvimento'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
