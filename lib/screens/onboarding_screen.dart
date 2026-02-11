// 온보딩 화면 파일
// 로그인 후 첫 사용자를 위한 화면
// 프로필 사진, 환영 메시지, 종목 추가 안내

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// 온보딩 화면 위젯 (StatelessWidget)
/// 사용자 프로필 사진, 환영 메시지, 종목 추가 버튼 표시
class OnboardingScreen extends StatelessWidget {
  // 사용자 이름 (나중에 API에서 가져올 예정)
  final String userName;
  // 프로필 이미지 URL (선택사항)
  final String? profileImageUrl;

  const OnboardingScreen({
    super.key,
    this.userName = '홍길동',
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 앱바 (뒤로가기 버튼 없음)
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // 프로필 사진 영역
              _buildProfileImage(),
              const SizedBox(height: 32),
              // 환영 메시지
              _buildWelcomeMessage(),
              const Spacer(flex: 3),
              // 버튼 영역
              _buildButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 사진 위젯
  /// 사용자 프로필 이미지 또는 기본 아바타 표시
  Widget _buildProfileImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: profileImageUrl != null
            ? Image.network(
                profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  /// 기본 아바타 아이콘
  /// 프로필 이미지가 없을 때 표시
  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 64,
      color: AppColors.primary,
    );
  }

  /// 환영 메시지 위젯
  /// 사용자 이름과 안내 문구 표시
  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        // 사용자 이름 + 환영 문구
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: userName,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const TextSpan(text: '님\n'),
              const TextSpan(text: '보유한 주식종목이\n있으신가요?'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 부연 설명
        Text(
          '종목을 추가하면 AI가 포트폴리오를\n분석하여 맞춤 투자 의견을 제공합니다',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  /// 버튼 영역 위젯
  /// "보유 종목 추가" 버튼과 "메인으로" 버튼
  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // "보유 종목 추가" 버튼 (주 액션)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _onAddStocksTap(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, size: 22),
                SizedBox(width: 8),
                Text(
                  '보유 종목 추가',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // "메인으로" 버튼 (보조 액션)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _onSkipToMain(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary, width: 1.5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '나중에 추가하기 (메인으로)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// "보유 종목 추가" 버튼 클릭 시
  /// 종목 추가 화면으로 이동
  void _onAddStocksTap(BuildContext context) {
    Navigator.of(context).pushNamed('/add-stocks');
  }

  /// "메인으로" 버튼 클릭 시
  /// 메인 화면으로 이동 (온보딩 건너뛰기)
  void _onSkipToMain(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/main');
  }
}
