import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  
  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #${order['id']}'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Status',
              order['status'] ?? 'N/A',
              _getStatusColor(order['status']),
            ),
            SizedBox(height: 16),
            _buildInfoCard(
              'Prioridade',
              order['priority'] ?? 'NORMAL',
              _getPriorityColor(order['priority']),
            ),
            SizedBox(height: 16),
            _buildInfoCard(
              'Peso',
              '${order['weight']} kg',
              Colors.blue,
            ),
            SizedBox(height: 16),
            _buildSection('Origem', order['originAddress'] ?? 'N/A'),
            SizedBox(height: 16),
            _buildSection('Destino', order['destinationAddress'] ?? 'N/A'),
            if (order['description'] != null) ...[
              SizedBox(height: 16),
              _buildSection('Descrição', order['description']),
            ],
            if (order['assignedDriver'] != null) ...[
              SizedBox(height: 16),
              _buildSection('Entregador', order['assignedDriver']['user']['name'] ?? 'N/A'),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Chip(
              label: Text(value),
              backgroundColor: color.withOpacity(0.2),
              labelStyle: TextStyle(color: color),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection(String title, String content) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String? status) {
    switch (status) {
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
      default:
        return Colors.grey;
    }
  }
  
  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'EXPRESS':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'NORMAL':
        return Colors.blue;
      case 'LOW':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}

