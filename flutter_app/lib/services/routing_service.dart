import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:geolocator/geolocator.dart';

class RoutingService {
  static const double _earthRadius = 6371; // Raio da Terra em km

  /// Calcula a distância entre dois pontos usando a fórmula de Haversine
  static double calculateDistance(
    double lat1, double lon1, 
    double lat2, double lon2
  ) {
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return _earthRadius * c;
  }

  /// Converte graus para radianos
  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Calcula o tempo estimado de viagem baseado na distância
  static Duration calculateEstimatedTime(double distanceKm, {double averageSpeedKmh = 30}) {
    double timeHours = distanceKm / averageSpeedKmh;
    int timeMinutes = (timeHours * 60).round();
    return Duration(minutes: timeMinutes);
  }

  /// Otimiza a rota para múltiplas entregas usando algoritmo simples
  static List<RoutePoint> optimizeRoute(
    RoutePoint startPoint,
    List<RoutePoint> deliveryPoints,
    {RoutePoint? endPoint}
  ) {
    if (deliveryPoints.isEmpty) {
      return endPoint != null ? [startPoint, endPoint] : [startPoint];
    }

    List<RoutePoint> optimizedRoute = [startPoint];
    List<RoutePoint> remainingPoints = List.from(deliveryPoints);
    RoutePoint currentPoint = startPoint;

    // Algoritmo do vizinho mais próximo
    while (remainingPoints.isNotEmpty) {
      RoutePoint nearestPoint = remainingPoints.first;
      double shortestDistance = calculateDistance(
        currentPoint.latitude, currentPoint.longitude,
        nearestPoint.latitude, nearestPoint.longitude
      );

      for (RoutePoint point in remainingPoints) {
        double distance = calculateDistance(
          currentPoint.latitude, currentPoint.longitude,
          point.latitude, point.longitude
        );
        
        if (distance < shortestDistance) {
          shortestDistance = distance;
          nearestPoint = point;
        }
      }

      optimizedRoute.add(nearestPoint);
      remainingPoints.remove(nearestPoint);
      currentPoint = nearestPoint;
    }

    if (endPoint != null) {
      optimizedRoute.add(endPoint);
    }

    return optimizedRoute;
  }

  /// Calcula estatísticas da rota
  static RouteStatistics calculateRouteStatistics(List<RoutePoint> route) {
    if (route.length < 2) {
      return RouteStatistics(
        totalDistance: 0,
        estimatedTime: Duration.zero,
        numberOfStops: route.length,
      );
    }

    double totalDistance = 0;
    for (int i = 0; i < route.length - 1; i++) {
      totalDistance += calculateDistance(
        route[i].latitude, route[i].longitude,
        route[i + 1].latitude, route[i + 1].longitude
      );
    }

    return RouteStatistics(
      totalDistance: totalDistance,
      estimatedTime: calculateEstimatedTime(totalDistance),
      numberOfStops: route.length,
    );
  }

  /// Obtém a localização atual do dispositivo
  static Future<RoutePoint?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Serviço de localização desabilitado');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Permissão de localização negada');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissão de localização negada permanentemente');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return RoutePoint(
        latitude: position.latitude,
        longitude: position.longitude,
        address: 'Localização Atual',
        type: RoutePointType.current,
      );
    } catch (e) {
      print('Erro ao obter localização: $e');
      return null;
    }
  }

  /// Simula pontos de interesse em São Paulo para demonstração
  static List<RoutePoint> getSimulatedDeliveryPoints() {
    return [
      RoutePoint(
        latitude: -23.5505,
        longitude: -46.6333,
        address: 'Av. Paulista, 1000 - Bela Vista',
        type: RoutePointType.delivery,
        orderId: 101,
      ),
      RoutePoint(
        latitude: -23.5489,
        longitude: -46.6388,
        address: 'Rua Augusta, 500 - Consolação',
        type: RoutePointType.delivery,
        orderId: 102,
      ),
      RoutePoint(
        latitude: -23.5558,
        longitude: -46.6396,
        address: 'Rua dos Jardins, 200 - Jardins',
        type: RoutePointType.delivery,
        orderId: 103,
      ),
      RoutePoint(
        latitude: -23.5475,
        longitude: -46.6361,
        address: 'Rua Oscar Freire, 300 - Jardins',
        type: RoutePointType.delivery,
        orderId: 104,
      ),
    ];
  }

  /// Gera instruções de navegação simples
  static List<String> generateNavigationInstructions(List<RoutePoint> route) {
    List<String> instructions = [];
    
    if (route.isEmpty) return instructions;

    instructions.add('Iniciar rota em ${route.first.address}');

    for (int i = 1; i < route.length; i++) {
      RoutePoint current = route[i];
      RoutePoint previous = route[i - 1];
      
      double distance = calculateDistance(
        previous.latitude, previous.longitude,
        current.latitude, current.longitude
      );
      
      Duration time = calculateEstimatedTime(distance);
      
      String instruction = 'Siga para ${current.address} '
          '(${distance.toStringAsFixed(1)} km, ~${time.inMinutes} min)';
      
      if (current.type == RoutePointType.delivery) {
        instruction += ' - ENTREGA #${current.orderId}';
      }
      
      instructions.add(instruction);
    }

    return instructions;
  }
}

class RoutePoint {
  final double latitude;
  final double longitude;
  final String address;
  final RoutePointType type;
  final int? orderId;
  final String? description;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.type,
    this.orderId,
    this.description,
  });

  @override
  String toString() {
    return 'RoutePoint(lat: $latitude, lon: $longitude, address: $address, type: $type)';
  }
}

enum RoutePointType {
  start,
  current,
  delivery,
  pickup,
  end,
}

class RouteStatistics {
  final double totalDistance;
  final Duration estimatedTime;
  final int numberOfStops;

  RouteStatistics({
    required this.totalDistance,
    required this.estimatedTime,
    required this.numberOfStops,
  });

  @override
  String toString() {
    return 'RouteStatistics(distance: ${totalDistance.toStringAsFixed(1)} km, '
           'time: ${estimatedTime.inMinutes} min, stops: $numberOfStops)';
  }
}
