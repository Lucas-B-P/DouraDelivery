# ⚙️ Como Configurar a URL do Backend

## 🔧 Passo 1: Obter URL do Railway

1. Acesse [railway.app](https://railway.app)
2. Entre no seu projeto
3. Clique no serviço da aplicação
4. Vá em "Settings" → "Networking"
5. Copie a URL (ex: `https://seu-app.up.railway.app`)

## 📝 Passo 2: Configurar no App

Edite o arquivo `lib/services/api_service.dart`:

```dart
class ApiService {
  // SUBSTITUA pela URL do seu backend no Railway
  static const String baseUrl = 'https://seu-app.up.railway.app';
  // ...
}
```

**Importante:**
- ✅ Use `https://` (não `http://`)
- ✅ Remova a barra `/` no final
- ✅ Não adicione `/api` no final

## ✅ Passo 3: Verificar

Teste a conexão:

1. Abra no navegador:
   ```
   https://sua-url.up.railway.app/actuator/health
   ```
   
2. Deve retornar:
   ```json
   {
     "status": "UP"
   }
   ```

3. Se funcionar no navegador, funcionará no app!

## 🧪 Testar Login

Use estas credenciais de teste:
- **Cliente**: `cliente@example.com` / `senha123`
- **Entregador**: `entregador@example.com` / `senha123`

## ❌ Erro Comum

Se aparecer erro de conexão:
1. Verifique se o backend está rodando no Railway
2. Verifique se a URL está correta (sem `/` no final)
3. Verifique se está usando `https://` (não `http://`)

---

**URL configurada! 🎉**

