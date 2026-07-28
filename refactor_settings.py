import re

with open('lib/presentation/pages/settings_page.dart', 'r') as f:
    content = f.read()

# 1. Imports
content = content.replace("import 'l10n/app_localizations.dart';", "import '../../l10n/app_localizations.dart';")
content = content.replace("import 'config.dart';", "import '../../core/config/app_config.dart';")
content = content.replace("import 'credits.dart';", "import '../widgets/designer_credits.dart';")
content = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../providers/settings_provider.dart';\nimport '../../domain/entities/settings_entity.dart';\n" + content

# 2. Convert StatefulWidget to ConsumerStatefulWidget
content = content.replace("class SettingsPage extends StatefulWidget {", "class SettingsPage extends ConsumerStatefulWidget {")
content = content.replace("State<SettingsPage> createState() => _SettingsPageState();", "ConsumerState<SettingsPage> createState() => _SettingsPageState();")
content = content.replace("class _SettingsPageState extends State<SettingsPage> {", "class _SettingsPageState extends ConsumerState<SettingsPage> {")

# 3. Remove constructor variables
constructor_pattern = re.compile(r'  final Map<String, bool> enabledReminders;.*?  const SettingsPage\(\{.*?\}\);', re.DOTALL)
content = constructor_pattern.sub('  const SettingsPage({super.key});', content)

# 4. Modify initState and add _isInitialized flag
init_state_pattern = re.compile(r'  @override\n  void initState\(\) \{.*?  \}', re.DOTALL)
content = init_state_pattern.sub('''  bool _isInitialized = false;

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
  
  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _intervalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }''', content)

# 5. Modify build method to check for async value
build_pattern = re.compile(r'  @override\n  Widget build\(BuildContext context\) \{.*?return Scaffold\(', re.DOTALL)
content = build_pattern.sub('''  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    
    return settingsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (settings) {
        _initFromSettings(settings);
        return Scaffold(''
''', content)
content = content.replace('Scaffold(', 'Scaffold(\n') # Ensure we don't double replace but regex already replaced the first Scaffold

# 6. Modify the save button
save_pattern = re.compile(r'                onPressed: \(\) \{.*?                \},', re.DOTALL)
new_save = '''                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  
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
                },'''
content = save_pattern.sub(new_save, content, count=1)

with open('lib/presentation/pages/settings_page.dart', 'w') as f:
    f.write(content)
