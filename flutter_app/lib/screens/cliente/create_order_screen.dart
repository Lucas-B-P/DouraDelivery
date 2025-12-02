import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';

class CreateOrderScreen extends StatefulWidget {
  @override
  _CreateOrderScreenState createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originAddressController = TextEditingController();
  final _destinationAddressController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  double? _originLat;
  double? _originLon;
  double? _destinationLat;
  double? _destinationLon;
  String _priority = 'NORMAL';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Pedido')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _originAddressController,
                decoration: InputDecoration(
                  labelText: 'Endereço de Origem',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(Icons.location_on),
                label: Text('Usar Minha Localização'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _destinationAddressController,
                decoration: InputDecoration(
                  labelText: 'Endereço de Destino',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Peso (kg)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Obrigatório' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(),
                ),
                items: ['LOW', 'NORMAL', 'HIGH', 'EXPRESS']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Consumer<OrderProvider>(
                builder: (context, provider, _) {
                  return provider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _createOrder,
                          child: Text('Criar Pedido'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _originLat = position.latitude;
        _originLon = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Localização obtida!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }
  
  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_originLat == null || _originLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Obtenha sua localização primeiro')),
      );
      return;
    }
    
    final orderData = {
      'originLat': _originLat,
      'originLon': _originLon,
      'destinationLat': _destinationLat ?? -23.5505,
      'destinationLon': _destinationLon ?? -46.6333,
      'originAddress': _originAddressController.text,
      'destinationAddress': _destinationAddressController.text,
      'weight': double.parse(_weightController.text),
      'priority': _priority,
      'description': _descriptionController.text,
    };
    
    final provider = Provider.of<OrderProvider>(context, listen: false);
    await provider.createOrder(orderData);
    
    if (provider.error == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido criado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${provider.error}')),
      );
    }
  }
}

