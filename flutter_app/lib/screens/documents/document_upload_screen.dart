import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../providers/auth_provider.dart';
import '../../services/document_service.dart';
import '../dashboard/user_dashboard_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  final String userType;
  final int userId;

  const DocumentUploadScreen({
    Key? key,
    required this.userType,
    required this.userId,
  }) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final DocumentService _documentService = DocumentService();
  final ImagePicker _picker = ImagePicker();
  
  File? _cpfDocument;
  File? _cnhDocument;
  File? _profilePhoto;
  File? _vehicleDocument;
  
  bool _isUploading = false;
  String? _uploadError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envio de Documentos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove botão voltar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com informações
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Documentação Necessária',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Para ativar sua conta, você precisa enviar os documentos abaixo. '
                      'Eles serão analisados pela nossa equipe em até 24 horas.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Documentos obrigatórios para todos
            _buildSectionTitle('Documentos Obrigatórios'),
            const SizedBox(height: 16),

            // CPF/RG
            _buildDocumentCard(
              title: 'CPF ou RG',
              description: kIsWeb ? 'Selecione uma imagem do documento' : 'Foto clara do documento de identidade',
              file: _cpfDocument,
              onTap: () => _pickDocument('cpf'),
              icon: Icons.credit_card,
            ),
            const SizedBox(height: 16),

            // Foto do perfil
            _buildDocumentCard(
              title: 'Foto do Perfil',
              description: kIsWeb ? 'Selecione uma foto sua' : 'Selfie clara para identificação',
              file: _profilePhoto,
              onTap: () => _pickDocument('profile'),
              icon: Icons.person,
            ),
            const SizedBox(height: 16),

            // Documentos específicos para entregadores
            if (widget.userType == 'DRIVER') ...[
              const SizedBox(height: 24),
              _buildSectionTitle('Documentos do Entregador'),
              const SizedBox(height: 16),

              // CNH
              _buildDocumentCard(
                title: 'CNH (Carteira de Habilitação)',
                description: 'Foto clara da CNH válida',
                file: _cnhDocument,
                onTap: () => _pickDocument('cnh'),
                icon: Icons.drive_eta,
                required: true,
              ),
              const SizedBox(height: 16),

              // Documento do veículo
              _buildDocumentCard(
                title: 'Documento do Veículo',
                description: 'CRLV ou documento do veículo',
                file: _vehicleDocument,
                onTap: () => _pickDocument('vehicle'),
                icon: Icons.motorcycle,
                required: true,
              ),
            ],

            const SizedBox(height: 32),

            // Botão de envio
            if (_uploadError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _uploadDocuments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isUploading
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
                          SizedBox(width: 8),
                          Text('Enviando...'),
                        ],
                      )
                    : const Text(
                        'Enviar Documentos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Botão pular (apenas para clientes)
            if (widget.userType == 'CLIENT')
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _skipDocuments,
                  child: const Text(
                    'Pular por agora (pode enviar depois)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDocumentCard({
    required String title,
    required String description,
    required File? file,
    required VoidCallback onTap,
    required IconData icon,
    bool required = false,
  }) {
    final bool hasFile = file != null;
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: hasFile ? Colors.green.shade100 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasFile ? Icons.check_circle : icon,
                  color: hasFile ? Colors.green.shade700 : Colors.grey.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (required)
                          const Text(
                            ' *',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (hasFile) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Documento selecionado ✓',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasFile ? Icons.edit : (kIsWeb ? Icons.upload_file : Icons.camera_alt),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDocument(String type) async {
    try {
      XFile? image;
      
      if (kIsWeb) {
        // No web, usar gallery ao invés de camera
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      } else {
        // No mobile, usar camera
        image = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
          maxWidth: 1920,
          maxHeight: 1080,
        );
      }

      if (image != null) {
        if (mounted) {
          setState(() {
            switch (type) {
              case 'cpf':
                _cpfDocument = File(image!.path);
                break;
              case 'profile':
                _profilePhoto = File(image!.path);
                break;
              case 'cnh':
                _cnhDocument = File(image!.path);
                break;
              case 'vehicle':
                _vehicleDocument = File(image!.path);
                break;
            }
            _uploadError = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadError = 'Erro ao selecionar imagem: $e';
        });
      }
    }
  }

  Future<void> _uploadDocuments() async {
    // Validar documentos obrigatórios
    if (_cpfDocument == null || _profilePhoto == null) {
      if (mounted) {
        setState(() {
          _uploadError = 'CPF/RG e foto do perfil são obrigatórios';
        });
      }
      return;
    }

    if (widget.userType == 'DRIVER' && (_cnhDocument == null || _vehicleDocument == null)) {
      if (mounted) {
        setState(() {
          _uploadError = 'CNH e documento do veículo são obrigatórios para entregadores';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isUploading = true;
        _uploadError = null;
      });
    }

    try {
      final response = await _documentService.uploadDocuments(
        userId: widget.userId,
        cpfDocument: _cpfDocument!,
        profilePhoto: _profilePhoto!,
        cnhDocument: _cnhDocument,
        vehicleDocument: _vehicleDocument,
      );

      if (response['success']) {
        // Mostrar sucesso e navegar para dashboard
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Documentos enviados com sucesso! Aguarde a análise.'),
              backgroundColor: Colors.green,
            ),
          );
          _navigateToDashboard();
        }
      } else {
        if (mounted) {
          setState(() {
            _uploadError = response['message'] ?? 'Erro ao enviar documentos';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadError = 'Erro ao enviar documentos: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _skipDocuments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pular Documentação'),
        content: const Text(
          'Você pode enviar os documentos depois através do seu perfil. '
          'Algumas funcionalidades podem estar limitadas até a verificação.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToDashboard();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const UserDashboardScreen(),
      ),
      (route) => false,
    );
  }
}
