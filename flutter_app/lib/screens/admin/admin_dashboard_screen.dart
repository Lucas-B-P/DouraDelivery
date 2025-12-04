import 'package:flutter/material.dart';
import '../../services/document_service.dart';
import '../auth/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DocumentService _documentService = DocumentService();
  List<Map<String, dynamic>> _pendingDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingDocuments();
  }

  Future<void> _loadPendingDocuments() async {
    setState(() {
      _isLoading = true;
    });

    final documents = await _documentService.getPendingDocuments();
    setState(() {
      _pendingDocuments = documents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingDocuments,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPendingDocuments,
              child: _pendingDocuments.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum documento pendente!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Todos os documentos foram analisados.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pendingDocuments.length,
                      itemBuilder: (context, index) {
                        final document = _pendingDocuments[index];
                        return _buildDocumentCard(document);
                      },
                    ),
            ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    final userName = document['userName'] ?? 'Usuário';
    final userType = document['userType'] ?? 'CLIENT';
    final userId = document['userId'];
    final submittedAt = document['submittedAt'];
    final documents = document['documents'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header do usuário
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: userType == 'DRIVER' 
                      ? Colors.blue.shade100 
                      : Colors.green.shade100,
                  child: Icon(
                    userType == 'DRIVER' ? Icons.delivery_dining : Icons.person,
                    color: userType == 'DRIVER' 
                        ? Colors.blue.shade700 
                        : Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userType == 'DRIVER' ? 'Entregador' : 'Cliente',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      if (submittedAt != null)
                        Text(
                          'Enviado em: ${_formatDate(submittedAt)}',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PENDENTE',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Lista de documentos
            const Text(
              'Documentos Enviados:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...documents.map((doc) => _buildDocumentItem(doc)).toList(),
            
            const SizedBox(height: 16),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showRejectDialog(userId, userName),
                    icon: const Icon(Icons.close),
                    label: const Text('Rejeitar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(userId, userName),
                    icon: const Icon(Icons.check),
                    label: const Text('Aprovar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> doc) {
    final type = doc['type'] ?? '';
    final fileName = doc['fileName'] ?? '';
    
    String displayName;
    IconData icon;
    
    switch (type) {
      case 'CPF':
        displayName = 'CPF/RG';
        icon = Icons.credit_card;
        break;
      case 'PROFILE':
        displayName = 'Foto do Perfil';
        icon = Icons.person;
        break;
      case 'CNH':
        displayName = 'CNH';
        icon = Icons.drive_eta;
        break;
      case 'VEHICLE':
        displayName = 'Documento do Veículo';
        icon = Icons.motorcycle;
        break;
      default:
        displayName = type;
        icon = Icons.description;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          TextButton.icon(
            onPressed: () => _viewDocument(fileName),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Ver', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String fileName) {
    // TODO: Implementar visualização de documento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visualizar documento: $fileName')),
    );
  }

  void _showApproveDialog(int userId, String userName) {
    final observationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aprovar Documentos - $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tem certeza que deseja aprovar os documentos deste usuário?'),
            const SizedBox(height: 16),
            TextField(
              controller: observationController,
              decoration: const InputDecoration(
                labelText: 'Observação (opcional)',
                hintText: 'Documentos aprovados com sucesso!',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveDocument(userId, observationController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int userId, String userName) {
    final observationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rejeitar Documentos - $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Por que os documentos estão sendo rejeitados?'),
            const SizedBox(height: 16),
            TextField(
              controller: observationController,
              decoration: const InputDecoration(
                labelText: 'Motivo da rejeição *',
                hintText: 'Ex: Documento ilegível, foto cortada, etc.',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final observation = observationController.text.trim();
              if (observation.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor, informe o motivo da rejeição'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _rejectDocument(userId, observation);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveDocument(int userId, String observation) async {
    final response = await _documentService.approveDocument(
      userId: userId,
      observation: observation.isEmpty ? 'Documentos aprovados com sucesso!' : observation,
    );

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documentos aprovados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPendingDocuments(); // Recarregar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao aprovar: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectDocument(int userId, String observation) async {
    final response = await _documentService.rejectDocument(
      userId: userId,
      observation: observation,
    );

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documentos rejeitados. Usuário foi notificado.'),
          backgroundColor: Colors.orange,
        ),
      );
      _loadPendingDocuments(); // Recarregar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao rejeitar: ${response['message']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _logout() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
