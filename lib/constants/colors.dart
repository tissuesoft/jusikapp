// 앱 전체에서 사용하는 색상 상수 파일
// 모든 색상을 중앙에서 관리하여 일관성 유지 및 유지보수 용이

import 'package:flutter/material.dart';

/// 앱 색상 상수 클래스
/// 모든 색상 값을 static const로 정의하여 메모리 효율적으로 관리
class AppColors {
  // 생성자를 private으로 만들어 인스턴스화 방지
  AppColors._();

  // ========== 주요 테마 색상 ==========
  /// 메인 테마 색상 (파란색)
  static const Color primary = Color(0xFF2563EB);

  /// 메인 테마 색상 (밝은 파란색) - 그라디언트용
  static const Color primaryLight = Color(0xFF60A5FA);

  /// 메인 테마 색상 (어두운 파란색)
  static const Color primaryDark = Color(0xFF1565C0);

  // ========== 주가 상승/하락 색상 ==========
  /// 주가 상승 색상 (빨간색) - 한국 증시 표준
  static const Color stockUp = Color(0xFFC62828);

  /// 주가 상승 색상 (밝은 빨간색) - 그라디언트용
  static const Color stockUpLight = Color(0xFFEF5350);

  /// 주가 상승 배경색 (연한 빨간색)
  static const Color stockUpBackground = Color(0xFFFFEBEE);

  /// 주가 하락 색상 (파란색) - 한국 증시 표준
  static const Color stockDown = Color(0xFF2563EB);

  /// 주가 하락 색상 (밝은 파란색) - 그라디언트용
  static const Color stockDownLight = Color(0xFF60A5FA);

  /// 주가 하락 배경색 (연한 파란색)
  static const Color stockDownBackground = Color(0xFFE3F2FD);

  // ========== 배경 색상 ==========
  /// 메인 배경색 (밝은 회색)
  static const Color background = Color(0xFFF8F9FA);

  /// 보조 배경색 (더 밝은 회색)
  static const Color backgroundLight = Color(0xFFF5F6FA);

  /// 카드 배경색 (흰색)
  static const Color cardBackground = Colors.white;

  // ========== 텍스트 색상 ==========
  /// 기본 텍스트 색상 (검은색에 가까운 회색)
  static const Color textPrimary = Color(0xFF212121);

  /// 보조 텍스트 색상 (회색)
  static const Color textSecondary = Color(0xFF757575);

  /// 비활성 텍스트 색상 (밝은 회색)
  static const Color textDisabled = Color(0xFFBDBDBD);

  // ========== 알림 타입별 색상 ==========
  /// 주가 알림 색상 (파란색)
  static const Color notificationStock = Color(0xFF2563EB);

  /// 주가 알림 배경색 (연한 파란색)
  static const Color notificationStockBackground = Color(0xFFE3F2FD);

  /// 뉴스 알림 색상 (주황색)
  static const Color notificationNews = Color(0xFFF97316);

  /// 뉴스 알림 배경색 (연한 주황색)
  static const Color notificationNewsBackground = Color(0xFFFFF4E6);

  /// 시스템 알림 색상 (보라색)
  static const Color notificationSystem = Color(0xFF9333EA);

  /// 시스템 알림 배경색 (연한 보라색)
  static const Color notificationSystemBackground = Color(0xFFF3E8FF);

  /// 읽지 않은 알림 배경색 (연한 파란색)
  static const Color notificationUnreadBackground = Color(0xFFF0F7FF);

  // ========== 에러 및 경고 색상 ==========
  /// 에러 색상 (빨간색)
  static const Color error = Color(0xFFC62828);

  /// 에러 배경색 (연한 빨간색)
  static const Color errorBackground = Color(0xFFFEF2F2);

  /// 에러 테두리 색상 (밝은 빨간색)
  static const Color errorBorder = Color(0xFFFCA5A5);

  /// 경고 색상 (노란색)
  static const Color warning = Color(0xFFFFA000);

  /// 성공 색상 (초록색)
  static const Color success = Color(0xFF4CAF50);

  // ========== 테두리 및 구분선 색상 ==========
  /// 기본 테두리 색상 (밝은 회색)
  static const Color border = Color(0xFFE0E0E0);

  /// 구분선 색상 (더 밝은 회색)
  static const Color divider = Color(0xFFEEEEEE);

  // ========== 그림자 색상 ==========
  /// 카드 그림자 색상 (반투명 검은색)
  static Color shadow = Colors.black.withValues(alpha: 0.05);

  /// 진한 그림자 색상 (반투명 검은색)
  static Color shadowDark = Colors.black.withValues(alpha: 0.1);

  // ========== 반투명 색상 (오버레이용) ==========
  /// 반투명 흰색 (10% 불투명도)
  static Color whiteOverlay10 = Colors.white.withValues(alpha: 0.1);

  /// 반투명 흰색 (12% 불투명도)
  static Color whiteOverlay12 = Colors.white.withValues(alpha: 0.12);

  /// 반투명 흰색 (70% 불투명도)
  static Color whiteOverlay70 = Colors.white.withValues(alpha: 0.7);

  /// 반투명 파란색 (12% 불투명도) - 인디케이터용
  static Color primaryOverlay12 = primary.withValues(alpha: 0.12);

  /// 반투명 파란색 (20% 불투명도) - 테두리용
  static Color primaryOverlay20 = primary.withValues(alpha: 0.2);

  // ========== 추천 등급별 색상 (선택사항) ==========
  /// 강력매수 색상 (진한 빨간색)
  static const Color strongBuy = Color(0xFFB71C1C);

  /// 매수 색상 (빨간색)
  static const Color buy = Color(0xFFC62828);

  /// 관망 색상 (회색)
  static const Color hold = Color(0xFF757575);

  /// 매도 색상 (파란색)
  static const Color sell = Color(0xFF2563EB);

  /// 강력매도 색상 (진한 파란색)
  static const Color strongSell = Color(0xFF1565C0);

  // ========== 헬퍼 메서드 ==========
  /// 주가 상승/하락 여부에 따른 색상 반환
  /// [isPositive]가 true면 상승 색상, false면 하락 색상 반환
  static Color getStockColor(bool isPositive) {
    return isPositive ? stockUp : stockDown;
  }

  /// 주가 상승/하락 여부에 따른 밝은 색상 반환 (그라디언트용)
  /// [isPositive]가 true면 상승 밝은 색상, false면 하락 밝은 색상 반환
  static Color getStockLightColor(bool isPositive) {
    return isPositive ? stockUpLight : stockDownLight;
  }

  /// 주가 상승/하락 여부에 따른 배경 색상 반환
  /// [isPositive]가 true면 상승 배경 색상, false면 하락 배경 색상 반환
  static Color getStockBackgroundColor(bool isPositive) {
    return isPositive ? stockUpBackground : stockDownBackground;
  }

  /// 주가 상승/하락 여부에 따른 그라디언트 색상 리스트 반환 (차트용)
  /// [isPositive]가 true면 빨간색 계열, false면 파란색 계열 그라디언트
  static List<Color> getStockGradientColors(bool isPositive) {
    return isPositive ? [stockUp, stockUpLight] : [stockDown, stockDownLight];
  }
}
