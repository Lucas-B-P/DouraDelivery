import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/auth/simple_register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cliente/create_order_screen.dart';
import 'screens/cliente/cliente_orders_screen.dart';
import 'screens/entregador/entregador_orders_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'DouraDelivery',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: AuthCheck(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => SimpleRegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/cliente/create-order': (context) => CreateOrderScreen(),
          '/cliente/orders': (context) => ClienteOrdersScreen(),
          '/entregador/orders': (context) => EntregadorOrdersScreen(),
        },
      ),
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: Provider.of<AuthProvider>(context, listen: false).checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.data == true) {
          return HomeScreen();
        }
        
        return LoginScreen();
      },
    );
  }
}

