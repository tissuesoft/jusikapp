// FCM 플랫폼 감지 (Android/iOS - dart:io 사용)
import 'dart:io' show Platform;

String get pushPlatform => Platform.isIOS ? 'ios' : 'android';
