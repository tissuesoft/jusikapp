// 알림 수신 on/off 설정 저장
// SharedPreferences에 저장하여 앱 재시작 후에도 유지된다

import 'package:shared_preferences/shared_preferences.dart';

/// 알림 수신 허용 여부를 저장·조회하는 정적 헬퍼
/// on: 푸시 수신 시 알림 표시 및 목록 저장, off: 표시·저장하지 않음
class NotificationPreferences {
  static const String _key = 'notification_enabled';

  /// 알림 수신 허용 여부 (기본값 true)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  /// 알림 수신 허용 여부 저장
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
