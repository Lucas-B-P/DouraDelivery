import 'package:flutter/material.dart';
import '../../services/order_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  double? _distance;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final order = await _orderService.getOrderById(widget.orderId);
      final distanceData = await _orderService.getOrderDistance(widget.orderId);

      setState(() {
        _order = order;
        _distance = distanceData?['distance']?.toDouble();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao carregar detalhes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    try {
      final response = await _orderService.updateOrderStatus(widget.orderId, newStatus);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadOrderDetails(); // Recarregar detalhes
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

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atualizar Status - Pedido #${widget.orderId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.new_releases, color: Colors.blue),
              title: const Text('Novo'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('NEW');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Colors.orange),
              title: const Text('Atribuído'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('ASSIGNED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.purple),
              title: const Text('Coletado'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('PICKED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping, color: Colors.amber),
              title: const Text('Em Trânsito'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('IN_TRANSIT');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Entregue'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('DELIVERED');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Cancelado'),
              onTap: () {
                Navigator.pop(context);
                _updateOrderStatus('CANCELED');
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

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Não informado';
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
        title: Text('📦 Pedido #${widget.orderId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_order != null)
            IconButton(
              onPressed: _showStatusUpdateDialog,
              icon: const Icon(Icons.edit),
              tooltip: 'Atualizar Status',
            ),
          IconButton(
            onPressed: _loadOrderDetails,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
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
                  Text('Carregando detalhes...'),
                ],
              ),
            )
          : _order == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pedido não encontrado',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Status Card
                      _buildInfoCard(
                        'Status do Pedido',
                        Icons.info,
                        Colors.blue,
                        [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _orderService.getStatusColor(_order!['status'] ?? 'NEW').withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _orderService.getStatusColor(_order!['status'] ?? 'NEW'),
                              ),
                            ),
                            child: Text(
                              _orderService.getStatusText(_order!['status'] ?? 'NEW'),
                              style: TextStyle(
                                color: _orderService.getStatusColor(_order!['status'] ?? 'NEW'),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow('Prioridade', _orderService.getPriorityText(_order!['priority'] ?? 'NORMAL')),
                          if (_distance != null)
                            _buildInfoRow('Distância', '${_distance!.toStringAsFixed(2)} km', icon: Icons.straighten),
                        ],
                      ),
                      
                      // Localização Card
                      _buildInfoCard(
                        'Localização',
                        Icons.location_on,
                        Colors.green,
                        [
                          _buildInfoRow(
                            'Origem',
                            _order!['originAddress'] ?? 'Não informado',
                            icon: Icons.my_location,
                          ),
                          if (_order!['originLat'] != null && _order!['originLon'] != null)
                            _buildInfoRow(
                              'Coordenadas',
                              '${_order!['originLat']}, ${_order!['originLon']}',
                            ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            'Destino',
                            _order!['destinationAddress'] ?? 'Não informado',
                            icon: Icons.flag,
                          ),
                          if (_order!['destinationLat'] != null && _order!['destinationLon'] != null)
                            _buildInfoRow(
                              'Coordenadas',
                              '${_order!['destinationLat']}, ${_order!['destinationLon']}',
                            ),
                        ],
                      ),
                      
                      // Detalhes da Carga Card
                      _buildInfoCard(
                        'Detalhes da Carga',
                        Icons.inventory,
                        Colors.orange,
                        [
                          _buildInfoRow(
                            'Peso',
                            '${_order!['weight'] ?? 0} kg',
                            icon: Icons.fitness_center,
                          ),
                          if (_order!['volume'] != null && _order!['volume'] > 0)
                            _buildInfoRow(
                              'Volume',
                              '${_order!['volume']} m³',
                              icon: Icons.all_inbox,
                            ),
                          if (_order!['description'] != null && _order!['description'].isNotEmpty)
                            _buildInfoRow(
                              'Descrição',
                              _order!['description'],
                              icon: Icons.description,
                            ),
                        ],
                      ),
                      
                      // Janela de Tempo Card
                      if (_order!['timeWindowStart'] != null || _order!['timeWindowEnd'] != null)
                        _buildInfoCard(
                          'Janela de Tempo',
                          Icons.schedule,
                          Colors.purple,
                          [
                            if (_order!['timeWindowStart'] != null)
                              _buildInfoRow(
                                'Início',
                                _formatDate(_order!['timeWindowStart']),
                                icon: Icons.access_time,
                              ),
                            if (_order!['timeWindowEnd'] != null)
                              _buildInfoRow(
                                'Fim',
                                _formatDate(_order!['timeWindowEnd']),
                                icon: Icons.access_time_filled,
                              ),
                          ],
                        ),
                      
                      // Informações do Cliente Card
                      if (_order!['client'] != null)
                        _buildInfoCard(
                          'Cliente',
                          Icons.person,
                          Colors.teal,
                          [
                            _buildInfoRow(
                              'Nome',
                              _order!['client']['name'] ?? 'Não informado',
                              icon: Icons.person,
                            ),
                            _buildInfoRow(
                              'Email',
                              _order!['client']['email'] ?? 'Não informado',
                              icon: Icons.email,
                            ),
                            if (_order!['client']['phone'] != null)
                              _buildInfoRow(
                                'Telefone',
                                _order!['client']['phone'],
                                icon: Icons.phone,
                              ),
                          ],
                        ),
                      
                      // Entregador Card
                      if (_order!['assignedDriver'] != null)
                        _buildInfoCard(
                          'Entregador',
                          Icons.local_shipping,
                          Colors.indigo,
                          [
                            _buildInfoRow(
                              'Nome',
                              _order!['assignedDriver']['name'] ?? 'Não informado',
                              icon: Icons.person,
                            ),
                            _buildInfoRow(
                              'Email',
                              _order!['assignedDriver']['email'] ?? 'Não informado',
                              icon: Icons.email,
                            ),
                            if (_order!['assignedDriver']['phone'] != null)
                              _buildInfoRow(
                                'Telefone',
                                _order!['assignedDriver']['phone'],
                                icon: Icons.phone,
                              ),
                          ],
                        ),
                      
                      // Datas Card
                      _buildInfoCard(
                        'Histórico',
                        Icons.history,
                        Colors.grey,
                        [
                          _buildInfoRow(
                            'Criado em',
                            _formatDate(_order!['createdAt']),
                            icon: Icons.add_circle,
                          ),
                          _buildInfoRow(
                            'Atualizado em',
                            _formatDate(_order!['updatedAt']),
                            icon: Icons.update,
                          ),
                          if (_order!['deliveredAt'] != null)
                            _buildInfoRow(
                              'Entregue em',
                              _formatDate(_order!['deliveredAt']),
                              icon: Icons.check_circle,
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
      floatingActionButton: _order != null
          ? FloatingActionButton.extended(
              onPressed: _showStatusUpdateDialog,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.edit),
              label: const Text('Atualizar Status'),
            )
          : null,
    );
  }
}
