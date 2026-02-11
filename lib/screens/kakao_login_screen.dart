// 카카오톡 로그인 화면 파일
// 스플래시 화면 이후 카카오톡 로그인 UI를 표시
// 로그인 성공 시 메인 화면으로 이동

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// 카카오톡 로그인 화면 위젯 (StatelessWidget)
/// 카카오톡 로고, 앱 설명, 카카오톡 로그인 버튼으로 구성
class KakaoLoginScreen extends StatelessWidget {
  const KakaoLoginScreen({super.key});

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

  /// 앱 로고 위젯
  /// 파란색 배경에 흰색 N 텍스트
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

  /// 카카오톡 로그인 버튼 위젯
  /// 노란색 배경에 카카오톡 로고와 텍스트
  Widget _buildKakaoLoginButton(BuildContext context) {
    return InkWell(
      onTap: () => _onKakaoLoginTap(context),
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
            // 로그인 텍스트
            const Text(
              '카카오톡으로 시작하기',
              style: TextStyle(
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

  /// 이용약관 텍스트 위젯
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

  /// 카카오톡 로그인 버튼 클릭 시 호출되는 메서드
  /// 실제 카카오 SDK 연동은 추후 구현
  /// 현재는 바로 메인 화면으로 이동
  void _onKakaoLoginTap(BuildContext context) {
    // TODO: 실제 카카오톡 로그인 SDK 연동
    // 1. 카카오 SDK 초기화
    // 2. 로그인 요청
    // 3. 사용자 정보 가져오기
    // 4. 서버에 인증 토큰 전송
    // 5. 로그인 성공 시 메인 화면으로 이동

    // 현재는 임시로 바로 메인 화면으로 이동
    Navigator.of(context).pushReplacementNamed('/main');
  }
}
