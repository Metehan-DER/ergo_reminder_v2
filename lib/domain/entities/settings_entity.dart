import 'package:flutter/material.dart';

class SettingsEntity {
  final String userName;
  final String userTitle;
  final String gender;
  final bool autoStart;
  final TimeOfDay silentStart;
  final TimeOfDay silentEnd;
  final Map<String, bool> enabledReminders;
  final Map<String, int> reminderIntervals;
  final bool isOnboardingCompleted;

  const SettingsEntity({
    required this.userName,
    required this.userTitle,
    required this.gender,
    required this.autoStart,
    required this.silentStart,
    required this.silentEnd,
    required this.enabledReminders,
    required this.reminderIntervals,
    this.isOnboardingCompleted = false,
  });

  // ── Domain verisi — DIP: Settings sayfası bu listelerden okur, kendi tanımlamaz ──

  /// Kullanıcının seçebileceği unvan listesi (Türkçe).
  static const List<String> availableTitles = [
    "Yok",
    // Samimi & Geleneksel
    "Bey", "Hanım", "Dostum", "Kanka", "Abi", "Reis", "Patron",
    "Dahi", "Kahraman", "Lider", "Usta",
    // Saygın / Profesyonel
    "Mühendis", "Kıdemli Mühendis", "Başmühendis", "Teknik Lider",
    "Sistem Mimarı", "Baş Uzman", "Danışman", "Üstat", "Bilge",
    // Liderlik / Güç
    "Kaptan", "Komutan", "Amiral", "Başkomutan", "Şef", "Öncü",
    // Kraliyet
    "Kral", "Kraliçe", "Majesteleri", "İmparator", "Han", "Kağan", "Lord",
    // Başarı
    "Şampiyon", "Efsane", "Zirvedeki", "MVP", "Usta Oyuncu",
    // Eğlenceli / Absürt
    "Final Boss", "Gizli Boss", "CEO of Evren", "Galaksiler Arası Müdür",
    "Zaman Yolcusu", "NPC Ama Önemli", "Yan Görev Ustası",
    // Kaotik / Meme
    "Atak Helikopteri", "Savaş Makinesi", "Mobil Tehdit", "Bug Avcısı",
    "Exception Fırlatıcısı", "Stack Overflow Lordu", "Yapay Zeka (Ama Duygulu)",
  ];

  /// Türkçe unvan → İngilizce karşılık haritası.
  static const Map<String, String> titleTranslations = {
    "Yok": "None", "Bey": "Mr.", "Hanım": "Ms.", "Dostum": "Buddy",
    "Kanka": "Bro", "Abi": "Big Bro", "Reis": "Chief", "Patron": "Boss",
    "Mühendis": "Engineer", "Kıdemli Mühendis": "Senior Engineer",
    "Başmühendis": "Chief Engineer", "Teknik Lider": "Tech Lead",
    "Sistem Mimarı": "Systems Architect", "Baş Uzman": "Principal Expert",
    "Danışman": "Consultant", "Üstat": "Master", "Bilge": "Sage",
    "Kaptan": "Captain", "Komutan": "Commander", "Amiral": "Admiral",
    "Başkomutan": "Commander-in-Chief", "Şef": "Chief", "Öncü": "Pioneer",
    "Kral": "King", "Kraliçe": "Queen", "Majesteleri": "Your Majesty",
    "İmparator": "Emperor", "Han": "Khan", "Kağan": "Khagan", "Lord": "Lord",
    "Şampiyon": "Champion", "Efsane": "Legend", "Zirvedeki": "At the Peak",
    "MVP": "MVP", "Usta Oyuncu": "Master Player",
    "Final Boss": "Final Boss", "Gizli Boss": "Secret Boss",
    "CEO of Evren": "CEO of the Universe",
    "Galaksiler Arası Müdür": "Intergalactic Manager",
    "Zaman Yolcusu": "Time Traveler", "NPC Ama Önemli": "Important NPC",
    "Yan Görev Ustası": "Side Quest Master",
    "Atak Helikopteri": "Attack Helicopter", "Savaş Makinesi": "War Machine",
    "Mobil Tehdit": "Mobile Threat", "Bug Avcısı": "Bug Hunter",
    "Exception Fırlatıcısı": "Exception Thrower",
    "Stack Overflow Lordu": "Stack Overflow Lord",
  };



  SettingsEntity copyWith({
    String? userName,
    String? userTitle,
    String? gender,
    bool? autoStart,
    TimeOfDay? silentStart,
    TimeOfDay? silentEnd,
    Map<String, bool>? enabledReminders,
    Map<String, int>? reminderIntervals,
    bool? isOnboardingCompleted,
  }) {
    return SettingsEntity(
      userName: userName ?? this.userName,
      userTitle: userTitle ?? this.userTitle,
      gender: gender ?? this.gender,
      autoStart: autoStart ?? this.autoStart,
      silentStart: silentStart ?? this.silentStart,
      silentEnd: silentEnd ?? this.silentEnd,
      enabledReminders: enabledReminders ?? this.enabledReminders,
      reminderIntervals: reminderIntervals ?? this.reminderIntervals,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }
}
