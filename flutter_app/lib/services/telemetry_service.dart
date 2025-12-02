import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_service.dart';

class TelemetryService {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  bool _isRunning = false;
  
  Future<void> start() async {
    if (_isRunning) return;
    
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
    
    _isRunning = true;
    
    _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        
        await _apiService.dio.post('/api/entregador/telemetria', data: {
          'lat': position.latitude,
          'lon': position.longitude,
          'speed': position.speed * 3.6,
          'heading': position.heading,
          'accuracy': position.accuracy,
        });
      } catch (e) {
        print('Erro ao enviar telemetria: $e');
      }
    });
  }
  
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }
  
  bool get isRunning => _isRunning;
}

