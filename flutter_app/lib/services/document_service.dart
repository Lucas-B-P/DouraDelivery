import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class DocumentService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> uploadDocument(
    int userId,
    String documentType,
    File file,
  ) async {
    try {
      print('📤 Enviando documento: $documentType para usuário $userId');
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      // Criar FormData para upload
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: '${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiService.dio.post(
        '/api/documents/upload/$userId/$documentType',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ Upload realizado com sucesso!');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        throw Exception('Erro no upload: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro no upload:');
      print('   Tipo: ${e.type}');
      print('   Mensagem: ${e.message}');
      print('   Response: ${e.response?.data}');
      
      String errorMessage = 'Erro no upload do documento';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Erro inesperado no upload: $e');
      return {
        'success': false,
        'message': 'Erro inesperado: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getDocumentStatus(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      
      if (token == null) {
        throw Exception('Token não encontrado. Faça login novamente.');
      }

      final response = await _apiService.dio.get(
        '/api/documents/status/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        throw Exception('Erro ao buscar status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao buscar status dos documentos: ${e.message}');
      return {
        'success': false,
        'message': 'Erro ao buscar status dos documentos',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String userType,
    required String cpf,
    required DateTime birthDate,
    required String phone,
    String? cnhNumber,
    String? cnhCategory,
    DateTime? cnhExpiryDate,
  }) async {
    try {
      print('📝 Registrando usuário: $email');
      
      Map<String, dynamic> requestData = {
        'name': name,
        'email': email,
        'password': password,
        'userType': userType,
        'cpf': cpf,
        'birthDate': birthDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'phone': phone,
      };

      // Campos específicos para entregadores
      if (userType.toUpperCase() == 'DRIVER') {
        requestData.addAll({
          'cnhNumber': cnhNumber,
          'cnhCategory': cnhCategory,
          'cnhExpiryDate': cnhExpiryDate?.toIso8601String().split('T')[0],
        });
      }

      final response = await _apiService.dio.post(
        '/api/auth/register',
        data: requestData,
      );

      if (response.statusCode == 200) {
        print('✅ Registro realizado com sucesso!');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        throw Exception('Erro no registro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro no registro:');
      print('   Tipo: ${e.type}');
      print('   Mensagem: ${e.message}');
      print('   Response: ${e.response?.data}');
      
      String errorMessage = 'Erro no registro';
      if (e.response?.data != null && e.response!.data['message'] != null) {
        errorMessage = e.response!.data['message'];
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Erro inesperado no registro: $e');
      return {
        'success': false,
        'message': 'Erro inesperado: $e',
      };
    }
  }
}
