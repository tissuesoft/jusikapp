// 인증(Auth) 서비스 파일
// 카카오 로그인 후 발급받은 JWT 토큰을 앱 전역에서 관리한다
// 싱글톤 패턴으로 구현하여 어디서든 동일한 인스턴스에 접근 가능

import 'package:shared_preferences/shared_preferences.dart';

/// AuthService: JWT 토큰을 저장하고 제공하는 싱글톤 클래스
/// 싱글톤(Singleton): 앱 전체에서 딱 하나의 인스턴스만 존재하는 패턴
/// → 어디서든 AuthService.instance로 같은 객체에 접근 가능
class AuthService {
  // _instance: 클래스 내부에서만 접근 가능한 유일한 인스턴스
  // static: 클래스 자체에 속하는 변수 (객체 생성 없이 접근 가능)
  static final AuthService _instance = AuthService._internal();

  // factory 생성자: new AuthService()를 호출해도 항상 같은 _instance를 반환
  // → 여러 곳에서 AuthService()를 호출해도 동일한 객체
  factory AuthService() => _instance;

  // instance getter: AuthService.instance로 간편하게 접근
  static AuthService get instance => _instance;

  // _internal: 외부에서 직접 생성할 수 없도록 하는 프라이빗 생성자
  AuthService._internal();

  // 로컬 저장소 키
  static const String _tokenKey = 'kakao_access_token';

  // JWT 토큰을 저장하는 변수 (로그인 전에는 null)
  String? _jwtToken;

  /// 초기화 메서드 - 앱 시작 시 로컬 저장소에서 토큰 불러오기
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _jwtToken = prefs.getString(_tokenKey);
  }

  /// JWT 토큰 getter - 저장된 토큰을 반환
  String? get jwtToken => _jwtToken;

  /// JWT 토큰 저장 메서드
  /// 카카오 로그인 성공 후 서버에서 발급받은 토큰을 메모리와 로컬 저장소에 저장한다
  Future<void> setToken(String token) async {
    _jwtToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// JWT 토큰 삭제 메서드
  /// 로그아웃 시 호출하여 토큰을 메모리와 로컬 저장소에서 제거한다
  Future<void> clearToken() async {
    _jwtToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// 토큰 존재 여부 확인
  /// 로그인 상태인지 판별할 때 사용
  bool get hasToken => _jwtToken != null && _jwtToken!.isNotEmpty;

  /// API 요청에 사용할 인증 헤더를 반환
  /// Authorization: Bearer <토큰> 형태로 헤더를 구성한다
  /// 토큰이 없으면 빈 Map 반환
  Map<String, String> get authHeaders {
    if (_jwtToken != null) {
      return {'Authorization': 'Bearer $_jwtToken'};
    }
    return {};
  }
}
