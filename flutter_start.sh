#!/bin/bash

# Script para criar projeto Flutter DouraDelivery

echo "🚀 Criando projeto Flutter DouraDelivery..."

# Criar projeto
flutter create douradelivery_app
cd douradelivery_app

# Adicionar dependências ao pubspec.yaml
cat >> pubspec.yaml << 'EOF'

  # HTTP Client
  dio: ^5.4.0
  
  # Storage
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^12.1.0
  
  # State Management
  provider: ^6.1.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  
  # WebSocket
  web_socket_channel: ^2.4.0
  
  # Notifications
  flutter_local_notifications: ^16.2.0
EOF

# Instalar dependências
flutter pub get

echo "✅ Projeto criado! Próximos passos:"
echo "1. cd douradelivery_app"
echo "2. flutter run"
echo "3. Ou copie os arquivos de FLUTTER_EXEMPLO_COMPLETO.md"

