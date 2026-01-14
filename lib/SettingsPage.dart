import 'package:flutter/material.dart';
import 'config.dart';
import 'credits.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, bool> enabledReminders;
  final Map<String, int> reminderIntervals;
  final TimeOfDay silentStart;
  final TimeOfDay silentEnd;
  final bool autoStart;
  // Yeni eklenen alanlar
  final String userName;
  final String selectedTitle;
  final String gender;

  final Function(
    Map<String, bool>,
    Map<String, int>,
    TimeOfDay,
    TimeOfDay,
    bool,
    String, // userName
    String, // selectedTitle
    String, // gender
  )
  onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.enabledReminders,
    required this.reminderIntervals,
    required this.silentStart,
    required this.silentEnd,
    required this.autoStart,
    required this.userName,
    required this.selectedTitle,
    required this.gender,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, bool> _enabledReminders;
  late Map<String, int> _reminderIntervals;
  late TimeOfDay _silentStart;
  late TimeOfDay _silentEnd;
  late bool _autoStart;

  // Form alanları için state değişkenleri
  late String _userName;
  late String _selectedTitle;
  late String _gender;

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

  @override
  void initState() {
    super.initState();
    _enabledReminders = Map.from(widget.enabledReminders);
    _reminderIntervals = Map.from(widget.reminderIntervals);
    _silentStart = widget.silentStart;
    _silentEnd = widget.silentEnd;
    _autoStart = widget.autoStart;
    // Widget'tan gelen ilk değerleri atıyoruz
    _userName = widget.userName;
    _selectedTitle = widget.selectedTitle;
    _gender = widget.gender;
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
            colors: [Colors.white, Colors.teal.withOpacity(0.05)],
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
                decoration: InputDecoration(
                  labelText: 'Adınız',
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  prefixIcon: const Icon(Icons.edit, color: Colors.deepOrange),
                  // Normal Kenarlık
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withOpacity(0.3),
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
                  fillColor: Colors.deepPurple.withOpacity(0.05),
                ),
                controller: TextEditingController(text: _userName)
                  ..selection = TextSelection.collapsed(
                    offset: _userName.length,
                  ),
                onChanged: (value) => _userName = value,
              ),

              const SizedBox(height: 18),

              // Unvan Seçimi
              DropdownButtonFormField<String>(
                value: _selectedTitle,
                dropdownColor: Colors.white, // Menü açıldığında arka plan
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic,
                ),
                decoration: InputDecoration(
                  labelText: 'Hitap Unvanı',
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withOpacity(0.3),
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
                  fillColor: Colors.deepPurple.withOpacity(0.05),
                ),
                items: _titles
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedTitle = value!),
              ),

              const SizedBox(height: 18),

              // Cinsiyet Seçimi
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Cinsiyet',
                  labelStyle: const TextStyle(color: Colors.deepOrange),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: Colors.deepPurple.withOpacity(0.3),
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
                  fillColor: Colors.deepOrange.withOpacity(0.05),
                ),
                items: _genders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar'), elevation: 0),
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
            _buildSectionTitle('Profil Özelleştir', Icons.person),

            _buildUserPersonalizationCard(),

            _buildSectionTitle('Hatırlatıcı Ayarları', Icons.notifications),
            const SizedBox(height: 16),
            ..._reminderData.entries.map((entry) {
              return _buildReminderCard(entry.key, entry.value);
            }).toList(),

            const SizedBox(height: 32),
            _buildSectionTitle('Sessiz Saatler', Icons.nightlight_round),
            const SizedBox(height: 16),
            _buildSilentHoursCard(),

            const SizedBox(height: 32),
            _buildSectionTitle('Sistem Ayarları', Icons.settings),
            const SizedBox(height: 16),
            _buildSystemSettingsCard(),

            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onSettingsChanged(
                    _enabledReminders,
                    _reminderIntervals,
                    _silentStart,
                    _silentEnd,
                    _autoStart,
                    _userName,
                    _selectedTitle,
                    _gender,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Ayarlar başarıyla kaydedildi'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Ayarları Kaydet'),
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
                          data['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          data['description'],
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
                    activeColor: data['color'],
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
                      const Text('Her ', style: TextStyle(fontSize: 16)),
                      Container(
                        width: 80,
                        child: TextField(
                          controller: TextEditingController(
                            text: _reminderIntervals[key].toString(),
                          ),
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
                        ' ${AppConfig.timeUnit}da bir',
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
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: Colors.indigo,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sessiz Saatler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Bu saatler arasında hatırlatıcılar susturulur',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                        const Text(
                          'Başlangıç Saati:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
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
                        const Text(
                          'Bitiş Saati:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
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
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.computer,
                      color: Colors.teal,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistem Ayarları',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Uygulama başlatma ve sistem entegrasyonu',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sistem başlangıcında otomatik çalıştır',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Bilgisayar açıldığında uygulamayı başlat',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                      activeColor: Colors.teal,
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
