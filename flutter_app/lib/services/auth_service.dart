import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔗 Conectando em: ${ApiService.baseUrl}/api/auth/login');
      
      final response = await _apiService.dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erro ao fazer login: Status ${response.statusCode}');
      }
      
      final data = response.data;
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('jwt_token', data['token']);
      await prefs.setString('user_type', data['userType']);
      await prefs.setInt('user_id', data['userId']);
      await prefs.setString('user_name', data['name']);
      
      print('✅ Login bem-sucedido!');
      return data;
    } on DioException catch (e) {
      print('❌ Erro de conexão:');
      print('   Tipo: ${e.type}');
      print('   Mensagem: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Timeout: Backend não respondeu. Verifique se está rodando.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Erro de conexão: Não foi possível conectar ao backend. Verifique a URL.');
      } else if (e.response != null) {
        throw Exception('Erro ${e.response!.statusCode}: ${e.response!.data ?? e.message}');
      } else {
        throw Exception('Erro de rede: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
  
  Future<Map<String, dynamic>> register(Map<String, dynamic> registerData) async {
    try {
      print('🔗 Registrando usuário em: ${ApiService.baseUrl}/api/auth/register');
      
      final response = await _apiService.dio.post('/api/auth/register', data: registerData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Registro bem-sucedido!');
        return response.data;
      } else {
        throw Exception('Erro ao registrar: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro de registro:');
      print('   Tipo: ${e.type}');
      print('   Mensagem: ${e.message}');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      
      if (e.response != null && e.response!.data != null) {
        return e.response!.data;
      } else {
        return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
      }
    } catch (e) {
      print('❌ Erro inesperado no registro: $e');
      return {'success': false, 'message': 'Erro inesperado: $e'};
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_type');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
  }
  
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('jwt_token');
  }
  
  Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }
  
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }
}

