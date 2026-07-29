import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../core/config/app_config.dart';
import '../widgets/designer_credits.dart';
import '../providers/settings_provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
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

    // Samimi & Geleneksel
    "Bey",
    "Hanım",
    "Dostum",
    "Kanka",
    "Abi",
    "Reis",
    "Patron",
    "Dahi",
    "Kahraman",
    "Lider",
    "Usta",

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
    "Bey": "Mr.",
    "Hanım": "Ms.",
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
  };

  final Map<String, Map<String, dynamic>> _reminderData = {
    'eyeRest': {
      'name': 'Göz Dinlendirme',
      'icon': Icons.visibility,
      'color': Colors.lightBlueAccent,
      'description': '20-20-20 kuralı hatırlatıcısı',
    },
    'posture': {
      'name': 'Duruş Kontrolü',
      'icon': Icons.accessibility_new,
      'color': Colors.greenAccent,
      'description': 'Oturma pozisyonu kontrolü',
    },
    'water': {
      'name': 'Su İçme',
      'icon': Icons.local_drink,
      'color': Colors.cyanAccent,
      'description': 'Hidrasyon hatırlatıcısı',
    },
    'stretch': {
      'name': 'Esneme',
      'icon': Icons.self_improvement,
      'color': Colors.orangeAccent,
      'description': 'Kas gerginliği giderme',
    },
    'walk': {
      'name': 'Yürüyüş',
      'icon': Icons.directions_walk,
      'color': Colors.purpleAccent,
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

    if (!_titles.contains(_selectedTitle)) {
      _titles.insert(1, _selectedTitle);
    }

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

  // ── Ortak glass-card kabuğu ────────────────────────────────
  // Uygulamanın geri kalanıyla (ör. günün sözü kartı) aynı buzlu cam
  // dilini konuşması için tüm bölümler bunun üzerinden inşa edilir.
  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Kart içi ikon rozeti — accent renk hafif zeminle, tüm sayfada tutarlı.
  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  // Glass zemine uygun ortak input dekorasyonu.
  InputDecoration _glassInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontWeight: FontWeight.w600),
      prefixIcon: Icon(icon, color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.6),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
    );
  }

  Widget _buildUserPersonalizationCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            controller: _nameController,
            decoration: _glassInputDecoration(label: _l10n.nameLabel, icon: Icons.person_outline),
            onChanged: (value) => _userName = value,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedTitle,
            dropdownColor: const Color(0xFF2A2A45),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            decoration: _glassInputDecoration(label: _l10n.titleLabel, icon: Icons.badge_outlined),
            items: _titles
                .map((t) => DropdownMenuItem(value: t, child: Text(_getLocalizedTitle(t))))
                .toList(),
            onChanged: (value) => setState(() => _selectedTitle = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white))),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (settings) {
        _initFromSettings(settings);
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _l10n.settingsTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          body: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: ref.watch(themeProvider).activeGradientColors,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sol Kolon (%48) - Profil, Tema, Dil & Kaydet
                    Expanded(
                      flex: 48,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSectionTitle(_l10n.profileSection, Icons.person),
                            const SizedBox(height: 12),
                            _buildUserPersonalizationCard(),
                            const SizedBox(height: 20),
                            _buildSectionTitle(_l10n.themeSection, Icons.palette_outlined),
                            const SizedBox(height: 12),
                            _buildThemeCard(),
                            const SizedBox(height: 20),
                            _buildSectionTitle(_l10n.languageSection, Icons.language),
                            const SizedBox(height: 12),
                            _buildLanguageCard(),
                            const SizedBox(height: 24),
                            _buildSaveButton(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sağ Kolon (%52) - Hatırlatıcılar, Sessiz Saatler & Sistem
                    Expanded(
                      flex: 52,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            _buildSectionTitle(_l10n.reminderSettingsSection, Icons.notifications),
                            const SizedBox(height: 12),
                            ..._reminderData.entries.map((entry) {
                              return _buildReminderCard(entry.key, entry.value);
                            }),
                            const SizedBox(height: 20),
                            _buildSectionTitle(_l10n.silentHoursSection, Icons.nightlight_round),
                            const SizedBox(height: 12),
                            _buildSilentHoursCard(),
                            const SizedBox(height: 20),
                            _buildSectionTitle(_l10n.systemSettingsSection, Icons.settings),
                            const SizedBox(height: 12),
                            _buildSystemSettingsCard(),
                            const SizedBox(height: 24),
                            DesignerCredits(
                              designerName: "Metehan DER",
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    final accent = ref.watch(themeProvider).activeGradientColors.first;
    return SizedBox(
      width: double.infinity,
      height: 52,
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
        label: Text(_l10n.saveSettings, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: accent,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(String key, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIconBadge(data['icon'], data['color']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getReminderName(key),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _getReminderDesc(key),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.65),
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
                  inactiveThumbColor: Colors.white70,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                ),
              ],
            ),
            if (_enabledReminders[key]!)
              Container(
                margin: const EdgeInsets.only(top: 14),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${_l10n.every} ',
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _intervalControllers[key],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        decoration: InputDecoration(
                          fillColor: Colors.white.withValues(alpha: 0.08),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.white, width: 1.6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
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
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePill(String time, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSilentHoursCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBadge(Icons.nightlight_round, Colors.indigoAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.silentHoursSection,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _l10n.silentHoursDesc,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _l10n.startTimeLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    _buildTimePill(_silentStart.format(context), () async {
                      final time = await showTimePicker(context: context, initialTime: _silentStart);
                      if (time != null) setState(() => _silentStart = time);
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _l10n.endTimeLabel,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    _buildTimePill(_silentEnd.format(context), () async {
                      final time = await showTimePicker(context: context, initialTime: _silentEnd);
                      if (time != null) setState(() => _silentEnd = time);
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemSettingsCard() {
    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBadge(Icons.computer, Colors.tealAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.systemSettingsSection,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _l10n.systemSettingsDesc,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.power_settings_new, color: Colors.tealAccent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.autoStartLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _l10n.autoStartDesc,
                        style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.65)),
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
                  activeThumbColor: Colors.tealAccent,
                  inactiveThumbColor: Colors.white70,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      selectedColor: Colors.white.withValues(alpha: 0.22),
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.white.withValues(alpha: 0.7)),
      side: BorderSide(color: Colors.white.withValues(alpha: selected ? 0.4 : 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildLanguageCard() {
    final currentLocale = ref.watch(appProvider).locale;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBadge(Icons.language, Colors.lightBlueAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _l10n.languageSection,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: _l10n.langTurkish,
                  selected: currentLocale.languageCode == 'tr',
                  onTap: () => ref.read(appProvider.notifier).setLocale(const Locale('tr')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceChip(
                  label: _l10n.langEnglish,
                  selected: currentLocale.languageCode == 'en',
                  onTap: () => ref.read(appProvider.notifier).setLocale(const Locale('en')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard() {
    final themeState = ref.watch(themeProvider);

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildIconBadge(Icons.palette_outlined, Colors.purpleAccent),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _l10n.themeSection,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _l10n.themePaletteLabel,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(ThemeState.palettes.length, (index) {
                final isSelected = themeState.paletteIndex == index;
                final palette = ThemeState.palettes[index];

                return GestureDetector(
                  onTap: () => ref.read(themeProvider.notifier).setPaletteIndex(index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [palette[0], palette[1]],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}