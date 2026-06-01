import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const _keyMeal = 'notif_meal';
  static const _keyShopping = 'notif_shopping';
  static const _keyCommunity = 'notif_community';
  static const _keyAiGeneration = 'notif_ai_generation';
  static const _keyMealHour = 'notif_meal_hour';
  static const _keyMealMinute = 'notif_meal_minute';

  bool _mealReminder = false;
  bool _shoppingReminder = false;
  bool _communityNotif = false;
  bool _aiGenerationNotif = true;
  int _mealReminderHour = 8;
  int _mealReminderMinute = 0;

  bool get mealReminder => _mealReminder;
  bool get shoppingReminder => _shoppingReminder;
  bool get communityNotif => _communityNotif;
  bool get aiGenerationNotif => _aiGenerationNotif;
  int get mealReminderHour => _mealReminderHour;
  int get mealReminderMinute => _mealReminderMinute;

  String get mealReminderTimeString =>
      '${_mealReminderHour.toString().padLeft(2, '0')}:${_mealReminderMinute.toString().padLeft(2, '0')}';

  NotificationProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _mealReminder = prefs.getBool(_keyMeal) ?? false;
    _shoppingReminder = prefs.getBool(_keyShopping) ?? false;
    _communityNotif = prefs.getBool(_keyCommunity) ?? false;
    _aiGenerationNotif = prefs.getBool(_keyAiGeneration) ?? true;
    _mealReminderHour = prefs.getInt(_keyMealHour) ?? 8;
    _mealReminderMinute = prefs.getInt(_keyMealMinute) ?? 0;
    notifyListeners();
  }

  Future<void> toggleMealReminder(bool value) async {
    _mealReminder = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMeal, value);

    if (value) {
      await NotificationService().scheduleDailyMealReminder(
          _mealReminderHour, _mealReminderMinute);
    } else {
      await NotificationService().cancel(NotificationId.mealReminder);
    }
    notifyListeners();
  }

  Future<void> updateMealReminderTime(int hour, int minute) async {
    _mealReminderHour = hour;
    _mealReminderMinute = minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMealHour, hour);
    await prefs.setInt(_keyMealMinute, minute);

    if (_mealReminder) {
      await NotificationService().scheduleDailyMealReminder(hour, minute);
    }
    notifyListeners();
  }

  Future<void> toggleShoppingReminder(bool value) async {
    _shoppingReminder = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShopping, value);
    if (!value) await NotificationService().cancel(NotificationId.shoppingReminder);
    notifyListeners();
  }

  Future<void> toggleCommunityNotif(bool value) async {
    _communityNotif = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCommunity, value);
    if (!value) await NotificationService().cancel(NotificationId.communityLike);
    notifyListeners();
  }

  Future<void> toggleAiGenerationNotif(bool value) async {
    _aiGenerationNotif = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAiGeneration, value);
    if (!value) await NotificationService().cancel(NotificationId.aiGenerationComplete);
    notifyListeners();
  }
}
