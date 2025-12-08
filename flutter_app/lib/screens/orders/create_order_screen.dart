import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();
  
  // Controllers
  final _originAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _weightController = TextEditingController();
  final _volumeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Dados do pedido
  double? _originLat;
  double? _originLon;
  double? _destinationLat;
  double? _destinationLon;
  String _priority = 'NORMAL';
  DateTime? _timeWindowStart;
  DateTime? _timeWindowEnd;
  
  bool _isLoading = false;
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _originAddressController.dispose();
    _destinationAddressController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Verificar permissões
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

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _originLat = position.latitude;
        _originLon = position.longitude;
        _originAddressController.text = 'Localização atual (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Localização atual obtida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao obter localização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _selectDateTime(bool isStart) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStart) {
            _timeWindowStart = dateTime;
          } else {
            _timeWindowEnd = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_originLat == null || _originLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor, defina a localização de origem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_destinationLat == null || _destinationLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Por favor, defina a localização de destino'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = await authProvider.authService.getUserId();

      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final response = await _orderService.createOrder(
        clientId: userId,
        originLat: _originLat!,
        originLon: _originLon!,
        destinationLat: _destinationLat!,
        destinationLon: _destinationLon!,
        originAddress: _originAddressController.text,
        destinationAddress: _destinationAddressController.text,
        weight: double.parse(_weightController.text),
        volume: _volumeController.text.isNotEmpty ? double.parse(_volumeController.text) : 0.0,
        priority: _priority,
        description: _descriptionController.text,
        timeWindowStart: _timeWindowStart,
        timeWindowEnd: _timeWindowEnd,
      );

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Pedido criado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${response['message'] ?? 'Erro ao criar pedido'}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Criar Pedido'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Origem
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.my_location, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Origem',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _isGettingLocation ? null : _getCurrentLocation,
                            icon: _isGettingLocation 
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.gps_fixed),
                            label: Text(_isGettingLocation ? 'Obtendo...' : 'GPS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _originAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço de origem',
                          hintText: 'Digite o endereço ou use o GPS',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Endereço de origem é obrigatório';
                          }
                          return null;
                        },
                        onTap: () {
                          // Aqui você pode implementar busca de endereço
                          // Por enquanto, permite entrada manual
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Card de Destino
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Destino',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _destinationAddressController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço de destino',
                          hintText: 'Digite o endereço de destino',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Endereço de destino é obrigatório';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Simulação de coordenadas para destino
                          // Em um app real, você usaria geocoding
                          if (value.isNotEmpty && _originLat != null && _originLon != null) {
                            setState(() {
                              _destinationLat = _originLat! + 0.01; // Simulação
                              _destinationLon = _originLon! + 0.01;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Card de Detalhes
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Detalhes do Pedido',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Peso
                      TextFormField(
                        controller: _weightController,
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          hintText: 'Ex: 2.5',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fitness_center),
                          suffixText: 'kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Peso é obrigatório';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Digite um peso válido';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Volume
                      TextFormField(
                        controller: _volumeController,
                        decoration: const InputDecoration(
                          labelText: 'Volume (m³) - Opcional',
                          hintText: 'Ex: 0.5',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.all_inbox),
                          suffixText: 'm³',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Prioridade
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Prioridade',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'LOW', child: Text('🟢 Baixa')),
                          DropdownMenuItem(value: 'NORMAL', child: Text('🟡 Normal')),
                          DropdownMenuItem(value: 'HIGH', child: Text('🟠 Alta')),
                          DropdownMenuItem(value: 'EXPRESS', child: Text('🔴 Expressa')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _priority = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Descrição
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descrição - Opcional',
                          hintText: 'Descreva o conteúdo ou instruções especiais',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Card de Janela de Tempo
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Janela de Tempo - Opcional',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: const Text('Início'),
                              subtitle: Text(
                                _timeWindowStart != null
                                    ? '${_timeWindowStart!.day}/${_timeWindowStart!.month} ${_timeWindowStart!.hour}:${_timeWindowStart!.minute.toString().padLeft(2, '0')}'
                                    : 'Não definido',
                              ),
                              leading: const Icon(Icons.access_time),
                              onTap: () => _selectDateTime(true),
                            ),
                          ),
                          Expanded(
                            child: ListTile(
                              title: const Text('Fim'),
                              subtitle: Text(
                                _timeWindowEnd != null
                                    ? '${_timeWindowEnd!.day}/${_timeWindowEnd!.month} ${_timeWindowEnd!.hour}:${_timeWindowEnd!.minute.toString().padLeft(2, '0')}'
                                    : 'Não definido',
                              ),
                              leading: const Icon(Icons.access_time_filled),
                              onTap: () => _selectDateTime(false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botão de Criar Pedido
              ElevatedButton(
                onPressed: _isLoading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Criando Pedido...'),
                        ],
                      )
                    : const Text(
                        '📦 Criar Pedido',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
