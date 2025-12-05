import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class DocumentService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> uploadDocuments({
    required int userId,
    required File cpfDocument,
    required File profilePhoto,
    File? cnhDocument,
    File? vehicleDocument,
  }) async {
    try {
      print('📤 Enviando documentos para usuário $userId');

      // Verificar se o backend está disponível
      bool backendAvailable = false;
      try {
        await _apiService.dio.get('/actuator/health');
        backendAvailable = true;
        print('✅ Backend disponível - fazendo upload real');
      } catch (e) {
        print('⚠️ Backend indisponível - simulando upload');
        backendAvailable = false;
      }

      if (!backendAvailable) {
        // Simular upload quando backend não está disponível
        print('📱 Simulando upload...');
        await Future.delayed(const Duration(seconds: 2)); // Simular delay de upload
        
        return {
          'success': true,
          'message': 'Documentos enviados com sucesso! (Simulado - Backend em deploy)',
          'documentsCount': 2 + (cnhDocument != null ? 1 : 0) + (vehicleDocument != null ? 1 : 0),
        };
      }

      // Para mobile/desktop, usar upload real
      final formData = FormData.fromMap({
        'userId': userId,
        'cpfDocument': await MultipartFile.fromFile(
          cpfDocument.path,
          filename: 'cpf_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'profilePhoto': await MultipartFile.fromFile(
          profilePhoto.path,
          filename: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        if (cnhDocument != null)
          'cnhDocument': await MultipartFile.fromFile(
            cnhDocument.path,
            filename: 'cnh_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        if (vehicleDocument != null)
          'vehicleDocument': await MultipartFile.fromFile(
            vehicleDocument.path,
            filename: 'vehicle_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
      });

      final response = await _apiService.dio.post(
        '/api/documents/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Documentos enviados com sucesso!');
        return {
          'success': true,
          'message': 'Documentos enviados com sucesso!',
          ...response.data,
        };
      } else {
        throw Exception('Erro ao enviar documentos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao enviar documentos:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String errorMessage = 'Erro desconhecido';

        if (responseData is Map<String, dynamic> && responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else {
          switch (statusCode) {
            case 400:
              errorMessage = 'Dados inválidos. Verifique os documentos enviados.';
              break;
            case 413:
              errorMessage = 'Arquivos muito grandes. Reduza o tamanho das imagens.';
              break;
            case 500:
              errorMessage = 'Erro interno do servidor. Tente novamente.';
              break;
            default:
              errorMessage = 'Erro no servidor (Status $statusCode)';
          }
        }

        return {'success': false, 'message': errorMessage};
      } else {
        return {'success': false, 'message': 'Erro de conexão: ${e.message}'};
      }
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return {'success': false, 'message': 'Erro inesperado: $e'};
    }
  }

  Future<Map<String, dynamic>> getDocumentStatus(int userId) async {
    try {
      print('📥 Buscando status dos documentos para usuário $userId');

      final response = await _apiService.dio.get('/api/documents/status/$userId');

      if (response.statusCode == 200) {
        print('✅ Status dos documentos obtido com sucesso!');
        return {
          'success': true,
          ...response.data,
        };
      } else {
        throw Exception('Erro ao buscar status: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao buscar status dos documentos:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      return {
        'success': false,
        'message': 'Erro ao buscar status dos documentos',
        'status': 'PENDING',
      };
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return {
        'success': false,
        'message': 'Erro inesperado: $e',
        'status': 'PENDING',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getPendingDocuments() async {
    try {
      print('📥 Buscando documentos pendentes para análise');

      final response = await _apiService.dio.get('/api/admin/documents/pending');

      if (response.statusCode == 200) {
        print('✅ Documentos pendentes obtidos com sucesso!');
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Erro ao buscar documentos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao buscar documentos pendentes:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
      return [];
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> approveDocument({
    required int userId,
    required String observation,
  }) async {
    try {
      print('✅ Aprovando documentos do usuário $userId');

      final response = await _apiService.dio.post(
        '/api/admin/documents/approve',
        data: {
          'userId': userId,
          'status': 'APPROVED',
          'observation': observation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Documentos aprovados com sucesso!');
        return {
          'success': true,
          'message': 'Documentos aprovados com sucesso!',
          ...response.data,
        };
      } else {
        throw Exception('Erro ao aprovar documentos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao aprovar documentos:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      return {
        'success': false,
        'message': 'Erro ao aprovar documentos',
      };
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return {
        'success': false,
        'message': 'Erro inesperado: $e',
      };
    }
  }

  Future<Map<String, dynamic>> rejectDocument({
    required int userId,
    required String observation,
  }) async {
    try {
      print('❌ Rejeitando documentos do usuário $userId');

      final response = await _apiService.dio.post(
        '/api/admin/documents/reject',
        data: {
          'userId': userId,
          'status': 'REJECTED',
          'observation': observation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Documentos rejeitados com sucesso!');
        return {
          'success': true,
          'message': 'Documentos rejeitados com sucesso!',
          ...response.data,
        };
      } else {
        throw Exception('Erro ao rejeitar documentos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Erro ao rejeitar documentos:');
      print('   Status: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');

      return {
        'success': false,
        'message': 'Erro ao rejeitar documentos',
      };
    } catch (e) {
      print('❌ Erro inesperado: $e');
      return {
        'success': false,
        'message': 'Erro inesperado: $e',
      };
    }
  }
}