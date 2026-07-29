import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StorageService _storage;

  SettingsRepositoryImpl(this._storage);

  @override
  Future<SettingsEntity> getSettings() async {
    return SettingsEntity(
      userName: _storage.getString('userName', defaultValue: ''),
      userTitle: _storage.getString('userTitle', defaultValue: 'Yok'),
      gender: _storage.getString('gender', defaultValue: 'Belirtilmemiş'),
      autoStart: _storage.getBool('autoStart', defaultValue: false),
      silentStart: _parseTimeOfDay(_storage.getString('silentStart', defaultValue: '22:00'), const TimeOfDay(hour: 22, minute: 0)),
      silentEnd: _parseTimeOfDay(_storage.getString('silentEnd', defaultValue: '08:00'), const TimeOfDay(hour: 8, minute: 0)),
      enabledReminders: {
        'eyeRest': _storage.getBool('reminder_eyeRest', defaultValue: true),
        'posture': _storage.getBool('reminder_posture', defaultValue: true),
        'water': _storage.getBool('reminder_water', defaultValue: true),
        'stretch': _storage.getBool('reminder_stretch', defaultValue: true),
        'walk': _storage.getBool('reminder_walk', defaultValue: true),
      },
      reminderIntervals: {
        'eyeRest': _storage.getInt('interval_eyeRest', defaultValue: 20),
        'posture': _storage.getInt('interval_posture', defaultValue: 30),
        'water': _storage.getInt('interval_water', defaultValue: 45),
        'stretch': _storage.getInt('interval_stretch', defaultValue: 60),
        'walk': _storage.getInt('interval_walk', defaultValue: 90),
      },
      isOnboardingCompleted: _storage.getBool('isOnboardingCompleted', defaultValue: false),
    );
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    await _storage.setString('userName', settings.userName);
    await _storage.setString('userTitle', settings.userTitle);
    await _storage.setString('gender', settings.gender);
    await _storage.setBool('autoStart', settings.autoStart);
    await _storage.setBool('isOnboardingCompleted', settings.isOnboardingCompleted);
    
    await _storage.setString('silentStart', _formatTimeOfDay(settings.silentStart));
    await _storage.setString('silentEnd', _formatTimeOfDay(settings.silentEnd));

    for (var entry in settings.enabledReminders.entries) {
      await _storage.setBool('reminder_${entry.key}', entry.value);
    }

    for (var entry in settings.reminderIntervals.entries) {
      await _storage.setInt('interval_${entry.key}', entry.value);
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr, TimeOfDay defaultValue) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (_) {}
    return defaultValue;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
