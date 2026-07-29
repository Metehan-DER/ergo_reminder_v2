import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'ErgoMate'**
  String get appTitle;

  /// No description provided for @statusHealthy.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığınız Korunuyor'**
  String get statusHealthy;

  /// No description provided for @statusStopped.
  ///
  /// In tr, this message translates to:
  /// **'Takip Durduruldu'**
  String get statusStopped;

  /// No description provided for @statusHealthyContinued.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığınız Korunuyor...'**
  String get statusHealthyContinued;

  /// No description provided for @greetingMorning.
  ///
  /// In tr, this message translates to:
  /// **'Günaydın'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In tr, this message translates to:
  /// **'İyi Günler'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In tr, this message translates to:
  /// **'İyi Akşamlar'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In tr, this message translates to:
  /// **'İyi Geceler'**
  String get greetingNight;

  /// No description provided for @workTimeFormat.
  ///
  /// In tr, this message translates to:
  /// **'{hours}sa {mins}dk'**
  String workTimeFormat(int hours, int mins);

  /// No description provided for @activeRemindersCount.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Hatırlatıcı'**
  String get activeRemindersCount;

  /// No description provided for @nextReminderLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sonraki Hatırlatıcı'**
  String get nextReminderLabel;

  /// No description provided for @todayReceived.
  ///
  /// In tr, this message translates to:
  /// **'Bugün Alınan'**
  String get todayReceived;

  /// No description provided for @todayPostponed.
  ///
  /// In tr, this message translates to:
  /// **'Bugün Ertelenen'**
  String get todayPostponed;

  /// No description provided for @activeRemindersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Hatırlatıcılar'**
  String get activeRemindersTitle;

  /// No description provided for @noActiveReminders.
  ///
  /// In tr, this message translates to:
  /// **'Henüz aktif hatırlatıcı yok.\nAyarlardan hatırlatıcıları aktifleştirin.'**
  String get noActiveReminders;

  /// No description provided for @minuteShort.
  ///
  /// In tr, this message translates to:
  /// **'dk'**
  String get minuteShort;

  /// No description provided for @silentHoursActive.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz Saatler Aktif'**
  String get silentHoursActive;

  /// No description provided for @silentHoursMuted.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcılar susturuldu'**
  String get silentHoursMuted;

  /// No description provided for @infoTrayText.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama sistem tepsisinde çalışmaya devam eder. Tamamen kapatmak için sistem tepsisindeki menüyü kullanın.'**
  String get infoTrayText;

  /// No description provided for @dialogOk.
  ///
  /// In tr, this message translates to:
  /// **'Tamam, Yapıyorum'**
  String get dialogOk;

  /// No description provided for @snoozeOption.
  ///
  /// In tr, this message translates to:
  /// **'{minutes} dk ertele'**
  String snoozeOption(int minutes);

  /// No description provided for @snoozeButtonLabel.
  ///
  /// In tr, this message translates to:
  /// **'Ertele'**
  String get snoozeButtonLabel;

  /// No description provided for @exitTitle.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Kapat'**
  String get exitTitle;

  /// No description provided for @exitContent.
  ///
  /// In tr, this message translates to:
  /// **'ErgoMate\'i tamamen kapatmak istiyor musunuz?'**
  String get exitContent;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @quit.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get quit;

  /// No description provided for @stop.
  ///
  /// In tr, this message translates to:
  /// **'Durdur'**
  String get stop;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başlat'**
  String get start;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @changeColors.
  ///
  /// In tr, this message translates to:
  /// **'Renkleri Değiştir'**
  String get changeColors;

  /// No description provided for @tooltipHideToTray.
  ///
  /// In tr, this message translates to:
  /// **'Sistem tepsisine gizle'**
  String get tooltipHideToTray;

  /// No description provided for @trayShowWindow.
  ///
  /// In tr, this message translates to:
  /// **'Pencereyi Göster'**
  String get trayShowWindow;

  /// No description provided for @trayHideWindow.
  ///
  /// In tr, this message translates to:
  /// **'Pencereyi Gizle'**
  String get trayHideWindow;

  /// No description provided for @trayQuit.
  ///
  /// In tr, this message translates to:
  /// **'Uygulamayı Kapat'**
  String get trayQuit;

  /// No description provided for @trayRunning.
  ///
  /// In tr, this message translates to:
  /// **'Çalışıyor'**
  String get trayRunning;

  /// No description provided for @trayStopped.
  ///
  /// In tr, this message translates to:
  /// **'Durduruldu'**
  String get trayStopped;

  /// No description provided for @reminderEyeRest.
  ///
  /// In tr, this message translates to:
  /// **'Göz Dinlendirme'**
  String get reminderEyeRest;

  /// No description provided for @reminderPosture.
  ///
  /// In tr, this message translates to:
  /// **'Duruş Kontrolü'**
  String get reminderPosture;

  /// No description provided for @reminderWater.
  ///
  /// In tr, this message translates to:
  /// **'Su İçme'**
  String get reminderWater;

  /// No description provided for @reminderStretch.
  ///
  /// In tr, this message translates to:
  /// **'Esneme'**
  String get reminderStretch;

  /// No description provided for @reminderWalk.
  ///
  /// In tr, this message translates to:
  /// **'Yürüyüş'**
  String get reminderWalk;

  /// No description provided for @msgEyeRest.
  ///
  /// In tr, this message translates to:
  /// **'20 saniye boyunca uzağa bakın ve gözlerinizi dinlendirin.'**
  String get msgEyeRest;

  /// No description provided for @msgPosture.
  ///
  /// In tr, this message translates to:
  /// **'Sırtınızı dik tutun ve omuzlarınızı rahatlatın.'**
  String get msgPosture;

  /// No description provided for @msgWater.
  ///
  /// In tr, this message translates to:
  /// **'Vücudunuzun hidrate kalması için bir bardak su için.'**
  String get msgWater;

  /// No description provided for @msgStretch.
  ///
  /// In tr, this message translates to:
  /// **'Hafif esneme hareketleri yaparak kas gerginliğini azaltın.'**
  String get msgStretch;

  /// No description provided for @msgWalk.
  ///
  /// In tr, this message translates to:
  /// **'Biraz ayağa kalkın ve 5 dakika yürüyüş yapın.'**
  String get msgWalk;

  /// No description provided for @reminderDefault.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı'**
  String get reminderDefault;

  /// No description provided for @msgDefault.
  ///
  /// In tr, this message translates to:
  /// **'Sağlığınız için kısa bir mola verin.'**
  String get msgDefault;

  /// No description provided for @settingsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settingsTitle;

  /// No description provided for @profileSection.
  ///
  /// In tr, this message translates to:
  /// **'Profil Özelleştir'**
  String get profileSection;

  /// No description provided for @nameLabel.
  ///
  /// In tr, this message translates to:
  /// **'Adınız'**
  String get nameLabel;

  /// No description provided for @titleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hitap Unvanı'**
  String get titleLabel;

  /// No description provided for @genderLabel.
  ///
  /// In tr, this message translates to:
  /// **'Cinsiyet'**
  String get genderLabel;

  /// No description provided for @genderUnspecified.
  ///
  /// In tr, this message translates to:
  /// **'Belirtilmemiş'**
  String get genderUnspecified;

  /// No description provided for @genderMale.
  ///
  /// In tr, this message translates to:
  /// **'Erkek'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In tr, this message translates to:
  /// **'Kadın'**
  String get genderFemale;

  /// No description provided for @noTitleOption.
  ///
  /// In tr, this message translates to:
  /// **'Yok'**
  String get noTitleOption;

  /// No description provided for @reminderSettingsSection.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı Ayarları'**
  String get reminderSettingsSection;

  /// No description provided for @descEyeRest.
  ///
  /// In tr, this message translates to:
  /// **'20-20-20 kuralı hatırlatıcısı'**
  String get descEyeRest;

  /// No description provided for @descPosture.
  ///
  /// In tr, this message translates to:
  /// **'Oturma pozisyonu kontrolü'**
  String get descPosture;

  /// No description provided for @descWater.
  ///
  /// In tr, this message translates to:
  /// **'Hidrasyon hatırlatıcısı'**
  String get descWater;

  /// No description provided for @descStretch.
  ///
  /// In tr, this message translates to:
  /// **'Kas gerginliği giderme'**
  String get descStretch;

  /// No description provided for @descWalk.
  ///
  /// In tr, this message translates to:
  /// **'Kan dolaşımını artırma'**
  String get descWalk;

  /// No description provided for @every.
  ///
  /// In tr, this message translates to:
  /// **'Her'**
  String get every;

  /// No description provided for @minutesSuffix.
  ///
  /// In tr, this message translates to:
  /// **'dakikada bir'**
  String get minutesSuffix;

  /// No description provided for @silentHoursSection.
  ///
  /// In tr, this message translates to:
  /// **'Sessiz Saatler'**
  String get silentHoursSection;

  /// No description provided for @silentHoursDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bu saatler arasında hatırlatıcılar susturulur'**
  String get silentHoursDesc;

  /// No description provided for @startTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç Saati:'**
  String get startTimeLabel;

  /// No description provided for @endTimeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Saati:'**
  String get endTimeLabel;

  /// No description provided for @systemSettingsSection.
  ///
  /// In tr, this message translates to:
  /// **'Sistem Ayarları'**
  String get systemSettingsSection;

  /// No description provided for @systemSettingsDesc.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama başlatma ve sistem entegrasyonu'**
  String get systemSettingsDesc;

  /// No description provided for @autoStartLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sistem başlangıcında otomatik çalıştır'**
  String get autoStartLabel;

  /// No description provided for @autoStartDesc.
  ///
  /// In tr, this message translates to:
  /// **'Bilgisayar açıldığında uygulamayı başlat'**
  String get autoStartDesc;

  /// No description provided for @saveSettings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarları Kaydet'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar başarıyla kaydedildi'**
  String get settingsSaved;

  /// No description provided for @languageSection.
  ///
  /// In tr, this message translates to:
  /// **'Dil / Language'**
  String get languageSection;

  /// No description provided for @langTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe 🇹🇷'**
  String get langTurkish;

  /// No description provided for @langEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English 🇬🇧'**
  String get langEnglish;

  /// No description provided for @statisticsTitle.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler & Analiz'**
  String get statisticsTitle;

  /// No description provided for @todayCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan'**
  String get todayCompleted;

  /// No description provided for @todaySnoozed.
  ///
  /// In tr, this message translates to:
  /// **'Ertelenen'**
  String get todaySnoozed;

  /// No description provided for @todayIgnored.
  ///
  /// In tr, this message translates to:
  /// **'Atlanan'**
  String get todayIgnored;

  /// No description provided for @totalReminders.
  ///
  /// In tr, this message translates to:
  /// **'Toplam İşlem'**
  String get totalReminders;

  /// No description provided for @successRate.
  ///
  /// In tr, this message translates to:
  /// **'Başarı Oranı'**
  String get successRate;

  /// No description provided for @viewStats.
  ///
  /// In tr, this message translates to:
  /// **'Detaylı İstatistikler'**
  String get viewStats;

  /// No description provided for @breakdownTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hatırlatıcı Dağılımı'**
  String get breakdownTitle;

  /// No description provided for @themeSection.
  ///
  /// In tr, this message translates to:
  /// **'Tema & Görünüm'**
  String get themeSection;

  /// No description provided for @themeModeLabel.
  ///
  /// In tr, this message translates to:
  /// **'Arayüz Modu'**
  String get themeModeLabel;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Karanlık'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In tr, this message translates to:
  /// **'Sistem'**
  String get themeSystem;

  /// No description provided for @themePaletteLabel.
  ///
  /// In tr, this message translates to:
  /// **'Renk Paleti'**
  String get themePaletteLabel;

  /// No description provided for @testModePrefix.
  ///
  /// In tr, this message translates to:
  /// **'Test:'**
  String get testModePrefix;

  /// No description provided for @dailyQuoteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün Notu'**
  String get dailyQuoteTitle;

  /// No description provided for @todoTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev Listesi'**
  String get todoTitle;

  /// No description provided for @calendarTitle.
  ///
  /// In tr, this message translates to:
  /// **'Takvim ve Ajanda'**
  String get calendarTitle;

  /// No description provided for @addTask.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Görev Ekle'**
  String get addTask;

  /// No description provided for @editTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Düzenle'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Sil'**
  String get deleteTask;

  /// No description provided for @taskTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Görev başlığı...'**
  String get taskTitleHint;

  /// No description provided for @taskDescHint.
  ///
  /// In tr, this message translates to:
  /// **'Açıklama veya notlar (isteğe bağlı)...'**
  String get taskDescHint;

  /// No description provided for @priority.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get priorityHigh;

  /// No description provided for @category.
  ///
  /// In tr, this message translates to:
  /// **'Kategori'**
  String get category;

  /// No description provided for @categoryWork.
  ///
  /// In tr, this message translates to:
  /// **'İş'**
  String get categoryWork;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryErgo.
  ///
  /// In tr, this message translates to:
  /// **'Ergonomi'**
  String get categoryErgo;

  /// No description provided for @categoryPersonal.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel'**
  String get categoryPersonal;

  /// No description provided for @dueDate.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tarih'**
  String get dueDate;

  /// No description provided for @noDueDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Yok'**
  String get noDueDate;

  /// No description provided for @filterAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get filterToday;

  /// No description provided for @filterPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyenler'**
  String get filterPending;

  /// No description provided for @filterCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlananlar'**
  String get filterCompleted;

  /// No description provided for @noTasksFound.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıtlı bir görev bulunamadı.'**
  String get noTasksFound;

  /// No description provided for @searchTasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevlerde ara...'**
  String get searchTasks;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @todayTasksSummary.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün Görevleri'**
  String get todayTasksSummary;

  /// No description provided for @pendingTasksCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} Görev Bekliyor'**
  String pendingTasksCount(int count);

  /// No description provided for @calendarSelectDate.
  ///
  /// In tr, this message translates to:
  /// **'Tarih Seçin'**
  String get calendarSelectDate;

  /// No description provided for @dailySummary.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Özet'**
  String get dailySummary;

  /// No description provided for @waterTrackerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günlük Su Tüketimi'**
  String get waterTrackerTitle;

  /// No description provided for @addGlass.
  ///
  /// In tr, this message translates to:
  /// **'+1 Bardak'**
  String get addGlass;

  /// No description provided for @removeGlass.
  ///
  /// In tr, this message translates to:
  /// **'-1 Bardak'**
  String get removeGlass;

  /// No description provided for @waterGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get waterGoal;

  /// No description provided for @waterGoalReached.
  ///
  /// In tr, this message translates to:
  /// **'Tebrikler! Günlük su hedefine ulaştınız! 💧'**
  String get waterGoalReached;

  /// No description provided for @selectWaterGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Seçin'**
  String get selectWaterGoal;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'ErgoMate\'e Hoş Geldin!'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In tr, this message translates to:
  /// **'Masaüstünde çalışırken sağlığınızı korumak ve verimliliğinizi artırmak için tasarlandı. Akıllı hatırlatıcılar, canlı su takibi ve ajanda ile gün boyu yanınızdayız.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @onboardingFeaturesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tüm Sağlık & Verimlilik Araçları'**
  String get onboardingFeaturesTitle;

  /// No description provided for @onboardingFeaturesDesc.
  ///
  /// In tr, this message translates to:
  /// **'Göz dinlendirme (20-20-20), duruş kontrolü, canlı su takipçisi, görev yönetimi ve kişisel ajandanız tek bir kokpitte.'**
  String get onboardingFeaturesDesc;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seni Tanıyalım!'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileDesc.
  ///
  /// In tr, this message translates to:
  /// **'Size nasıl hitap etmemizi istersiniz?'**
  String get onboardingProfileDesc;

  /// No description provided for @onboardingNameHint.
  ///
  /// In tr, this message translates to:
  /// **'Adınız (Örn: Metehan)...'**
  String get onboardingNameHint;

  /// No description provided for @onboardingTitleLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hitap Unvanı:'**
  String get onboardingTitleLabel;

  /// No description provided for @onboardingStartBtn.
  ///
  /// In tr, this message translates to:
  /// **'Başlayalım 🚀'**
  String get onboardingStartBtn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
