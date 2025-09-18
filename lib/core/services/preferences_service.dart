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
}
