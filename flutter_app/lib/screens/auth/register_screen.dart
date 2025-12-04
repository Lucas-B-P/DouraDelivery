import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import '../services/document_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocumentService _documentService = DocumentService();
  final ImagePicker _picker = ImagePicker();

  // Controladores dos campos
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cnhController = TextEditingController();

  // Estados
  bool _isLoading = false;
  String _userType = 'CLIENT';
  DateTime? _birthDate;
  DateTime? _cnhExpiryDate;
  String? _cnhCategory;
  File? _profilePhoto;
  File? _cpfPhoto;
  File? _cnhPhoto;
  int _currentStep = 0;

  final List<String> _cnhCategories = ['A', 'B', 'C', 'D', 'E', 'AB', 'AC', 'AD', 'AE'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('Voltar'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (details.stepIndex == 2) {
                      _submitRegistration();
                    } else {
                      details.onStepContinue?.call();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(details.stepIndex == 2 ? 'Finalizar' : 'Próximo'),
                ),
              ],
            );
          },
          steps: [
            Step(
              title: const Text('Dados Pessoais'),
              content: _buildPersonalDataStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Documentos'),
              content: _buildDocumentsStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Fotos dos Documentos'),
              content: _buildPhotosStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataStep() {
    return Column(
      children: [
        // Tipo de usuário
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tipo de Conta',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Cliente'),
                        value: 'CLIENT',
                        groupValue: _userType,
                        onChanged: (value) => setState(() => _userType = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Entregador'),
                        value: 'DRIVER',
                        groupValue: _userType,
                        onChanged: (value) => setState(() => _userType = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Campos básicos
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().length < 2) {
              return 'Nome deve ter pelo menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || !value.contains('@')) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Senha *',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar Senha *',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Senhas não coincidem';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: [
        // CPF
        TextFormField(
          controller: _cpfController,
          decoration: const InputDecoration(
            labelText: 'CPF *',
            border: OutlineInputBorder(),
            hintText: '000.000.000-00',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _CpfInputFormatter(),
          ],
          validator: (value) {
            if (value == null || !CPFValidator.isValid(value)) {
              return 'CPF inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Data de nascimento
        InkWell(
          onTap: _selectBirthDate,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Data de Nascimento *',
              border: OutlineInputBorder(),
            ),
            child: Text(
              _birthDate != null
                  ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                  : 'Selecione a data',
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Telefone
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefone *',
            border: OutlineInputBorder(),
            hintText: '(00) 00000-0000',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneInputFormatter(),
          ],
          validator: (value) {
            if (value == null || value.replaceAll(RegExp(r'[^\d]'), '').length < 10) {
              return 'Telefone inválido';
            }
            return null;
          },
        ),

        // Campos específicos para entregadores
        if (_userType == 'DRIVER') ...[
          const SizedBox(height: 24),
          const Divider(),
          const Text(
            'Dados da CNH (Obrigatório para Entregadores)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _cnhController,
            decoration: const InputDecoration(
              labelText: 'Número da CNH *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (_userType == 'DRIVER' && (value == null || value.length != 11)) {
                return 'CNH deve ter 11 dígitos';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _cnhCategory,
            decoration: const InputDecoration(
              labelText: 'Categoria da CNH *',
              border: OutlineInputBorder(),
            ),
            items: _cnhCategories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text('Categoria $category'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _cnhCategory = value),
            validator: (value) {
              if (_userType == 'DRIVER' && value == null) {
                return 'Selecione a categoria da CNH';
              }
              if (_userType == 'DRIVER' && !['A', 'AB', 'AC', 'AD', 'AE'].contains(value)) {
                return 'Entregadores devem ter CNH categoria A';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: _selectCnhExpiryDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Validade da CNH *',
                border: OutlineInputBorder(),
              ),
              child: Text(
                _cnhExpiryDate != null
                    ? '${_cnhExpiryDate!.day.toString().padLeft(2, '0')}/${_cnhExpiryDate!.month.toString().padLeft(2, '0')}/${_cnhExpiryDate!.year}'
                    : 'Selecione a validade',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotosStep() {
    return Column(
      children: [
        const Text(
          'Envie fotos dos seus documentos para verificação',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Foto do perfil
        _buildPhotoUpload(
          title: 'Foto do Perfil',
          description: 'Tire uma selfie ou envie uma foto sua',
          photo: _profilePhoto,
          onTap: () => _takePhoto('profile'),
        ),
        const SizedBox(height: 16),

        // Foto do CPF
        _buildPhotoUpload(
          title: 'Foto do CPF',
          description: 'Foto do documento de CPF (frente)',
          photo: _cpfPhoto,
          onTap: () => _takePhoto('cpf'),
        ),

        // Foto da CNH (apenas para entregadores)
        if (_userType == 'DRIVER') ...[
          const SizedBox(height: 16),
          _buildPhotoUpload(
            title: 'Foto da CNH',
            description: 'Foto da Carteira Nacional de Habilitação (frente)',
            photo: _cnhPhoto,
            onTap: () => _takePhoto('cnh'),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoUpload({
    required String title,
    required String description,
    required File? photo,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: photo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          photo,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (photo != null) ...[
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Foto adicionada',
                            style: TextStyle(color: Colors.green, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _takePhoto(String documentType) async {
    // Solicitar permissões
    final cameraPermission = await Permission.camera.request();
    if (!cameraPermission.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissão de câmera necessária')),
      );
      return;
    }

    // Mostrar opções: câmera ou galeria
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (documentType) {
            case 'profile':
              _profilePhoto = File(image.path);
              break;
            case 'cpf':
              _cpfPhoto = File(image.path);
              break;
            case 'cnh':
              _cnhPhoto = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao capturar foto: $e')),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final date = await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1924),
      maxTime: DateTime.now().subtract(const Duration(days: 365 * 18)),
      currentTime: _birthDate ?? DateTime(2000),
      locale: LocaleType.pt,
    );

    if (date != null) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _selectCnhExpiryDate() async {
    final date = await DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime.now(),
      maxTime: DateTime.now().add(const Duration(days: 365 * 20)),
      currentTime: _cnhExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
      locale: LocaleType.pt,
    );

    if (date != null) {
      setState(() => _cnhExpiryDate = date);
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar data de nascimento
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione sua data de nascimento')),
      );
      return;
    }

    // Validar fotos obrigatórias
    if (_profilePhoto == null || _cpfPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto do perfil e CPF são obrigatórias')),
      );
      return;
    }

    if (_userType == 'DRIVER') {
      if (_cnhExpiryDate == null || _cnhPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados da CNH são obrigatórios para entregadores')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // 1. Registrar usuário
      final registerResult = await _documentService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        userType: _userType,
        cpf: _cpfController.text.replaceAll(RegExp(r'[^\d]'), ''),
        birthDate: _birthDate!,
        phone: _phoneController.text.replaceAll(RegExp(r'[^\d]'), ''),
        cnhNumber: _userType == 'DRIVER' ? _cnhController.text : null,
        cnhCategory: _userType == 'DRIVER' ? _cnhCategory : null,
        cnhExpiryDate: _userType == 'DRIVER' ? _cnhExpiryDate : null,
      );

      if (!registerResult['success']) {
        throw Exception(registerResult['message']);
      }

      final userId = registerResult['data']['userId'];

      // 2. Upload das fotos
      await _uploadPhoto(userId, 'profile', _profilePhoto!);
      await _uploadPhoto(userId, 'cpf', _cpfPhoto!);
      
      if (_userType == 'DRIVER' && _cnhPhoto != null) {
        await _uploadPhoto(userId, 'cnh', _cnhPhoto!);
      }

      // 3. Sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso! Aguarde a verificação dos documentos.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadPhoto(int userId, String documentType, File photo) async {
    final result = await _documentService.uploadDocument(userId, documentType, photo);
    if (!result['success']) {
      throw Exception('Erro no upload da foto: ${result['message']}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _cnhController.dispose();
    super.dispose();
  }
}

// Formatadores personalizados
class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';
    
    for (int i = 0; i < text.length && i < 11; i++) {
      if (i == 3 || i == 6) formatted += '.';
      if (i == 9) formatted += '-';
      formatted += text[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    String formatted = '';
    
    if (text.isNotEmpty) {
      formatted += '(';
      for (int i = 0; i < text.length && i < 11; i++) {
        if (i == 2) formatted += ') ';
        if (i == 7 && text.length > 10) formatted += '-';
        if (i == 6 && text.length <= 10) formatted += '-';
        formatted += text[i];
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
