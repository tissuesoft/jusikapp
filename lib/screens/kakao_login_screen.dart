// 카카오톡 로그인 화면 파일
// 스플래시 화면 이후 카카오톡 로그인 UI를 표시
// 로그인 성공 시 사용자 정보를 가져와 온보딩 화면으로 이동

import 'package:flutter/material.dart';
// 카카오 로그인 및 사용자 정보 조회를 위한 SDK import
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/colors.dart';
import '../constants/api_config.dart';
// JWT 토큰 관리를 위한 AuthService import
import '../services/auth_service.dart';

/// 카카오톡 로그인 화면 위젯 (StatefulWidget)
/// StatefulWidget: 화면 내부 상태(로딩 여부 등)가 변할 수 있는 위젯
/// 카카오톡 로고, 앱 설명, 카카오톡 로그인 버튼으로 구성
class KakaoLoginScreen extends StatefulWidget {
  const KakaoLoginScreen({super.key});

  /// createState(): StatefulWidget이 생성될 때 호출되어 State 객체를 만듦
  /// → _KakaoLoginScreenState로 이동
  @override
  State<KakaoLoginScreen> createState() => _KakaoLoginScreenState();
}

/// _KakaoLoginScreenState: KakaoLoginScreen의 상태를 관리하는 클래스
/// State<T>: StatefulWidget의 상태를 저장하고 UI를 다시 그릴 수 있게 해줌
class _KakaoLoginScreenState extends State<KakaoLoginScreen> {
  // 로딩 상태 변수 - 로그인 진행 중일 때 true로 변경하여 버튼을 비활성화
  bool _isLoading = false;

