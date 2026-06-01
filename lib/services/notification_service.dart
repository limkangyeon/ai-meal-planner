import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 알림 ID 상수
class NotificationId {
  static const int mealReminder = 1;
  static const int shoppingReminder = 2;
  static const int communityLike = 3;
  static const int aiGenerationComplete = 4;
}

/// Android 알림 채널 ID
class NotificationChannel {
  static const String mealReminder = 'meal_reminder';
  static const String shoppingReminder = 'shopping_reminder';
  static const String community = 'community';
  static const String aiGeneration = 'ai_generation';
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('알림 탭: ${details.payload}');
      },
    );

    await _createAndroidChannels();
    _initialized = true;
  }

  Future<void> _createAndroidChannels() async {
    if (!defaultTargetPlatform.name.contains('android') &&
        defaultTargetPlatform != TargetPlatform.android) return;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      NotificationChannel.mealReminder, '식단 리마인더',
      description: '매일 식단 확인 알림',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      NotificationChannel.shoppingReminder, '장보기 리마인더',
      description: '장보기 목록 알림',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      NotificationChannel.community, '커뮤니티',
      description: '좋아요, 공유 알림',
      importance: Importance.defaultImportance,
    ));
    await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
      NotificationChannel.aiGeneration, 'AI 식단 생성',
      description: '식단 생성 완료 알림',
      importance: Importance.high,
    ));
  }

  NotificationDetails _details(String channelId, {Importance importance = Importance.defaultImportance}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId, channelId,
        importance: importance,
        priority: Priority.defaultPriority,
      ),
    );
  }

  /// 즉시 알림 표시
  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    if (!_initialized) await initialize();
    await _plugin.show(id, title, body, _details(channelId), payload: payload);
  }

  /// 매일 특정 시간에 반복 알림 스케줄
  Future<void> scheduleDailyMealReminder(int hour, int minute) async {
    if (!_initialized) await initialize();

    await _plugin.cancel(NotificationId.mealReminder);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      NotificationId.mealReminder,
      '오늘의 식단을 확인해보세요! 🍽️',
      '건강한 하루를 위한 맞춤 식단이 준비되어 있어요.',
      scheduled,
      _details(NotificationChannel.mealReminder),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 장보기 리마인더
  Future<void> showShoppingReminder(int ingredientCount) async {
    await show(
      id: NotificationId.shoppingReminder,
      title: '장보기 목록이 있어요 🛒',
      body: '식단에 필요한 재료 $ingredientCount가지를 구매해보세요.',
      channelId: NotificationChannel.shoppingReminder,
    );
  }

  /// 커뮤니티 좋아요 알림
  Future<void> showCommunityLike(String planTitle) async {
    await show(
      id: NotificationId.communityLike,
      title: '누군가 식단을 좋아해요! ❤️',
      body: '"$planTitle"에 좋아요가 달렸습니다.',
      channelId: NotificationChannel.community,
    );
  }

  /// AI 식단 생성 완료 알림
  Future<void> showGenerationComplete() async {
    await show(
      id: NotificationId.aiGenerationComplete,
      title: 'AI 식단 생성 완료! 🎉',
      body: '맞춤 식단이 준비됐어요. 지금 확인해보세요.',
      channelId: NotificationChannel.aiGeneration,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Android 알림 권한 요청
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }
}
