# DouraDelivery Flutter App

App Flutter completo para o sistema DouraDelivery.

## 🚀 Como Usar

1. **Instalar Flutter**: https://docs.flutter.dev/get-started/install

2. **Instalar dependências**:
```bash
flutter pub get
```

3. **Configurar URL do backend**:
Edite `lib/services/api_service.dart` e altere:
```dart
static const String baseUrl = 'https://seu-backend.up.railway.app';
```

4. **Executar**:
```bash
flutter run
```

5. **Gerar APK**:
```bash
flutter build apk --debug
```

## 📱 Funcionalidades

- ✅ Login com JWT
- ✅ Cliente: Criar e listar pedidos
- ✅ Entregador: Aceitar/recusar pedidos, confirmar entrega
- ✅ Telemetria GPS automática
- ✅ Interface completa e funcional

## 👤 Usuários de Teste

- **Cliente**: `cliente@example.com` / `senha123`
- **Entregador**: `entregador@example.com` / `senha123`

## 📁 Estrutura

```
lib/
├── main.dart
├── services/        # API, Auth, Order, Telemetry
├── providers/      # State Management
└── screens/        # Telas do app
    ├── cliente/
    └── entregador/
```

## 🔧 Troubleshooting

### Erro: "SDK location not found"
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
```

### Erro: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

**App pronto para usar! 🎉**

