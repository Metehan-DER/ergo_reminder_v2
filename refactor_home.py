import re

with open('lib/presentation/pages/home_page.dart', 'r') as f:
    content = f.read()

# Make it ConsumerStatefulWidget
content = content.replace("class HomePage extends StatefulWidget {", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/app_provider.dart';\nimport '../providers/timer_provider.dart';\nimport '../providers/settings_provider.dart';\nimport 'settings_page.dart';\n\nclass HomePage extends ConsumerStatefulWidget {")
content = content.replace("State<HomePage> createState() => _HomePageState();", "ConsumerState<HomePage> createState() => _HomePageState();")

# Find the class start
class_start_idx = content.find('class _HomePageState extends State<HomePage>')

# Find the build method
build_idx = content.find('  @override\n  Widget build(BuildContext context) {')

# The part after build method
body = content[build_idx:]

# New header
header = '''class _HomePageState extends ConsumerState<HomePage> {
  late AppLocalizations _l10n;
  Locale? _lastLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);

    final currentLocale = Localizations.localeOf(context);
    if (_lastLocale != currentLocale) {
      _lastLocale = currentLocale;
    }
  }

  String _getGreeting(String userName, String selectedTitle) {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour >= 5 && hour < 12) {
      timeGreeting = "Günaydın";
    } else if (hour >= 12 && hour < 18) {
      timeGreeting = "İyi Günler";
    } else if (hour >= 18 && hour < 22) {
      timeGreeting = "İyi Akşamlar";
    } else {
      timeGreeting = "İyi Geceler";
    }

    String titlePart = (selectedTitle != "Yok") ? "$selectedTitle " : "";

    return "$timeGreeting, $titlePart$userName \\nSağlığınız Korunuyor...";
  }

  void _showReminderDialog(String id, String title, String body, int snoozed, int ignored, int completed, Function(String) onSnooze, Function(String) onDone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              onSnooze(id);
              Navigator.pop(ctx);
            },
            child: Text("Ertele"),
          ),
          ElevatedButton(
            onPressed: () {
              onDone(id);
              Navigator.pop(ctx);
            },
            child: Text("Tamamla"),
          ),
        ],
      ),
    );
  }
'''

new_content = content[:class_start_idx] + header + body

# Replace state accesses inside body
new_content = new_content.replace('_isRunning', 'ref.watch(appProvider).isRunning')
new_content = new_content.replace('_startTracking();', 'ref.read(appProvider.notifier).setRunning(true);')
new_content = new_content.replace('_stopTracking();', 'ref.read(appProvider.notifier).setRunning(false);')
new_content = new_content.replace('_getGreeting()', '_getGreeting(settings.userName, settings.userTitle)')
new_content = new_content.replace('settings.userTitle', 'settings.userTitle') # just in case

# Fix the settings page navigation
nav_pattern = re.compile(r'Navigator\.push\(\n\s*context,\n\s*MaterialPageRoute\(\n\s*builder: \(context\) => SettingsPage\(.*?\),\n\s*\),\n\s*\);', re.DOTALL)
new_content = nav_pattern.sub('Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));', new_content)

# We need to wrap Scaffold in settingsAsync.when
build_start = '''  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final timerState = ref.watch(timerProvider);
    
    ref.listen(timerProvider.select((s) => s.dialogQueue), (prev, next) {
      if (next.isNotEmpty && (prev == null || prev.isEmpty || prev.first != next.first)) {
          final id = next.first;
          _showReminderDialog(
             id, 
             "Hatırlatıcı", 
             "Mola zamanı geldi: $id", 
             0, 0, 0, 
             (id) => ref.read(timerProvider.notifier).snoozeReminder(id),
             (id) => ref.read(timerProvider.notifier).removeFirstFromQueue()
          );
      }
    });

    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (settings) {
        final _enabledReminders = settings.enabledReminders;
        final _reminderIntervals = settings.reminderIntervals;
        final _timeElapsed = timerState.timeElapsed;
        final _totalRemindersToday = 0; // TODO: fetch from stats provider
        final _totalPostponedToday = 0;
        final _workMinutes = timerState.timeElapsed.values.fold(0, (a, b) => a + b);

'''
new_content = new_content.replace('  @override\n  Widget build(BuildContext context) {', build_start)
new_content = new_content.replace('return Scaffold(', 'return Scaffold(') # This is inside data
new_content = new_content.replace('    return Scaffold(', '    return Scaffold(') # This is inside data

# Fix the end of build method
new_content = new_content.replace('      ),\n    );\n  }\n\n  Widget _buildReminderCard', '      ),\n    );\n    });\n  }\n\n  Widget _buildReminderCard')

# There might be accesses to _reminderNames, _reminderIcons, _reminderColors in _buildReminderCard which I removed.
# Let's add them back to the class header:
reminders_maps = '''
  final Map<String, String> _reminderNames = {
    'eyeRest': 'Göz Dinlendirme',
    'posture': 'Duruş',
    'water': 'Su İçme',
    'stretch': 'Esneme',
    'walk': 'Yürüyüş',
  };
  final Map<String, IconData> _reminderIcons = {
    'eyeRest': Icons.visibility,
    'posture': Icons.accessibility_new,
    'water': Icons.local_drink,
    'stretch': Icons.self_improvement,
    'walk': Icons.directions_walk,
  };
  final Map<String, Color> _reminderColors = {
    'eyeRest': Colors.blue,
    'posture': Colors.green,
    'water': Colors.cyan,
    'stretch': Colors.orange,
    'walk': Colors.purple,
  };
'''
new_content = new_content.replace('  late AppLocalizations _l10n;', reminders_maps + '  late AppLocalizations _l10n;')


with open('lib/presentation/pages/home_page.dart', 'w') as f:
    f.write(new_content)
