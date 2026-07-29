# 🧘 ErgoMate

> **Ofis ve masaüstü çalışanları için akıllı sağlık, mola ve verimlilik asistanı.**  
> Flutter ile geliştirilmiştir; Windows ve macOS üzerinde son derece akıcı, modern ve kişiselleştirilebilir bir deneyim sunar.

---

## 🚀 Doğrudan İndir (Hızlı Kurulum)

Geliştirme ortamı kurmakla uğraşmak istemiyorsanız, işletim sisteminize uygun hazır sürümleri tek tıkla indirebilirsiniz:

| İşletim Sistemi | Sürüm | Doğrudan İndirme Linki |
|---|---|---|
| 🪟 **Windows** | v2.0.0 (64-bit) | [📥 Windows İndir (.zip / .exe)](https://github.com/Metehan-DER/ergo_reminder_v2/releases/latest/download/ErgoMate-Windows.zip) |
| 🍎 **macOS** | v2.0.0 (Universal) | [📥 macOS İndir (.dmg / .app)](https://github.com/Metehan-DER/ergo_reminder_v2/releases/latest/download/ErgoMate-macOS.dmg) |

> 💡 *Sürümleri ayrıca GitHub üzerindeki [Releases](https://github.com/Metehan-DER/ergo_reminder_v2/releases) sayfasından da takip edebilirsiniz.*

---

## ✨ Öne Çıkan Özellikler

### 🔔 1. Akıllı Sağlık & Ergonomi Hatırlatıcıları
| Hatırlatıcı | Varsayılan Aralık | Açıklama |
|---|---|---|
| 👁️ **Göz Dinlendirme** | 40 dakika | 20-20-20 kuralı — uzağa bak ve göz kaslarını dinlendir |
| 🧍 **Duruş Kontrolü** | 30 dakika | Oturma pozisyonunu ve sırt doğruluğunu kontrol et |
| 💧 **Su İçme** | 60 dakika | Düzenli hidrasyon hatırlatıcısı |
| 🤸 **Esneme Molası** | 50 dakika | Omuz ve boyun kas gerginliğini gider |
| 🚶 **Yürüyüş Molası** | 120 dakika | Kan dolaşımını canlandırmak için hareket et |

---

### 💧 2. Canlı Animasyonlu Su Takipçisi (Water Tracker)
- **Fiziksel Sıvı Dalgalanması:** `CustomPainter` ve `AnimationController` ile bardağın içindeki suyun canlı ve akıcı sinüs dalgaları (`sin wave`) ile sürekli hareket etmesi.
- **Tek Tıkla Tüketim Ekleme:** `+1 Bardak (+250 ml)` ve `-1 Bardak` hızlı eylemleri.
- **Kişiselleştirilebilir Günlük Hedef:** Tıklandığında 1.5L, 2.0L, 2.5L, 3.0L veya 3.5L hedef seçimi.

---

### 📝 3. Görev Listesi & Verimlilik (Todo List)
- **Öncelik & Kategori Yönetimi:** Görevleri *Yüksek, Orta, Düşük* öncelik ve *İş, Sağlık, Ergonomi, Kişisel* kategorileriyle organize etme.
- **Filtreleme & Arama:** Metin ile canlı arama; *Tümü, Bugün, Bekleyenler, Tamamlananlar* sekmeleri.
- **Şık Modal Form:** Aşağıdan yumuşak bir animasyonla açılan (Modal Bottom Sheet) hızlı görev ekleme ekranı.
- **Ana Sayfa İlerleme Kartı:** Günlük tamamlanan görev oranını canlı dairesel halka (`CircularProgressIndicator`) ile izleme.

---

### 📅 4. Takvim ve Günlük Ajanda (Calendar View)
- **Buzlu Cam Izgara (Glassmorphism Grid):** Ana sayfa sağ paneline gömülü özel ay/gün takvimi.
- **Günlük Analiz & Mola Özeti:** Seçilen güne tıklayarak o günün mola istatistiklerini ve planlanan görevlerini görüntüleme.
- **Öncelikli Görev Noktaları:** Tarihlerin altında görev durumuna göre renkli gösterge noktaları.

---

### 🎬 5. Premium Arayüz & Akıcı Geçişler
- **Glassmorphic 2.0 Tasarımı:** İnce renkli gradyan kenarlıklar, canlı kontrastlar ve bulanıklaştırılmış arka planlar.
- **Derinlikli Sayfa Geçişleri (Scale + Fade + Slide):** Apple ve Material 3 standartlarında akıcı derinlik animasyonları.
- **Çoklu Renk Paletleri & Tema:** Aydınlık/Karanlık mod ve 5+ canlı renk teması.
- **Çoklu Dil Desteği:** Türkçe 🇹🇷 ve İngilizce 🇬🇧 yerel dil seçeneği.

---

### 🖥️ 6. Sistem & Masaüstü Entegrasyonu
- **Sistem Tepsisi (System Tray):** Pencere kapatıldığında arka planda sessizce çalışmaya devam etme.
- **Otomatik Başlatma:** Bilgisayar açıldığında otomatik çalışma seçeneği (`launch_at_startup`).
- **Masaüstü Bildirimleri:** Windows ve macOS yerel bildirim desteği.

---

## 🛠️ Kullanılan Teknolojiler & Mimarisi

- **Framework:** Flutter 3.x (Dart)
- **State Management:** Riverpod 3.x (`NotifierProvider`, `StateNotifier`)
- **Mimari:** Clean Architecture (Domain, Data, Presentation, Core)
- **Paketler:** `flutter_local_notifications`, `tray_manager`, `window_manager`, `launch_at_startup`, `shared_preferences`, `google_fonts`

---

## 🗂️ Proje Yapısı

```
lib/
├── core/
│   ├── services/       # Storage, Notification & Window servisleri
│   └── utils/          # Premium sayfa geçiş animasyonları (AppPageRoute)
├── data/
│   └── repositories/   # StorageService tabanlı veri depoları
├── domain/
│   ├── entities/       # Todo, WaterLog, Settings, Stats modelleri
│   └── repositories/   # Soyut repository arayüzleri
├── l10n/               # Türkçe ve İngilizce dil dosyaları (app_tr.arb, app_en.arb)
└── presentation/
    ├── pages/          # Home, Settings, Stats, Todo, Calendar sayfaları
    ├── providers/      # Riverpod durum ve servis sağlayıcıları
    └── widgets/        # WaterTracker, TodoSummaryCard, AnimatedWaterCup
```

---

## 💻 Kaynak Koddan Çalıştırma (Geliştiriciler İçin)

Proje kaynak kodunu yerel ortamınızda derlemek isterseniz:

```bash
# 1. Repoyu klonlayın
git clone https://github.com/Metehan-DER/ergo_reminder_v2.git
cd ergo_reminder_v2

# 2. Bağımlılıkları yükleyin
flutter pub get

# 3. Derleyin ve çalıştırın
flutter run -d windows   # Windows için
flutter run -d macos     # macOS için
```

---

<div align="center">
  <i>Designed & Developed with ❤️ by <b>Metehan DER</b></i>
</div>
