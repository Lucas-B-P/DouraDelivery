import 'package:flutter/material.dart';
import '../../services/routing_service.dart';

class RoutePlanningScreen extends StatefulWidget {
  const RoutePlanningScreen({Key? key}) : super(key: key);

  @override
  State<RoutePlanningScreen> createState() => _RoutePlanningScreenState();
}

class _RoutePlanningScreenState extends State<RoutePlanningScreen> {
  List<RoutePoint> _deliveryPoints = [];
  List<RoutePoint> _optimizedRoute = [];
  RouteStatistics? _routeStatistics;
  RoutePoint? _currentLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeliveryPoints();
  }

  void _loadDeliveryPoints() {
    setState(() {
      _deliveryPoints = RoutingService.getSimulatedDeliveryPoints();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final location = await RoutingService.getCurrentLocation();
      if (location != null) {
        setState(() {
          _currentLocation = location;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Localização atual obtida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Não foi possível obter a localização');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter localização: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Usar localização simulada como fallback
      setState(() {
        _currentLocation = RoutePoint(
          latitude: -23.5505,
          longitude: -46.6333,
          address: 'Centro de São Paulo (Simulado)',
          type: RoutePointType.current,
        );
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _optimizeRoute() {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obtenha sua localização atual primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _optimizedRoute = RoutingService.optimizeRoute(
        _currentLocation!,
        _deliveryPoints,
      );
      _routeStatistics = RoutingService.calculateRouteStatistics(_optimizedRoute);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rota otimizada com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startNavigation() {
    if (_optimizedRoute.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Otimize a rota primeiro'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(route: _optimizedRoute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planejamento de Rota'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  _buildDeliveryPointsSection(),
                  const SizedBox(height: 16),
                  if (_optimizedRoute.isNotEmpty) _buildOptimizedRouteSection(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationCard() {
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
            const SizedBox(height: 8),
            if (_currentLocation != null)
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_currentLocation!.address),
                  ),
                ],
              )
            else
              const Text(
                'Localização não obtida',
                style: TextStyle(color: Colors.grey),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Obter Localização Atual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPointsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entregas Pendentes (${_deliveryPoints.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_deliveryPoints.map((point) => _buildDeliveryPointItem(point))),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryPointItem(RoutePoint point) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${point.orderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  point.address,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedRouteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rota Otimizada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_routeStatistics != null) _buildRouteStatistics(),
            const SizedBox(height: 12),
            ...(_optimizedRoute.asMap().entries.map((entry) {
              int index = entry.key;
              RoutePoint point = entry.value;
              return _buildRouteStepItem(point, index + 1);
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteStatistics() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Distância',
            '${_routeStatistics!.totalDistance.toStringAsFixed(1)} km',
            Icons.straighten,
          ),
          _buildStatItem(
            'Tempo Est.',
            '${_routeStatistics!.estimatedTime.inMinutes} min',
            Icons.access_time,
          ),
          _buildStatItem(
            'Paradas',
            '${_routeStatistics!.numberOfStops}',
            Icons.flag,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
    );
  }

  Widget _buildRouteStepItem(RoutePoint point, int stepNumber) {
    IconData icon;
    Color color;
    String prefix;

    switch (point.type) {
      case RoutePointType.current:
        icon = Icons.my_location;
        color = Colors.blue;
        prefix = 'INÍCIO';
        break;
      case RoutePointType.delivery:
        icon = Icons.location_on;
        color = Colors.red;
        prefix = 'ENTREGA #${point.orderId}';
        break;
      default:
        icon = Icons.flag;
        color = Colors.green;
        prefix = 'PARADA';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stepNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prefix,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 12,
                  ),
                ),
                Text(
                  point.address,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _optimizeRoute,
            icon: const Icon(Icons.route),
            label: const Text('Otimizar Rota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _optimizedRoute.isNotEmpty ? _startNavigation : null,
            icon: const Icon(Icons.navigation),
            label: const Text('Iniciar Navegação'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class NavigationScreen extends StatelessWidget {
  final List<RoutePoint> route;

  const NavigationScreen({Key? key, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final instructions = RoutingService.generateNavigationInstructions(route);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegação'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: instructions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(instructions[index]),
              trailing: index == 0 
                  ? const Icon(Icons.play_arrow, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navegação iniciada! Siga as instruções.'),
                backgroundColor: Colors.green,
              ),
            );
          },
          icon: const Icon(Icons.navigation),
          label: const Text('Iniciar Navegação'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }
}
