// config.dart

class AppConfig {
  // Test mode'u kapatmak için false yapın
  static const bool isTestMode = false;

  // Timer aralığı
  static Duration get timerInterval =>
      isTestMode ? const Duration(seconds: 1) : const Duration(minutes: 1);

  // Varsayılan hatırlatma aralıkları (dakika cinsinden)
  static Map<String, int> get defaultIntervals => isTestMode
      ? {
    'eyeRest': 10,   // Test için saniye
    'posture': 15,
    'water': 20,
    'stretch': 25,
    'walk': 30,
  }
      : {
    'eyeRest': 40,   // Production için dakika
    'posture': 30,
    'water': 60,
    'stretch': 50,
    'walk': 120,
  };

  // UI'da gösterilecek zaman birimi
  static String get timeUnit => isTestMode ? 'saniye' : 'dakika';
}