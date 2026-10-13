import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsService extends ChangeNotifier {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _voiceEnabled = true;
  String _selectedLanguage = 'vi';
  String _timeLimit = '45';
  bool _isParentUnlocked = false;
  int _starsCount = 12;
  int _freeAiTurns = 3;

  // Getters
  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get voiceEnabled => _voiceEnabled;
  String get selectedLanguage => _selectedLanguage;
  String get timeLimit => _timeLimit;
  bool get isParentUnlocked => _isParentUnlocked;
  int get starsCount => _starsCount;
  int get freeAiTurns => _freeAiTurns;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      final prefs = await _getPrefs();
      _sfxEnabled = prefs.getBool('sfx_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
      _voiceEnabled = prefs.getBool('voice_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'vi';
      _timeLimit = prefs.getString('time_limit') ?? '45';
      _starsCount = prefs.getInt('stars_count') ?? 12;
      _freeAiTurns = prefs.getInt('free_ai_turns') ?? 3;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing AppSettingsService: $e');
    }
  }

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setBool('sfx_enabled', value);
    } catch (e) {
      debugPrint('Error saving sfxEnabled: $e');
    }
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setBool('music_enabled', value);
    } catch (e) {
      debugPrint('Error saving musicEnabled: $e');
    }
  }

  Future<void> setVoiceEnabled(bool value) async {
    _voiceEnabled = value;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setBool('voice_enabled', value);
    } catch (e) {
      debugPrint('Error saving voiceEnabled: $e');
    }
  }

  Future<void> setSelectedLanguage(String code) async {
    _selectedLanguage = code;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setString('selected_language', code);
    } catch (e) {
      debugPrint('Error saving selectedLanguage: $e');
    }
  }

  Future<void> setTimeLimit(String limit) async {
    _timeLimit = limit;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setString('time_limit', limit);
    } catch (e) {
      debugPrint('Error saving timeLimit: $e');
    }
  }

  void setParentUnlocked(bool unlocked) {
    _isParentUnlocked = unlocked;
    notifyListeners();
  }

  Future<void> addStars(int count) async {
    _starsCount += count;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setInt('stars_count', _starsCount);
    } catch (e) {
      debugPrint('Error saving starsCount: $e');
    }
  }

  Future<void> addAiTurn(int count) async {
    _freeAiTurns += count;
    notifyListeners();
    try {
      final prefs = await _getPrefs();
      await prefs.setInt('free_ai_turns', _freeAiTurns);
    } catch (e) {
      debugPrint('Error saving freeAiTurns: $e');
    }
  }

  Future<bool> useAiTurn() async {
    if (_freeAiTurns > 0) {
      _freeAiTurns--;
      notifyListeners();
      try {
        final prefs = await _getPrefs();
        await prefs.setInt('free_ai_turns', _freeAiTurns);
      } catch (e) {
        debugPrint('Error saving freeAiTurns: $e');
      }
      return true;
    }
    return false;
  }
}
