import 'package:flutter/foundation.dart';
import '../../core/models/settings.dart';
import '../../core/utils/storage_service.dart';

/// Pure data layer for settings.
class SettingsService {
  Future<Settings> load()            => StorageService.loadSettings();
  Future<bool> save(Settings s)      => StorageService.saveSettings(s);
}

/// Exposes settings state to the UI.
class SettingsController extends ChangeNotifier {
  final SettingsService _service;

  Settings _settings = Settings.defaults();
  bool    _isLoading = false;
  String? _error;

  SettingsController({SettingsService? service})
      : _service = service ?? SettingsService();

  Settings get settings  => _settings;
  bool    get isLoading  => _isLoading;
  String? get error      => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _service.load();
      _error = null;
    } catch (e) {
      _error = 'Failed to load settings: $e';
      debugPrint('SettingsController.initialize: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings(Settings settings) async {
    try {
      await _service.save(settings);
      _settings = settings;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to save settings: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
