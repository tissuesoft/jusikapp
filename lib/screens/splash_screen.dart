// 스플래시(로딩) 화면 파일
// 앱 시작 시 #2563EB 배경에 앱 메인 아이콘과 로딩 애니메이션을 표시한 뒤
// 일정 시간 후 메인 화면으로 자동 전환한다

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/push_service.dart';

/// 스플래시 화면 위젯 (StatefulWidget)
/// 로고 페이드인 + 스케일 애니메이션 후 메인 화면으로 이동
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // 로고 애니메이션 컨트롤러
  late AnimationController _controller;
  // 로고 페이드인 애니메이션
  late Animation<double> _fadeAnimation;
  // 로고 스케일 애니메이션
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1.2초 동안 애니메이션 실행
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 0 → 1 페이드인 (처음 60% 구간)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 0.6 → 1.0 스케일업 (부드러운 탄성 효과)
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // 애니메이션 시작
    _controller.forward();

    // 앱 초기화 및 토큰 확인
    _initializeApp();
  }

  /// 앱 초기화 및 토큰 확인 후 적절한 화면으로 이동
  Future<void> _initializeApp() async {
    // AuthService 초기화 (로컬 저장소에서 토큰 불러오기)
    await AuthService.instance.initialize();

    // 최소 2.5초 대기 (스플래시 화면 표시 시간)
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // 토큰이 있으면 FCM 푸시 토큰을 백엔드에 등록한 뒤 메인으로, 없으면 로그인으로 이동
    if (AuthService.instance.hasToken) {
      await PushService.registerTokenWithBackend();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 앱 메인 아이콘: 둥근 모서리 흰색 박스 + N 로고 (로딩 화면용)
  Widget _buildAppIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
            height: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // #2563EB 파란색 전체 배경
      backgroundColor: const Color(0xFF2563EB),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 앱 메인 아이콘 (assets/images/app_icon.png 없으면 N 로고 폴백)
              _buildAppIcon(),
              const SizedBox(height: 32),
              // 앱 이름 텍스트 (설치 시 이름과 동일: N주식)
              const Text(
                'N주식',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // 부제 텍스트
              Text(
                'AI 기반 주식 분석 서비스',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 48),
              // 로딩 인디케이터 (흰색 원형 프로그레스)
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
