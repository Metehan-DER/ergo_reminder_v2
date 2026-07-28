# 🧘 Ergonomik Asistan

> Ofis çalışanları için masaüstü ergonomi takip uygulaması. Flutter ile geliştirilmiş, Windows ve macOS üzerinde çalışır.

---

## ✨ Özellikler

### 🔔 Akıllı Hatırlatıcılar
| Hatırlatıcı | Varsayılan Aralık | Açıklama |
|---|---|---|
| 👁️ Göz Dinlendirme | 40 dakika | 20-20-20 kuralı — uzağa bak, gözlerini dinlendir |
| 🧍 Duruş Kontrolü | 30 dakika | Sırtını dik tut, omuzlarını rahatlatı |
| 💧 Su İçme | 60 dakika | Hidrasyon takibi |
| 🤸 Esneme | 50 dakika | Kas gerginliğini gider |
| 🚶 Yürüyüş Molası | 120 dakika | Kan dolaşımını artır |

### ⚙️ Diğer Özellikler
- 🔕 **Sessiz Saatler** — belirli saatler arasında bildirimleri sustur (varsayılan: 22:00–08:00)
- 🚀 **Otomatik Başlatma** — sistem başlangıcında arka planda çal
- 🎨 **Kişiselleştirme** — isim, unvan ve cinsiyete göre kişisel selamlama
- 🖥️ **Sistem Tepsisi** — pencereyi kapatınca arka planda çalışmaya devam eder
- ⏸️ **Durdur / Başlat** — takibi tek tuşla duraklat
- 🌈 **Glassmorphism UI** — animasyonlu, renk değiştirebilen modern arayüz

---

## 📦 Kurulum

### Gereksinimler
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.x veya üzeri)
- **Windows:** Visual Studio 2019+ (C++ masaüstü geliştirme iş yükü)
- **macOS:** Xcode

### Adımlar

```bash
# 1. Repoyu klonla
git clone https://github.com/kullanici_adi/ergo_reminder_v2.git
cd ergo_reminder_v2

# 2. Bağımlılıkları yükle
flutter pub get

# 3. Platform desteğini etkinleştir (ilk kurulumda)
flutter config --enable-windows-desktop   # Windows için
flutter config --enable-macos-desktop     # macOS için

# 4. Uygulamayı çalıştır
flutter run -d windows    # Windows
flutter run -d macos      # macOS
```

---

## 🏗️ Build (Release)

```bash
# Windows
flutter build windows --release
# Çıktı: build/windows/x64/runner/Release/

# macOS
flutter build macos --release
# Çıktı: build/macos/Build/Products/Release/
```

---

## 🗂️ Proje Yapısı

```
lib/
├── main.dart           # Uygulama giriş noktası, pencere & başlatma ayarları
├── home_page.dart      # Ana ekran — durum kartı, hatırlatıcı kartları, animasyonlar
├── settings_page.dart  # Ayarlar ekranı — aralık, sessiz saatler, profil
├── credits.dart        # "Designed by" easter egg widget'ı
└── config.dart         # Merkezi yapılandırma (aralıklar, test modu)
```

---

## 🛠️ Kullanılan Teknolojiler

| Paket | Amaç |
|---|---|
| `flutter_local_notifications` | Yerel sistem bildirimleri (Windows & macOS) |
| `tray_manager` | Sistem tepsisi entegrasyonu |
| `window_manager` | Pencere kontrolü (boyut, gizle/göster, always on top) |
| `launch_at_startup` | Sistem başlangıcında otomatik çalıştırma |
| `shared_preferences` | Kullanıcı ayarlarını kaydetme |
| `lottie` | Lottie JSON animasyonları |

---

## 💡 Kullanım

1. **İlk Açılış:** Uygulama başladığında takip otomatik olarak başlar.
2. **Sistem Tepsisi:** Pencereyi kapatınca uygulama arka planda çalışmaya devam eder. Tepsi simgesine tıklayarak pencereyi göster/gizle veya uygulamayı kapat.
3. **Ayarlar:** Sağ üstteki ⚙️ simgesine veya tepsi menüsündeki "Ayarlar"a tıkla.
4. **Hatırlatma Geldiğinde:** Açılan diyalogdan "Tamam, Yapıyorum" ile onayla veya "5 Dk Ertele" ile ertele.
5. **Durdurma:** Ana ekrandaki "Durdur" butonuyla veya tepsi menüsünden takibi duraklat.

---

## 📄 Lisans

Bu proje kişisel / eğitim amaçlı geliştirilmiştir.

---

<div align="center">
  <i>Designed with ❤️ by Metehan DER</i>
</div>
