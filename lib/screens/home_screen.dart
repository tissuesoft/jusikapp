// 홈 화면 (포트폴리오 대시보드) 파일
// 사용자의 보유 종목 현황, 총 수익률, 총 평가 손익 등을 표시하는 메인 화면

import 'package:flutter/material.dart';
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

// State 클래스를 외부에서 접근 가능하도록 클래스명을 명시적으로 선언
class _HomeScreenState extends State<HomeScreen> {

  // 보유 종목 리스트 (서버에서 가져온 실제 데이터)
  List<PortfolioItem> _portfolio = [];
  // 서버에서 받은 포트폴리오 요약 정보 (총 수익률, 총 손익 등)
  PortfolioSummary? _summary;
  final _apiService = StockApiService();
  bool _isLoading = false;
  String? _errorMessage;
  // 읽지 않은 알림 개수 (실제로는 API나 로컬 저장소에서 가져와야 함)
  final int _unreadNotificationCount = 42;
  // 중복 호출 방지 플래그
  bool _isLoadingPortfolio = false;

  /// 외부에서 호출 가능한 새로고침 메서드
  /// 종목 추가 후 메인 화면으로 돌아올 때 호출됨
  void refreshPortfolio() {
    print('🔄 외부에서 포트폴리오 새로고침 요청');
    _loadPortfolioHome();
  }

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 서버에서 포트폴리오 데이터를 가져온다
    _loadPortfolioHome();
  }

  /// 서버에서 포트폴리오 홈 데이터를 GET 요청으로 가져온다
  /// GET /portfolio/home 엔드포인트를 호출하여 보유 종목 리스트를 받아온다
  /// Header: Authorization: Bearer <JWT 토큰>
  /// 중복 호출 방지: 이미 로딩 중이면 무시
  Future<void> _loadPortfolioHome() async {
    // 중복 호출 방지: 이미 로딩 중이면 무시
    if (_isLoadingPortfolio) {
      print('⚠️ 포트폴리오 데이터 로드 중복 호출 방지');
      return;
    }

    print('🔄 포트폴리오 데이터 로드 시작');
    setState(() {
      _isLoading = true;
      _isLoadingPortfolio = true;
      _errorMessage = null;
    });

    try {
      // StockApiService의 fetchPortfolioHome()으로 서버 데이터 조회
      // 응답 구조: { summary: { ... }, stocks: [ ... ] }
      final result = await _apiService.fetchPortfolioHome();
      
      if (!mounted) return;
      
      setState(() {
        if (result != null) {
          _summary = result.summary;     // 서버에서 계산된 요약 정보
          // 등록 순서(order) 기준으로 정렬하여 보유 종목 리스트 설정
          final list = List<PortfolioItem>.from(result.stocks);
          list.sort((a, b) => a.order.compareTo(b.order));
          _portfolio = list;
          print('✅ 포트폴리오 데이터 로드 성공: ${result.stocks.length}개 종목 (등록 순서 정렬)');
        } else {
          _summary = null;
          _portfolio = [];
          _errorMessage = '포트폴리오 데이터를 불러올 수 없습니다.';
          print('⚠️ 포트폴리오 데이터가 null입니다');
        }
        _isLoading = false;
        _isLoadingPortfolio = false;
      });
    } catch (e, stackTrace) {
      print('❌ 포트폴리오 데이터 로드 실패: $e');
      print('스택 트레이스: $stackTrace');
      if (!mounted) return;
      
      setState(() {
        _errorMessage = '포트폴리오 데이터를 불러오지 못했습니다: $e';
        _isLoading = false;
        _isLoadingPortfolio = false;
      });
    }
  }

  /// "종목 추가" 버튼 탭 시 하단 시트를 표시하고,
  /// 종목 저장 결과를 받아 포트폴리오 데이터를 새로고침
  /// 
  /// 주의: add_stock_bottom_sheet.dart에서 이미 서버에 저장하므로
  /// 여기서는 중복 저장하지 않고 데이터만 새로고침합니다.
  Future<void> _onAddStockTap() async {
    // 1. 하단 시트에서 사용자가 입력한 종목 정보를 받아온다
    // add_stock_bottom_sheet.dart에서 이미 서버에 저장한 후 반환됨
    final result = await showAddStockBottomSheet(context);
    if (result != null) {
      // 2. 저장 성공 시 서버에서 최신 포트폴리오 데이터를 다시 가져온다
      // (add_stock_bottom_sheet에서 이미 저장했으므로 중복 저장하지 않음)
      print('🔄 종목 추가 완료, 포트폴리오 데이터 새로고침');
      await _loadPortfolioHome();
      
      // 3. 성공 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} 종목이 추가되었습니다.'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 서버에서 받은 요약 정보를 사용 (없으면 기본값 0)
    final totalBuy = _summary?.totalInvestAmount ?? 0.0;
    final totalCurrent = _summary?.totalCurrentValue ?? 0.0;
    final totalProfit = _summary?.totalProfit ?? 0.0;
    final totalReturnPercent = _summary?.totalProfitRate ?? 0.0;
    final stockCount = _summary?.stockCount ?? _portfolio.length;

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
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.black87,
                  size: 26,
                ),
                onPressed: () {
                  print('새로고침 버튼 클릭');
                  _loadPortfolioHome();
                },
              ),
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
              stockCount: stockCount,
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

          // 로딩 중 표시
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          // 보유 종목 카드 리스트
          else if (_portfolio.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '보유 종목이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '종목 추가 버튼을 눌러 종목을 추가하세요',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
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
