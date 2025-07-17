# Ergonomik Asistan

Ofis çalışanları için ergonomik hatırlatıcı uygulaması. Windows ve macOS platformlarında çalışır.

## Özellikler

- ⏰ **Özelleştirilebilir Hatırlatmalar**
    - Göz dinlendirme (varsayılan: 40 dakika)
    - Duruş kontrolü (varsayılan: 30 dakika)
    - Su içme (varsayılan: 60 dakika)
    - Esneme (varsayılan: 50 dakika)
    - Yürüyüş molası (varsayılan: 120 dakika)

- 🔕 **Sessiz Saatler**
    - Belirlediğiniz saatler arasında bildirim göndermez
    - Varsayılan: 22:00 - 08:00

- 🚀 **Otomatik Başlatma**
    - Bilgisayar açıldığında otomatik olarak başlar

- 🔔 **Sistem Bildirimleri**
    - Native bildirimler ile rahatsız edici olmayan hatırlatmalar

- 📍 **Sistem Tepsisi**
    - Minimal görünüm, sistem tepsisinden kontrol

## Kurulum

### 1. Flutter SDK'yı yükleyin
```bash
# Flutter'ı indirin ve PATH'e ekleyin
# https://flutter.dev/docs/get-started/install
```

### 2. Bağımlılıkları yükleyin
```bash
flutter pub get
```

### 3. Platform-specific ayarlar

#### Windows için:
```bash
# Visual Studio 2019 veya üzeri yüklü olmalı
flutter config --enable-windows-desktop
```

#### macOS için:
```bash
# Xcode yüklü olmalı
flutter config --enable-macos-desktop
```

### 4. Assets klasörünü oluşturun
```bash
mkdir assets
# app_icon.ico (Windows için) ve app_icon.png (macOS için) dosyalarını ekleyin
```

### 5. Uygulamayı çalıştırın
```bash
# Windows için
flutter run -d windows

# macOS için
flutter run -d macos
```

## Build

### Windows için:
```bash
flutter build windows --release
# Çıktı: build/windows/runner/Release/
```

### macOS için:
```bash
flutter build macos --release
# Çıktı: build/macos/Build/Products/Release/
```

## Kullanım

1. **İlk Açılış**: Uygulama açıldığında otomatik olarak takip başlar
2. **Sistem Tepsisi**: Pencereyi kap