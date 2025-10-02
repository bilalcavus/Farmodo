import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _firstLaunchKey = 'first_launch';
  
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  static PreferencesService get instance => _instance ??= PreferencesService._();
  
  PreferencesService._();

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool get isOnboardingCompleted {
    return _prefs?.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs?.setBool(_onboardingCompletedKey, completed) ?? false;
  }

  bool get isFirstLaunch {
    return _prefs?.getBool(_firstLaunchKey) ?? true;
  }

  Future<bool> setFirstLaunch(bool isFirst) async {
    return await _prefs?.setBool(_firstLaunchKey, isFirst) ?? false;
  }

  Future<bool> clearOnboardingData() async {
    final result1 = await _prefs?.remove(_onboardingCompletedKey) ?? false;
    final result2 = await _prefs?.remove(_firstLaunchKey) ?? false;
    return result1 && result2;
  }

  Set<String> getAllKeys() {
    return _prefs?.getKeys() ?? {};
  }

  // Generic methods for boolean preferences
  bool getBool(String key, bool defaultValue) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // Generic methods for string preferences
  String getString(String key, String defaultValue) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // Generic methods for integer preferences
  int getInt(String key, int defaultValue) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // Generic methods for double preferences
  double getDouble(String key, double defaultValue) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // Remove a specific key
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Clear all preferences
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}
