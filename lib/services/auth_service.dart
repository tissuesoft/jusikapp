// 인증(Auth) 서비스 파일
// 카카오 로그인 후 발급받은 JWT 토큰을 앱 전역에서 관리한다
// JWT는 flutter_secure_storage에 저장하여 안전하게 보관한다
// 싱글톤 패턴으로 구현하여 어디서든 동일한 인스턴스에 접근 가능

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// JWT 저장소 키 (secure storage 및 마이그레이션용 SharedPreferences 키)
const String _tokenStorageKey = 'jwt_token';
const String _legacyTokenKey = 'kakao_access_token';

/// AuthService: JWT 토큰을 저장하고 제공하는 싱글톤 클래스
/// 모든 API 요청에 Authorization: Bearer {token} 헤더로 사용한다
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  static AuthService get instance => _instance;

  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? _jwtToken;

  /// 앱 시작 시 secure storage에서 JWT 로드. 기존 SharedPreferences 값이 있으면 이전 후 secure로 저장
  Future<void> initialize() async {
    _jwtToken = await _secureStorage.read(key: _tokenStorageKey);
    if (_jwtToken != null) return;
    // 마이그레이션: 예전에 SharedPreferences에 저장된 토큰이 있으면 secure로 옮김
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_legacyTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await setToken(legacy);
      await prefs.remove(_legacyTokenKey);
    }
  }

  String? get jwtToken => _jwtToken;

  /// JWT 저장 (secure storage + 메모리)
  Future<void> setToken(String token) async {
    _jwtToken = token;
    await _secureStorage.write(key: _tokenStorageKey, value: token);
  }

  /// 로그아웃 시 토큰 삭제
  Future<void> clearToken() async {
    _jwtToken = null;
    await _secureStorage.delete(key: _tokenStorageKey);
  }

  bool get hasToken => _jwtToken != null && _jwtToken!.isNotEmpty;

  /// API 요청 시 사용할 인증 헤더 (Authorization: Bearer <토큰>)
  Map<String, String> get authHeaders {
    if (_jwtToken != null) {
      return {'Authorization': 'Bearer $_jwtToken'};
    }
    return {};
  }
}
