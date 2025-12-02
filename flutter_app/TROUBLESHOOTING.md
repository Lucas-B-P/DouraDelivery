# 🔧 Troubleshooting - Erros Comuns

## ❌ Erro: "The connection errored: XMLHttpRequest onError"

### Causa
Erro de conexão de rede. Geralmente significa que:
1. Backend não está rodando
2. URL do backend está incorreta
3. Problema de conectividade

### Solução

#### 1. Verificar URL do Backend

Edite `lib/services/api_service.dart` e confirme a URL:

```dart
static const String baseUrl = 'https://seu-backend.up.railway.app';
```

**Importante:**
- Use `https://` (não `http://`)
- Remova a barra `/` no final
- Use a URL completa do Railway

#### 2. Verificar se Backend está Rodando

Teste no navegador ou Postman:
```
GET https://seu-backend.up.railway.app/actuator/health
```

Deve retornar:
```json
{
  "status": "UP"
}
```

#### 3. Verificar CORS no Backend

O backend já está configurado para aceitar requisições de qualquer origem. Se ainda houver problema, verifique `SecurityConfig.java`.

#### 4. Testar Conexão Manualmente

Crie um arquivo de teste `test_connection.dart`:

```dart
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get('https://seu-backend.up.railway.app/actuator/health');
    print('✅ Conexão OK: ${response.data}');
  } catch (e) {
    print('❌ Erro: $e');
  }
}
```

Execute:
```bash
dart test_connection.dart
```

## ❌ Erro: "401 Unauthorized"

### Causa
Token JWT inválido ou expirado.

### Solução
1. Faça logout e login novamente
2. Verifique se o token está sendo salvo corretamente
3. Verifique se o JWT_SECRET no backend está correto

## ❌ Erro: "404 Not Found"

### Causa
Endpoint não existe ou URL incorreta.

### Solução
1. Verifique se o endpoint existe no backend
2. Confirme a URL base está correta
3. Verifique se o backend está deployado

## ❌ Erro: "Timeout"

### Causa
Backend demorando muito para responder.

### Solução
Aumente o timeout em `api_service.dart`:

```dart
_dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  headers: {'Content-Type': 'application/json'},
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
));
```

## ❌ Erro: "SSL Certificate"

### Causa
Problema com certificado SSL.

### Solução
Para desenvolvimento, pode desabilitar verificação SSL (NÃO use em produção):

```dart
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

_dio = Dio(BaseOptions(
  baseUrl: baseUrl,
  headers: {'Content-Type': 'application/json'},
));

(_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = 
  (HttpClient client) {
    client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return client;
  };
```

## ✅ Checklist de Diagnóstico

- [ ] Backend está rodando e acessível
- [ ] URL do backend está correta (com https://)
- [ ] Health check retorna 200 OK
- [ ] Não há barra `/` no final da URL
- [ ] Backend aceita requisições (CORS configurado)
- [ ] Dispositivo/emulador tem internet
- [ ] Firewall não está bloqueando

## 🧪 Testar Conexão

### Via cURL
```bash
curl https://seu-backend.up.railway.app/actuator/health
```

### Via Postman/Insomnia
```
GET https://seu-backend.up.railway.app/actuator/health
```

### Via Navegador
Abra no navegador:
```
https://seu-backend.up.railway.app/actuator/health
```

## 📱 Testar no App

Adicione logs temporários em `auth_service.dart`:

```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    print('🔗 Tentando conectar em: ${_apiService.baseUrl}/api/auth/login');
    print('📧 Email: $email');
    
    final response = await _apiService.dio.post('/api/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    print('✅ Login bem-sucedido!');
    // ... resto do código
  } on DioException catch (e) {
    print('❌ Erro DioException:');
    print('   Status: ${e.response?.statusCode}');
    print('   Mensagem: ${e.message}');
    print('   Response: ${e.response?.data}');
    throw Exception('Erro ao fazer login: ${e.response?.data ?? e.message}');
  }
}
```

Veja os logs no terminal:
```bash
flutter run
```

---

**Se o problema persistir, verifique os logs do backend no Railway!**

