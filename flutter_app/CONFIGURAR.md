# ⚙️ Configuração do App Flutter

## 🔧 Passo 1: Configurar URL do Backend

Edite `lib/services/api_service.dart` linha 3:

```dart
static const String baseUrl = 'https://seu-backend.up.railway.app';
```

Substitua pela URL real do seu backend no Railway.

## 🔧 Passo 2: Configurar WebSocket (Opcional)

Edite `lib/services/websocket_service.dart` linha 3:

```dart
static const String baseUrl = 'wss://seu-backend.up.railway.app';
```

## 📱 Passo 3: Instalar Dependências

```bash
cd flutter_app
flutter pub get
```

## 🚀 Passo 4: Executar

```bash
# Verificar dispositivos
flutter devices

# Executar
flutter run

# Ou gerar APK
flutter build apk --debug
```

## ✅ Pronto!

O app está configurado e pronto para usar.

**Usuários de teste:**
- Cliente: `cliente@example.com` / `senha123`
- Entregador: `entregador@example.com` / `senha123`

