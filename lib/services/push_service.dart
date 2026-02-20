// FCM 푸시 알림 서비스 파일
// Firebase Cloud Messaging 토큰 발급, 백엔드 등록, 푸시 수신 및 알림 탭 시 채팅 화면 이동을 담당한다

import 'dart:convert';
import 'push_platform_stub.dart'
    if (dart.library.io) 'push_platform_io.dart' as platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'auth_service.dart';
import 'stock_api_service.dart';
import 'notification_store.dart';
import '../screens/open_chat_from_push_screen.dart';

/// FCM 푸시 알림을 처리하는 서비스 (정적 메서드 위주)
/// 앱 시작 시 setup() 호출, 로그인 후 registerTokenWithBackend() 호출
class PushService {
  static final StockApiService _api = StockApiService();

  /// 포그라운드 수신 시 앱 내 로컬 알림 표시용
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 알림 탭 시 라우팅에 사용할 네비게이터 키 (MaterialApp에서 설정)
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState>? key) {
    _navigatorKey = key;
  }

  /// Firebase 초기화 및 FCM 리스너 등록
  /// main()에서 runApp 전에 호출한다. iOS/Android에서만 유효.
  static Future<void> setup() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('⚠️ Firebase 초기화 실패 (웹/미설정 시 무시): $e');
      return;
    }

    // 알림 권한 요청 (iOS, Android 13+)
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 로컬 알림 초기화 (포그라운드 푸시 시 알림 표시용)
    await _initLocalNotifications();

    // Android 13+ 상단 알림 표시를 위한 런타임 권한 요청 (POST_NOTIFICATIONS)
    await _requestNotificationPermission();

    // 앱이 종료된 상태에서 알림 탭으로 실행된 경우
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _addPushToStore(initialMessage);
      _handleMessageData(initialMessage.data);
    }

    // 앱이 백그라운드에 있다가 알림 탭으로 복귀한 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addPushToStore(message);
      _handleMessageData(message.data);
    });

    // 포그라운드에서 푸시 수신 시 알림 목록에 추가 + 로컬 알림 표시
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 포그라운드 푸시: ${message.notification?.title} / ${message.notification?.body}');
      if (message.data.isNotEmpty) {
        print('   data: ${message.data}');
      }
      _addPushToStore(message);
      _showLocalNotification(
        title: message.notification?.title ?? '알림',
        body: message.notification?.body ?? '',
        data: message.data,
      );
    });

    // 토큰 갱신 시 (재등록은 앱 실행 시 registerTokenWithBackend에서 수행)
    messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM 토큰 갱신됨');
      if (AuthService.instance.hasToken) {
        _registerToken(newToken);
      }
    });
  }

  /// 로컬 알림 플러그인 초기화 및 채널 생성, 알림 탭 콜백 등록
  static Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        try {
          final data = json.decode(response.payload!) as Map<String, dynamic>;
          _handleMessageData(Map<String, dynamic>.from(data));
        } catch (_) {}
      },
    );
    // Android 알림 채널 (Android 8.0+ 필수) — importance 높게 해서 상단/헤드업 표시
    const channel = AndroidNotificationChannel(
      'stock_push_channel',
      '주식 알림',
      description: '가격·공시 등 푸시 알림',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Android 13+ POST_NOTIFICATIONS 런타임 권한 요청 (상단 알림 표시에 필요)
  static Future<void> _requestNotificationPermission() async {
    final android = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  /// 포그라운드에서 수신한 푸시를 로컬 알림으로 표시 (data는 탭 시 채팅 이동에 사용)
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'stock_push_channel',
      '주식 알림',
      channelDescription: '가격·공시 등 푸시 알림',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = data.isEmpty ? null : json.encode(data);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 수신한 푸시를 알림 목록(NotificationStore)에 추가 — 알림 화면·배지에 반영
  static void _addPushToStore(RemoteMessage message) {
    final title = message.notification?.title ?? '알림';
    final body = message.notification?.body ?? '';
    final portfolioIdStr = message.data['portfolioId']?.toString();
    final portfolioId = portfolioIdStr != null ? int.tryParse(portfolioIdStr) : null;
    NotificationStore.instance.add(
      title: title,
      body: body,
      portfolioId: portfolioId,
    );
  }

  /// data 맵에서 portfolioId가 있으면 해당 종목 채팅 화면으로 이동
  static void _handleMessageData(Map<String, dynamic> data) {
    final portfolioIdStr = data['portfolioId']?.toString();
    if (portfolioIdStr == null || portfolioIdStr.isEmpty) return;

    final portfolioId = int.tryParse(portfolioIdStr);
    if (portfolioId == null) return;

    _navigateToChat(portfolioId);
  }

  /// 해당 portfolioId의 채팅 화면으로 푸시 (로딩 화면 경유 후 포트폴리오 조회)
  static void _navigateToChat(int portfolioId) {
    final state = _navigatorKey?.currentState;
    if (state == null || !state.mounted) {
      print('⚠️ 네비게이터를 사용할 수 없어 채팅으로 이동하지 못함');
      return;
    }
    state.push(
      MaterialPageRoute<void>(
        builder: (context) => OpenChatFromPushScreen(portfolioId: portfolioId),
      ),
    );
  }

  /// FCM 토큰을 발급받아 백엔드에 등록한다
  /// 로그인 직후 또는 앱 실행 시(이미 로그인된 경우) 한 번 호출한다.
  static Future<void> registerTokenWithBackend() async {
    if (!AuthService.instance.hasToken) {
      print('⚠️ JWT 없음, FCM 토큰 미등록');
      return;
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ FCM 토큰을 받지 못함');
        return;
      }
      await _registerToken(token);
    } catch (e) {
      print('❌ FCM 토큰 등록 중 오류: $e');
    }
  }

  static Future<void> _registerToken(String token) async {
    final platformName = platform.pushPlatform;
    final success = await _api.registerPushToken(token, platformName);
    if (!success) {
      print('⚠️ FCM 토큰 백엔드 등록 실패');
    }
  }
}
