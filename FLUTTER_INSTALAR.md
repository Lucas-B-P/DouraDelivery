# 🚀 Instalar e Executar App Flutter

## 📋 Passo 1: Instalar Flutter

### Windows
1. Baixe: https://docs.flutter.dev/get-started/install/windows
2. Extraia para `C:\src\flutter`
3. Adicione ao PATH: `C:\src\flutter\bin`
4. Abra novo terminal: `flutter doctor`

### macOS
```bash
brew install flutter
flutter doctor
```

### Linux
```bash
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
export PATH="$PATH:$HOME/flutter/bin"
flutter doctor
```

## 🚀 Passo 2: Copiar Projeto

```bash
# Copiar pasta flutter_app para seu workspace
cd flutter_app
```

## 📦 Passo 3: Instalar Dependências

```bash
flutter pub get
```

## ⚙️ Passo 4: Configurar URL do Backend

Edite `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://seu-backend.up.railway.app';
```

Substitua pela URL real do seu backend no Railway.

## 🏃 Passo 5: Executar

```bash
# Verificar dispositivos
flutter devices

# Executar
flutter run

# Ou gerar APK
flutter build apk --debug
```

## ✅ Pronto!

O app está configurado e pronto para usar!

**Usuários de teste:**
- Cliente: `cliente@example.com` / `senha123`
- Entregador: `entregador@example.com` / `senha123`

