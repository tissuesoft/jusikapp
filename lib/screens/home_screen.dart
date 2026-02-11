// 홈 화면 (포트폴리오 대시보드) 파일
// 사용자의 보유 종목 현황, 총 수익률, 총 평가 손익 등을 표시하는 메인 화면

import 'package:flutter/material.dart';
import '../data/mock_portfolio.dart';
import '../models/portfolio.dart';
import '../utils/formatters.dart';
import '../widgets/portfolio_card.dart';
import '../widgets/add_stock_bottom_sheet.dart';
import '../services/stock_api_service.dart';
import '../constants/colors.dart';
import 'ai_analysis_screen.dart';
import 'notification_screen.dart';
import 'settings_screen.dart';

/// 포트폴리오 대시보드 홈 화면 위젯 (StatefulWidget)
/// 상단 앱바 + 포트폴리오 요약 카드 + 보유 종목 리스트로 구성
/// 종목 추가/삭제 시 상태가 변경되므로 StatefulWidget으로 구현
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 보유 종목 리스트 (모의 데이터로 초기화, 추가/삭제 가능)
  late List<PortfolioItem> _portfolio;
  final _apiService = StockApiService();
  bool _isLoading = false;
  String? _errorMessage;
  // 읽지 않은 알림 개수 (실제로는 API나 로컬 저장소에서 가져와야 함)
  final int _unreadNotificationCount = 42;

  @override
  void initState() {
    super.initState();
    // 모의 데이터를 복사하여 동적 리스트로 관리
    _portfolio = List.from(mockPortfolio);
    // 화면 로드 시 API 호출하여 실시간 가격 업데이트
    _loadPortfolioPrices();
  }

  /// API를 호출하여 포트폴리오 종목들의 현재가를 업데이트
  Future<void> _loadPortfolioPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedPortfolio = await _apiService.fetchPortfolioPrices(
        _portfolio,
      );
      setState(() {
        _portfolio = updatedPortfolio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'API 호출 실패: $e';
        _isLoading = false;
      });
    }
  }

  /// "종목 추가" 버튼 탭 시 하단 시트를 표시하고,
  /// 종목 저장 결과를 받아 포트폴리오에 추가
  Future<void> _onAddStockTap() async {
    final result = await showAddStockBottomSheet(context);
    if (result != null) {
      setState(() {
        _portfolio.add(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 포트폴리오 전체 합산 계산
    final totalBuy = _portfolio.fold<double>(
      0,
      (sum, item) => sum + item.totalBuyAmount,
    );
    final totalCurrent = _portfolio.fold<double>(
      0,
      (sum, item) => sum + item.totalCurrentAmount,
    );
    final totalProfit = totalCurrent - totalBuy;
    // 매입 금액이 0이면 수익률 0으로 처리 (0 나누기 방지)
    final totalReturnPercent = totalBuy > 0
        ? (totalProfit / totalBuy) * 100
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          // 상단 앱바: 홈 아이콘 + 새로고침 + 설정 아이콘
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: const Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.home, color: Colors.black87, size: 26),
            ),
            actions: [
              // 새로고침 버튼 - API 재호출

              // 알림 아이콘 - 탭 시 알림 화면으로 이동
              // Badge 위젯으로 읽지 않은 알림 개수를 표시
              IconButton(
                icon: Badge(
                  // 읽지 않은 알림이 있을 때만 배지 표시
                  label: _unreadNotificationCount > 0
                      ? Text(
                          _unreadNotificationCount > 99
                              ? '99+' // 99개 이상이면 99+로 표시
                              : _unreadNotificationCount.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                  // 배지 배경색 (빨간색 - 주가 상승 색상 사용)
                  backgroundColor: AppColors.stockUp,
                  // 배지를 표시할지 여부
                  isLabelVisible: _unreadNotificationCount > 0,
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.black87,
                    size: 26,
                  ),
                ),
                onPressed: () {
                  print('알림 아이콘 클릭됨'); // 디버그용 로그
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const NotificationScreen(showBackButton: true),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black87,
                  size: 26,
                ),
                onPressed: () {
                  // 설정 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 에러 메시지 표시
          if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.errorBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.error,
                      ),
                      onPressed: () => setState(() => _errorMessage = null),
                    ),
                  ],
                ),
              ),
            ),

          // 포트폴리오 요약 카드 영역
          SliverToBoxAdapter(
            child: _buildPortfolioSummary(
              totalReturnPercent: totalReturnPercent,
              totalProfit: totalProfit,
              totalCurrent: totalCurrent,
              totalBuy: totalBuy,
              stockCount: _portfolio.length,
            ),
          ),

          // 보유 종목 섹션 헤더: "보유 종목" + "종목 추가" 버튼
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '보유 종목',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  // 종목 추가 버튼 - 탭 시 하단 시트 표시
                  GestureDetector(
                    onTap: _onAddStockTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2563EB),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            '종목 추가',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 보유 종목 카드 리스트
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return PortfolioCard(
                item: _portfolio[index],
                onAiAnalysisTap: () {
                  // AI 분석 채팅 화면으로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AiAnalysisScreen(item: _portfolio[index]),
                    ),
                  );
                },
              );
            }, childCount: _portfolio.length),
          ),

          // 하단 여백 (네비게이션 바에 가리지 않도록)
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  /// 포트폴리오 요약 카드 위젯
  /// 진한 남색 배경에 총 수익률과 세부 합산 정보를 표시
  Widget _buildPortfolioSummary({
    required double totalReturnPercent,
    required double totalProfit,
    required double totalCurrent,
    required double totalBuy,
    required int stockCount,
  }) {
    final isPositive = totalReturnPercent >= 0;

    return Container(
      // margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        // 메인 테마 색상 배경
        color: AppColors.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "총 수익률" 라벨
            Text(
              '총 수익률',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // 수익률 숫자 + 화살표 아이콘
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}${totalReturnPercent.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 세부 정보 리스트 (흰색 반투명 박스)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  // 총 평가 손익
                  _buildSummaryRow(
                    '총 평가 손익',
                    '${isPositive ? '+' : ''}${formatPrice(totalProfit, '₩')}',
                  ),
                  _buildDivider(),
                  // 총 평가 금액
                  _buildSummaryRow('총 평가 금액', formatPrice(totalCurrent, '₩')),
                  _buildDivider(),
                  // 총 매입 금액
                  _buildSummaryRow('총 매입 금액', formatPrice(totalBuy, '₩')),
                  _buildDivider(),
                  // 보유 종목 수
                  _buildSummaryRow('보유 종목 수', '$stockCount종목'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 요약 카드 내 한 줄 정보 행: 라벨(좌측) + 값(우측)
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 요약 카드 내 구분선
  Widget _buildDivider() {
    return Divider(color: Colors.white.withValues(alpha: 0.1), height: 1);
  }
}
