// 카카오톡 로그인 화면 파일
// 카카오 SDK로 로그인 후 accessToken을 받아 POST /auth/kakao 호출
// 응답의 needAgreement에 따라 약관 동의 화면 또는 메인 화면으로 이동

import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/colors.dart';
import '../constants/api_config.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';

/// 카카오톡 로그인 화면
/// 로그인 성공 시 JWT 저장 후 needAgreement 여부에 따라 /agreements 또는 /main 으로 이동
class KakaoLoginScreen extends StatefulWidget {
  const KakaoLoginScreen({super.key});

  @override
  State<KakaoLoginScreen> createState() => _KakaoLoginScreenState();
}

class _KakaoLoginScreenState extends State<KakaoLoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildAppLogo(),
              const SizedBox(height: 32),
              const Text(
                'Stock Analysis AI',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
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
              _buildKakaoLoginButton(context),
              const SizedBox(height: 16),
              _buildTermsText(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildKakaoLoginButton(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : () => _onKakaoLoginTap(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
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
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    'K',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFFE812),
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
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

  /// 카카오 로그인 → POST /auth/kakao → JWT 저장 → needAgreement에 따라 라우팅
  Future<void> _onKakaoLoginTap(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      // 1) 카카오 로그인 (앱 또는 웹)
      final isTalkInstalled = await isKakaoTalkInstalled();
      if (isTalkInstalled) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }

      final tokenInfo = await TokenManagerProvider.instance.manager.getToken();
      final kakaoAccessToken = tokenInfo?.accessToken;

      if (kakaoAccessToken == null || kakaoAccessToken.isEmpty) {
        throw Exception('카카오 액세스 토큰을 받지 못했습니다');
      }

      // 2) POST /auth/kakao 호출
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/kakao'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $kakaoAccessToken',
        },
      );

      final body = response.body;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final msg = _tryParseError(body);
        throw Exception(msg ?? '백엔드 인증 실패: ${response.statusCode}');
      }

      final data = json.decode(body) as Map<String, dynamic>;
      final token = data['token'] as String? ??
          data['jwt'] as String? ??
          data['accessToken'] as String? ??
          data['access_token'] as String?;

      if (token == null || token.isEmpty) {
        throw Exception('백엔드 응답에 JWT 토큰이 없습니다');
      }

      // 3) JWT 저장 (flutter_secure_storage)
      await AuthService.instance.setToken(token);

      // 4) needAgreement: true → 약관 동의 화면, false → 메인 + FCM 등록
      final needAgreement = data['needAgreement'] as bool? ?? false;

      if (!mounted) return;

      if (needAgreement) {
        Navigator.of(context).pushReplacementNamed('/agreements');
      } else {
        await PushService.registerTokenWithBackend();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/main');
      }
    } catch (e) {
      if (!mounted) return;
      _showError('카카오 로그인에 실패했습니다: ${e is Exception ? e.toString().replaceFirst('Exception: ', '') : e}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _tryParseError(String body) {
    try {
      final m = json.decode(body) as Map<String, dynamic>;
      return m['message'] as String? ?? m['error'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
