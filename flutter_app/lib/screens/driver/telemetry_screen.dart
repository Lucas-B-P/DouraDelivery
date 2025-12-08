import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/telemetry_service.dart';

class TelemetryScreen extends StatefulWidget {
  final TelemetryService telemetryService;

  const TelemetryScreen({Key? key, required this.telemetryService}) : super(key: key);

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  Timer? _updateTimer;
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _updateStatistics();
    
    // Atualizar estatísticas a cada 2 segundos
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateStatistics();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateStatistics() {
    setState(() {
      _statistics = widget.telemetryService.getSessionStatistics();
    });
  }

  Future<void> _toggleTelemetry() async {
    try {
      if (widget.telemetryService.isRunning) {
        widget.telemetryService.stop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Telemetria desativada'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await widget.telemetryService.start();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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

  Future<void> _syncPendingData() async {
    try {
      await widget.telemetryService.syncPendingTelemetry();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados sincronizados com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _statistics['isActive'] ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetria GPS'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isActive ? Icons.gps_fixed : Icons.gps_off),
            onPressed: _toggleTelemetry,
            tooltip: isActive ? 'Desativar GPS' : 'Ativar GPS',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(isActive),
            const SizedBox(height: 16),
            _buildStatisticsCard(),
            const SizedBox(height: 16),
            _buildLocationCard(),
            const SizedBox(height: 16),
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isActive) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.gps_fixed : Icons.gps_off,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: ${isActive ? "Ativo" : "Inativo"}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isActive 
                        ? 'Coletando dados de localização'
                        : 'Telemetria desativada',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _toggleTelemetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(isActive ? 'Parar' : 'Iniciar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final duration = _statistics['duration'] ?? 0;
    final distance = _statistics['distance'] ?? 0.0;
    final averageSpeed = _statistics['averageSpeed'] ?? 0.0;
    final currentSpeed = _statistics['currentSpeed'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas da Sessão',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Duração',
                    '${duration} min',
                    Icons.access_time,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Distância',
                    '${distance.toStringAsFixed(2)} km',
                    Icons.straighten,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Vel. Média',
                    '${averageSpeed.toStringAsFixed(1)} km/h',
                    Icons.speed,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Vel. Atual',
                    '${currentSpeed.toStringAsFixed(1)} km/h',
                    Icons.navigation,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final lastPosition = widget.telemetryService.lastPosition;
    final lastUpdate = _statistics['lastUpdate'];
    final positionCount = _statistics['positionCount'] ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Localização Atual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (lastPosition != null) ...[
              _buildLocationItem(
                'Latitude',
                lastPosition.latitude.toStringAsFixed(6),
                Icons.location_on,
              ),
              _buildLocationItem(
                'Longitude',
                lastPosition.longitude.toStringAsFixed(6),
                Icons.location_on,
              ),
              _buildLocationItem(
                'Precisão',
                '${lastPosition.accuracy.toStringAsFixed(1)} m',
                Icons.my_location,
              ),
              _buildLocationItem(
                'Altitude',
                '${lastPosition.altitude.toStringAsFixed(1)} m',
                Icons.height,
              ),
            ] else
              const Text(
                'Nenhuma localização disponível',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pontos coletados: $positionCount',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (lastUpdate != null)
                  Text(
                    'Última atualização: ${_formatTime(lastUpdate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _syncPendingData,
                icon: const Icon(Icons.sync),
                label: const Text('Sincronizar Dados Pendentes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showHistoryDialog();
                },
                icon: const Icon(Icons.history),
                label: const Text('Ver Histórico de Posições'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog() {
    final history = widget.telemetryService.positionHistory;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Histórico de Posições (${history.length})'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: history.isEmpty
              ? const Center(
                  child: Text('Nenhuma posição no histórico'),
                )
              : ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final position = history[index];
                    final time = DateTime.fromMillisecondsSinceEpoch(
                      position.timestamp.millisecondsSinceEpoch,
                    );
                    
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      title: Text(
                        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      subtitle: Text(
                        '${_formatTime(time)} - ${(position.speed * 3.6).toStringAsFixed(1)} km/h',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
           '${dateTime.minute.toString().padLeft(2, '0')}:'
           '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
