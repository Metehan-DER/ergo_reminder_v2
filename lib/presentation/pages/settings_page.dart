import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/config/app_config.dart';
import '../widgets/designer_credits.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/settings_entity.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late Map<String, bool> _enabledReminders;
  late Map<String, int> _reminderIntervals;
  late TimeOfDay _silentStart;
  late TimeOfDay _silentEnd;
  late bool _autoStart;

  // Form alanları için state değişkenleri
  late String _userName;
  late String _selectedTitle;
  late String _gender;

  // TextEditingController'lar state'de tutulur — hafiza sızıntısı önlemek için
  late TextEditingController _nameController;
  final Map<String, TextEditingController> _intervalControllers = {};

  final List<String> _titles = [
    "Yok",

    // Samimi
    "Dostum",
    "Kanka",
    "Abi",
    "Reis",
    "Patron",

    // Saygın / Profesyonel
    "Mühendis",
    "Kıdemli Mühendis",
    "Başmühendis",
    "Teknik Lider",
    "Sistem Mimarı",
    "Baş Uzman",
    "Danışman",
    "Üstat",
    "Bilge",

    // Liderlik / Güç
    "Kaptan",
    "Komutan",
    "Amiral",
    "Başkomutan",
    "Şef",
    "Öncü",

    // Kraliyet
    "Kral",
    "Kraliçe",
    "Majesteleri",
    "İmparator",
    "Han",
    "Kağan",
    "Lord",

    // Başarı
    "Şampiyon",
    "Efsane",
    "Zirvedeki",
    "MVP",
    "Usta Oyuncu",

    // Eğlenceli / Absürt
    "Final Boss",
    "Gizli Boss",
    "CEO of Evren",
    "Galaksiler Arası Müdür",
    "Zaman Yolcusu",
    "NPC Ama Önemli",
    "Yan Görev Ustası",

    // Kaotik / Meme
    "Atak Helikopteri",
    "Savaş Makinesi",
    "Mobil Tehdit",
    "Bug Avcısı",
    "Exception Fırlatıcısı",
    "Stack Overflow Lordu",
    "Yapay Zeka (Ama Duygulu)",
  ];

  static const Map<String, String> _englishTitles = {
    "Yok": "None",
    "Dostum": "Buddy",
    "Kanka": "Bro",
    "Abi": "Big Bro",
    "Reis": "Chief",
    "Patron": "Boss",
    "Mühendis": "Engineer",
    "Kıdemli Mühendis": "Senior Engineer",
    "Başmühendis": "Chief Engineer",
    "Teknik Lider": "Tech Lead",
    "Sistem Mimarı": "Systems Architect",
    "Baş Uzman": "Principal Expert",
    "Danışman": "Consultant",
    "Üstat": "Master",
    "Bilge": "Sage",
    "Kaptan": "Captain",
    "Komutan": "Commander",
    "Amiral": "Admiral",
    "Başkomutan": "Commander-in-Chief",
    "Şef": "Chief",
    "Öncü": "Pioneer",
    "Kral": "King",
    "Kraliçe": "Queen",
    "Majesteleri": "Your Majesty",
    "İmparator": "Emperor",
    "Han": "Khan",
    "Kağan": "Khagan",
    "Lord": "Lord",
    "Şampiyon": "Champion",
    "Efsane": "Legend",
    "Zirvedeki": "At the Peak",
    "MVP": "MVP",
    "Usta Oyuncu": "Master Player",
    "Final Boss": "Final Boss",
    "Gizli Boss": "Secret Boss",
    "CEO of Evren": "CEO of the Universe",
    "Galaksiler Arası Müdür": "Intergalactic Manager",
    "Zaman Yolcusu": "Time Traveler",
    "NPC Ama Önemli": "Important NPC",
    "Yan Görev Ustası": "Side Quest Master",
    "Atak Helikopteri": "Attack Helicopter",
    "Savaş Makinesi": "War Machine",
    "Mobil Tehdit": "Mobile Threat",
    "Bug Avcısı": "Bug Hunter",
    "Exception Fırlatıcısı": "Exception Thrower",
    "Stack Overflow Lordu": "Stack Overflow Lord",
    "Yapay Zeka (Ama Duygulu)": "Sentient AI",
  };
  final List<String> _genders = ["Belirtilmemiş", "Erkek", "Kadın"];

  final Map<String, Map<String, dynamic>> _reminderData = {
    'eyeRest': {
      'name': 'Göz Dinlendirme',
      'icon': Icons.visibility,
      'color': Colors.blue,
      'description': '20-20-20 kuralı hatırlatıcısı',
    },
    'posture': {
      'name': 'Duruş Kontrolü',
      'icon': Icons.accessibility_new,
      'color': Colors.green,
      'description': 'Oturma pozisyonu kontrolü',
    },
    'water': {
      'name': 'Su İçme',
      'icon': Icons.local_drink,
      'color': Colors.cyan,
      'description': 'Hidrasyon hatırlatıcısı',
    },
    'stretch': {
      'name': 'Esneme',
      'icon': Icons.self_improvement,
      'color': Colors.orange,
      'description': 'Kas gerginliği giderme',
    },
    'walk': {
      'name': 'Yürüyüş',
      'icon': Icons.directions_walk,
      'color': Colors.purple,
      'description': 'Kan dolaşımını artırma',
    },
  };

  bool _isInitialized = false;

  void _initFromSettings(SettingsEntity settings) {
    if (_isInitialized) return;
    _enabledReminders = Map.from(settings.enabledReminders);
    _reminderIntervals = Map.from(settings.reminderIntervals);
    _silentStart = settings.silentStart;
    _silentEnd = settings.silentEnd;
    _autoStart = settings.autoStart;
    _userName = settings.userName;
    _selectedTitle = settings.userTitle;
    _gender = settings.gender;

    _nameController = TextEditingController(text: _userName);
    for (final key in _reminderIntervals.keys) {
      _intervalControllers[key] = TextEditingController(
        text: _reminderIntervals[key].toString(),
      );
    }
    _isInitialized = true;
  }

  late AppLocalizations _l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
  }

  String _getReminderName(String key) {
    switch (key) {
      case 'eyeRest': return _l10n.reminderEyeRest;
      case 'posture': return _l10n.reminderPosture;
      case 'water': return _l10n.reminderWater;
      case 'stretch': return _l10n.reminderStretch;
      case 'walk': return _l10n.reminderWalk;
      default: return _l10n.reminderDefault;
    }
  }

  String _getReminderDesc(String key) {
    switch (key) {
      case 'eyeRest': return _l10n.descEyeRest;
      case 'posture': return _l10n.descPosture;
      case 'water': return _l10n.descWater;
      case 'stretch': return _l10n.descStretch;
      case 'walk': return _l10n.descWalk;
      default: return '';
    }
  }

  String _getLocalizedTitle(String key) {
    if (_l10n.localeName == 'tr') return key;
    return _englishTitles[key] ?? key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final c in _intervalControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // build metodu içinde "Sistem Ayarları" kartının üstüne veya altına ekleyebilirsin:
  Widget _buildUserPersonalizationCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.teal.withValues(alpha: 0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // İsim Giriş Alanı
              TextField(
                style: const TextStyle(color: Colors.black),
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _l10n.nameLabel,
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  prefixIcon: const Icon(Icons.edit, color: Colors.deepOrange),
                  // Normal Kenarlık
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  // Tıklandığındaki Kenarlık
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.deepPurple.withValues(alpha: 0.05),
                ),
                onChanged: (value) => _userName = value,
              ),

              const SizedBox(height: 18),

              // Unvan Seçimi
              DropdownButtonFormField<String>(
                initialValue: _selectedTitle,
                dropdownColor: Colors.white, // Menü açıldığında arka plan
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
                decoration: InputDecoration(
                  labelText: _l10n.titleLabel,
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.deepPurple.withValues(alpha: 0.05),
                ),
                items: _titles
                    .map((t) => DropdownMenuItem(value: t, child: Text(_getLocalizedTitle(t))))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTitle = value!),
              ),

              const SizedBox(height: 18),

              // Cinsiyet Seçimi
              DropdownButtonFormField<String>(
                initialValue: _gender,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: _l10n.genderLabel,
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(
                      color: Colors.deepOrange,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.deepOrange.withValues(alpha: 0.05),
                ),
                items: _genders.map((g) {
                  String localizedG;
                  if (g == "Erkek") {
                    localizedG = _l10n.genderMale;
                  } else if (g == "Kadın") {
                    localizedG = _l10n.genderFemale;
                  } else {
                    localizedG = _l10n.genderUnspecified;
                  }
                  return DropdownMenuItem(value: g, child: Text(localizedG));
                }).toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (settings) {
        _initFromSettings(settings);
        return Scaffold(
          appBar: AppBar(title: Text(_l10n.settingsTitle), elevation: 0),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Color(0xFFF3E5F5)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(_l10n.profileSection, Icons.person),

            _buildUserPersonalizationCard(),

            _buildSectionTitle(_l10n.reminderSettingsSection, Icons.notifications),
            const SizedBox(height: 16),
            ..._reminderData.entries.map((entry) {
              return _buildReminderCard(entry.key, entry.value);
            }),

            const SizedBox(height: 32),
            _buildSectionTitle(_l10n.silentHoursSection, Icons.nightlight_round),
            const SizedBox(height: 16),
            _buildSilentHoursCard(),

            const SizedBox(height: 32),
            _buildSectionTitle(_l10n.systemSettingsSection, Icons.settings),
            const SizedBox(height: 16),
            _buildSystemSettingsCard(),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final newSettings = SettingsEntity(
                    userName: _userName,
                    userTitle: _selectedTitle,
                    gender: _gender,
                    autoStart: _autoStart,
                    silentStart: _silentStart,
                    silentEnd: _silentEnd,
                    enabledReminders: _enabledReminders,
                    reminderIntervals: _reminderIntervals,
                  );
                  
                  await ref.read(settingsProvider.notifier).updateSettings(newSettings);
                  
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_l10n.settingsSaved),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: Text(_l10n.saveSettings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DesignerCredits(
              designerName: "Metehan DER",
              // İsteğe bağlı parametreler
              animationPath: 'assets/animations/fire.json',
              // showDuration: Duration(seconds: 5),
              // animationDuration: Duration(milliseconds: 500),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
    });
  }

  Widget _buildReminderCard(String key, Map<String, dynamic> data) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, data['color'].withOpacity(0.05)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: data['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(data['icon'], color: data['color'], size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getReminderName(key),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getReminderDesc(key),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enabledReminders[key]!,
                    onChanged: (value) {
                      setState(() {
                        _enabledReminders[key] = value;
                      });
                    },
                    activeThumbColor: data['color'],
                  ),
                ],
              ),
              if (_enabledReminders[key]!)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text('${_l10n.every} ', style: const TextStyle(fontSize: 16)),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _intervalControllers[key],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            final intValue = int.tryParse(value);
                            if (intValue != null && intValue > 0) {
                              setState(() {
                                _reminderIntervals[key] = intValue;
                              });
                            }
                          },
                        ),
                      ),
                      Text(
                        ' ${AppConfig.isTestMode ? _l10n.minuteShort : _l10n.minutesSuffix}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSilentHoursCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF3E5F5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: Colors.indigo,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _l10n.silentHoursSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _l10n.silentHoursDesc,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _l10n.startTimeLabel,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _silentStart,
                              );
                              if (time != null) {
                                setState(() {
                                  _silentStart = time;
                                });
                              }
                            },
                            child: Text(
                              _silentStart.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _l10n.endTimeLabel,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _silentEnd,
                              );
                              if (time != null) {
                                setState(() {
                                  _silentEnd = time;
                                });
                              }
                            },
                            child: Text(
                              _silentEnd.format(context),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemSettingsCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF3E5F5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.computer,
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _l10n.systemSettingsSection,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _l10n.systemSettingsDesc,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.power_settings_new, color: Colors.teal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _l10n.autoStartLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _l10n.autoStartDesc,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoStart,
                      onChanged: (value) {
                        setState(() {
                          _autoStart = value;
                        });
                      },
                      activeThumbColor: Colors.teal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
