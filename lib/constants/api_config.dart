// API 서버 주소 설정
// 백엔드 API 베이스 URL (api_config_io / api_config_stub 에서 정의)

// dart:io의 Platform은 웹에서 사용 불가 → 조건부 import
import 'api_config_stub.dart'
    if (dart.library.io) 'api_config_io.dart' as impl;

/// 백엔드 API 베이스 URL (원격 서버)
String get apiBaseUrl => impl.getApiBaseUrl;
