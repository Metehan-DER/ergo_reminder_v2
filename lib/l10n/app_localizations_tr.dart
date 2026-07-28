// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Ergonomik Asistan';

  @override
  String get statusHealthy => 'Sağlığınız Korunuyor';

  @override
  String get statusStopped => 'Takip Durduruldu';

  @override
  String get statusHealthyContinued => 'Sağlığınız Korunuyor...';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingAfternoon => 'İyi Günler';

  @override
  String get greetingEvening => 'İyi Akşamlar';

  @override
  String get greetingNight => 'İyi Geceler';

  @override
  String workTimeFormat(int hours, int mins) {
    return '${hours}sa ${mins}dk';
  }

  @override
  String get activeRemindersCount => 'Aktif Hatırlatıcı';

  @override
  String get nextReminderLabel => 'Sonraki Hatırlatıcı';

  @override
  String get todayReceived => 'Bugün Alınan';

  @override
  String get todayPostponed => 'Bugün Ertelenen';

  @override
  String get activeRemindersTitle => 'Aktif Hatırlatıcılar';

  @override
  String get noActiveReminders =>
      'Henüz aktif hatırlatıcı yok.\nAyarlardan hatırlatıcıları aktifleştirin.';

  @override
  String get minuteShort => 'dk';

  @override
  String get silentHoursActive => 'Sessiz Saatler Aktif';

  @override
  String get silentHoursMuted => 'Hatırlatıcılar susturuldu';

  @override
  String get infoTrayText =>
      'Uygulama sistem tepsisinde çalışmaya devam eder. Tamamen kapatmak için sistem tepsisindeki menüyü kullanın.';

  @override
  String get dialogOk => 'Tamam, Yapıyorum';

  @override
  String snoozeOption(int minutes) {
    return '$minutes dk ertele';
  }

  @override
  String get snoozeButtonLabel => 'Ertele';

  @override
  String get exitTitle => 'Uygulamayı Kapat';

  @override
  String get exitContent =>
      'Ergonomik Asistan\'ı tamamen kapatmak istiyor musunuz?';

  @override
  String get cancel => 'İptal';

  @override
  String get quit => 'Kapat';

  @override
  String get stop => 'Durdur';

  @override
  String get start => 'Başlat';

  @override
  String get settings => 'Ayarlar';

  @override
  String get changeColors => 'Renkleri Değiştir';

  @override
  String get tooltipHideToTray => 'Sistem tepsisine gizle';

  @override
  String get trayShowWindow => 'Pencereyi Göster';

  @override
  String get trayHideWindow => 'Pencereyi Gizle';

  @override
  String get trayQuit => 'Uygulamayı Kapat';

  @override
  String get trayRunning => 'Çalışıyor';

  @override
  String get trayStopped => 'Durduruldu';

  @override
  String get reminderEyeRest => 'Göz Dinlendirme';

  @override
  String get reminderPosture => 'Duruş Kontrolü';

  @override
  String get reminderWater => 'Su İçme';

  @override
  String get reminderStretch => 'Esneme';

  @override
  String get reminderWalk => 'Yürüyüş';

  @override
  String get msgEyeRest =>
      '20 saniye boyunca uzağa bakın ve gözlerinizi dinlendirin.';

  @override
  String get msgPosture => 'Sırtınızı dik tutun ve omuzlarınızı rahatlatın.';

  @override
  String get msgWater => 'Vücudunuzun hidrate kalması için bir bardak su için.';

  @override
  String get msgStretch =>
      'Hafif esneme hareketleri yaparak kas gerginliğini azaltın.';

  @override
  String get msgWalk => 'Biraz ayağa kalkın ve 5 dakika yürüyüş yapın.';

  @override
  String get reminderDefault => 'Hatırlatıcı';

  @override
  String get msgDefault => 'Sağlığınız için kısa bir mola verin.';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get profileSection => 'Profil Özelleştir';

  @override
  String get nameLabel => 'Adınız';

  @override
  String get titleLabel => 'Hitap Unvanı';

  @override
  String get genderLabel => 'Cinsiyet';

  @override
  String get genderUnspecified => 'Belirtilmemiş';

  @override
  String get genderMale => 'Erkek';

  @override
  String get genderFemale => 'Kadın';

  @override
  String get noTitleOption => 'Yok';

  @override
  String get reminderSettingsSection => 'Hatırlatıcı Ayarları';

  @override
  String get descEyeRest => '20-20-20 kuralı hatırlatıcısı';

  @override
  String get descPosture => 'Oturma pozisyonu kontrolü';

  @override
  String get descWater => 'Hidrasyon hatırlatıcısı';

  @override
  String get descStretch => 'Kas gerginliği giderme';

  @override
  String get descWalk => 'Kan dolaşımını artırma';

  @override
  String get every => 'Her';

  @override
  String get minutesSuffix => 'dakikada bir';

  @override
  String get silentHoursSection => 'Sessiz Saatler';

  @override
  String get silentHoursDesc => 'Bu saatler arasında hatırlatıcılar susturulur';

  @override
  String get startTimeLabel => 'Başlangıç Saati:';

  @override
  String get endTimeLabel => 'Bitiş Saati:';

  @override
  String get systemSettingsSection => 'Sistem Ayarları';

  @override
  String get systemSettingsDesc => 'Uygulama başlatma ve sistem entegrasyonu';

  @override
  String get autoStartLabel => 'Sistem başlangıcında otomatik çalıştır';

  @override
  String get autoStartDesc => 'Bilgisayar açıldığında uygulamayı başlat';

  @override
  String get saveSettings => 'Ayarları Kaydet';

  @override
  String get settingsSaved => 'Ayarlar başarıyla kaydedildi';

  @override
  String get languageSection => 'Dil / Language';

  @override
  String get testModePrefix => 'Test:';
}