  /// build(): 화면 UI를 구성하는 메서드 (Flutter가 자동 호출)
  /// → Scaffold 위젯으로 전체 화면 레이아웃 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 흰색 배경
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 앱 로고 영역
              _buildAppLogo(),
              const SizedBox(height: 32),
              // 앱 이름
              const Text(
                'Stock Analysis AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // 앱 설명
              Text(
                'AI 기반 주식 분석으로\n더 스마트한 투자를 시작하세요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 3),
              // 카카오톡 로그인 버튼
              _buildKakaoLoginButton(context),
              const SizedBox(height: 16),
              // 이용약관 텍스트
              _buildTermsText(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget: Flutter UI의 기본 단위, 화면에 보이는 모든 것은 Widget
  /// _buildAppLogo(): 앱 로고를 만드는 메서드 (파란색 배경에 흰색 N 텍스트)
  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }

  /// _buildKakaoLoginButton(): 카카오톡 로그인 버튼 위젯
  /// 노란색 배경에 카카오톡 로고와 텍스트, 로딩 중에는 로딩 인디케이터 표시
  Widget _buildKakaoLoginButton(BuildContext context) {
    return InkWell(
      // _isLoading이 true이면 버튼 클릭 비활성화 (중복 클릭 방지)
      onTap: _isLoading ? null : () => _onKakaoLoginTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          // 카카오톡 브랜드 컬러
          color: const Color(0xFFFFE812),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로딩 중이면 로딩 인디케이터 표시, 아니면 카카오 로고 표시
            if (_isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black54,
                ),
              )
            else
              // 카카오톡 로고 (간단한 아이콘으로 대체)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'K',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFFE812),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            // 로그인 텍스트 - 로딩 중이면 "로그인 중..." 표시
            Text(
              _isLoading ? '로그인 중...' : '카카오톡으로 시작하기',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// _buildTermsText(): 이용약관 텍스트 위젯
  /// 개인정보 처리방침 및 서비스 이용약관 안내
  Widget _buildTermsText() {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: '로그인 시 '),
          TextSpan(
            text: '이용약관',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.grey.shade600,
            ),
          ),
          const TextSpan(text: ' 및 '),
          TextSpan(
            text: '개인정보 처리방침',
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.grey.shade600,
            ),
          ),
          const TextSpan(text: '에\n동의하는 것으로 간주됩니다.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// _onKakaoLoginTap(): 카카오톡 로그인 버튼 클릭 시 호출되는 메서드
  /// async: 비동기 함수 표시 - 네트워크 요청 등 시간이 걸리는 작업을 처리
  /// 로그인 흐름:
  /// 1. 카카오톡 앱 설치 여부 확인
  /// 2. 설치됨 → 카카오톡 앱으로 로그인 / 미설치 → 카카오 계정(웹)으로 로그인
  /// 3. 로그인 성공 후 사용자 정보(닉네임, 프로필) 가져오기
  /// 4. 온보딩 화면으로 사용자 정보 전달하며 이동
  Future<void> _onKakaoLoginTap(BuildContext context) async {
    // setState(): State의 값이 변경되었음을 Flutter에 알려 화면을 다시 그림
    setState(() => _isLoading = true);

    try {
      // ===== 1단계: 카카오톡 로그인 =====
      // scopes: 로그인 시 요청할 권한 목록
      // 'profile_nickname' - 닉네임, 'profile_image' - 프로필 사진
      // 'account_email' - 이메일 (선택사항)
      // ※ 카카오 개발자 사이트 > 동의항목에서도 해당 항목을 활성화해야 함
      List<String> scopes = ['profile_nickname', 'profile_image'];

      // isKakaoTalkInstalled(): 카카오톡 앱이 설치되어 있는지 확인
      bool isTalkInstalled = await isKakaoTalkInstalled();

      if (isTalkInstalled) {
        // 카카오톡 앱이 설치되어 있으면 → 카카오톡 앱을 통해 로그인
        // loginWithKakaoTalk(): 카카오톡 앱이 열리고 사용자가 동의하면 토큰 반환
        // serviceTerms: 동의 항목을 명시적으로 요청
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오톡 앱이 없으면 → 웹 브라우저에서 카카오 계정으로 로그인
        // loginWithKakaoAccount(): 카카오 계정(이메일/비밀번호) 입력 페이지 표시
        // scopes: 프로필 닉네임과 프로필 사진 권한을 명시적으로 요청
        await UserApi.instance.loginWithKakaoAccount();
      }

      // ===== 2단계: 카카오 액세스 토큰 받기 =====
      // TokenManagerProvider: 카카오 SDK가 내부적으로 관리하는 토큰 저장소
      // getToken(): 로그인 성공 후 발급된 액세스 토큰을 가져온다
      final tokenInfo = await TokenManagerProvider.instance.manager.getToken();
      // tokenInfo?.accessToken: null일 수 있으므로 ?. 연산자로 안전하게 접근
      final accessToken = tokenInfo?.accessToken;

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('카카오 액세스 토큰을 받지 못했습니다');
      }

      debugPrint('카카오 액세스 토큰 받기 성공: ${accessToken.substring(0, 10)}...');

      // ===== 3단계: 백엔드에 카카오 액세스 토큰 전송하고 JWT 받기 =====
      String? jwtToken;
      try {
        final response = await http.post(
          Uri.parse('$apiBaseUrl/auth/kakao'),
          headers: {
            'Content-Type': 'application/json',
            'authorization': 'Bearer $accessToken',
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 백엔드 응답에서 JWT 추출
          final responseData =
              json.decode(response.body) as Map<String, dynamic>;

          // 다양한 응답 형식 지원: token, jwt, accessToken 등
          jwtToken =
              responseData['token'] as String? ??
              responseData['jwt'] as String? ??
              responseData['accessToken'] as String? ??
              responseData['access_token'] as String?;

          if (jwtToken != null && jwtToken.isNotEmpty) {
            debugPrint('백엔드에서 JWT 받기 성공: ${jwtToken.substring(0, 10)}...');
          } else {
            throw Exception('백엔드 응답에 JWT 토큰이 없습니다');
          }
        } else {
          debugPrint('백엔드 인증 실패: ${response.statusCode}');
          debugPrint('응답 내용: ${response.body}');
          throw Exception('백엔드 인증 실패: ${response.statusCode}');
        }
      } catch (e) {
        debugPrint('백엔드 요청 중 오류 발생: $e');
        throw Exception('백엔드 인증 실패: $e');
      }

      // ===== 4단계: 받은 JWT를 로컬 저장소에 저장 =====
      if (jwtToken.isNotEmpty) {
        await AuthService.instance.setToken(jwtToken);
        debugPrint('JWT 토큰 로컬 저장 완료');
      } else {
        throw Exception('JWT 토큰이 없습니다');
      }

      // ===== 3단계: 동의 여부 확인 및 추가 동의 요청 =====
      // me(): 로그인한 사용자의 프로필 정보(닉네임, 프로필 사진 등)를 서버에서 가져옴
      User user = await UserApi.instance.me();

      // 프로필 정보 동의 여부 확인
      // needsScopeAgreement: 사용자가 아직 프로필 정보 제공에 동의하지 않은 경우
      bool needsScopeAgreement =
          user.kakaoAccount?.profileNeedsAgreement == true;

      if (needsScopeAgreement) {
        // 사용자에게 프로필 정보 제공 동의를 추가로 요청
        // loginWithNewScopes(): 이미 로그인된 상태에서 추가 권한을 요청하는 메서드
        await UserApi.instance.loginWithNewScopes(scopes);
        // 동의 후 사용자 정보를 다시 가져옴
        user = await UserApi.instance.me();
      }

      // ===== 3단계: 사용자 정보 추출 =====
      // 닉네임 추출 (kakaoAccount.profile에서 가져옴, 없으면 '사용자'로 기본값)
      String userName =
          user.kakaoAccount?.profile?.nickname ??
          user.properties?['nickname'] ??
          '사용자';
      // 프로필 이미지 URL 추출 (없을 수 있으므로 nullable)
      String? profileImageUrl =
          user.kakaoAccount?.profile?.profileImageUrl ??
          user.properties?['profile_image'];

      // 디버그용 로그 출력 (콘솔에서 데이터 수신 여부 확인)
      debugPrint('카카오 로그인 성공 - 닉네임: $userName');
      debugPrint('카카오 로그인 성공 - 프로필 이미지: $profileImageUrl');
      debugPrint('카카오 계정 정보: ${user.kakaoAccount?.profile}');
      debugPrint('카카오 properties: ${user.properties}');

      // ===== 3단계: 온보딩 화면으로 이동 =====
      // mounted: 이 위젯이 아직 화면에 존재하는지 확인 (비동기 작업 후 필수 체크)
      if (!mounted) return;

      // pushReplacementNamed(): 현재 화면을 새 화면으로 교체 (뒤로가기 불가)
      // arguments: 다음 화면에 전달할 데이터 (Map 형태)
      Navigator.of(context).pushReplacementNamed(
        '/onboarding',
        arguments: {'userName': userName, 'profileImageUrl': profileImageUrl},
      );
    } catch (error) {
      // 로그인 실패 시 (사용자 취소, 네트워크 오류 등)
      if (!mounted) return;

      // SnackBar: 화면 하단에 잠시 나타나는 알림 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('카카오 로그인에 실패했습니다: $error'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      // finally: try/catch 결과와 관계없이 항상 실행되는 블록
      // 로딩 상태를 해제하여 버튼을 다시 활성화
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
