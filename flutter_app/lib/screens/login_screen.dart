import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DouraDelivery - Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining, size: 80, color: Colors.blue),
              SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Email obrigatório' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value?.isEmpty ?? true ? 'Senha obrigatória' : null,
              ),
              SizedBox(height: 24),
              Consumer<AuthProvider>(
                builder: (context, provider, _) {
                  return provider.isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: Text('Entrar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            backgroundColor: Colors.blue,
                          ),
                        );
                },
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text(
                  'Não tem conta? Cadastre-se aqui',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Para testes, use qualquer email/senha',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    final provider = Provider.of<AuthProvider>(context, listen: false);
    await provider.login(_emailController.text, _passwordController.text);
    
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Navegar para o dashboard correto baseado no tipo de usuário
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => provider.getDashboardScreen(),
        ),
      );
    }
  }
}

