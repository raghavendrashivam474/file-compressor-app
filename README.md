# 🗜️ File Compressor [Backend/App]

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Python](https://img.shields.io/badge/python-3.8+-blue.svg)
![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-green.svg)

...rest of README
A beautiful cross-platform Flutter app for compressing images, PDFs, and videos with an intuitive Material Design interface.

## ✨ Features

- 🖼️ **Image Compression** with quality control
- 📄 **PDF Compression** with image optimization
- 🎥 **Video Compression** with quality presets and resolution options
- 📊 Real-time progress tracking
- 💾 Direct file download
- 🌐 Cross-platform (Web, Android, iOS, Desktop)

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.0+
- Backend API running (see backend README)

### Installation

```bash
# Clone repository
git clone <your-repo-url>
cd compressor_app

# Install dependencies
flutter pub get

# Run app
flutter run -d chrome  # For web
flutter run            # For mobile/desktop
🛠️ Tech Stack
Flutter/Dart
Dio (HTTP client)
File Picker
Material Design
Provider (State Management)
📡 API Configuration
Update lib/services/api_service.dart:

dart

static const String baseUrl = 'http://your-api-url/api/v1';
📊 Compression Results
Images: Up to 95% size reduction
PDFs: Up to 50% size reduction
Videos: Up to 97% size reduction
🌍 Supported Platforms
✅ Web (Chrome, Firefox, Safari, Edge)
✅ Android
✅ iOS
✅ Windows
✅ macOS
✅ Linux
📄 License
MIT License
