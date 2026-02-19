// 여러 종목 추가 화면 파일
// 온보딩 단계에서 여러 보유 종목을 한번에 추가하는 화면

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/portfolio.dart';
import '../widgets/add_stock_bottom_sheet.dart';
import '../services/stock_api_service.dart';

/// 여러 종목 추가 화면 위젯 (StatefulWidget)
/// 종목 리스트 + 추가 버튼 + 완료 버튼으로 구성
class AddMultipleStocksScreen extends StatefulWidget {
  const AddMultipleStocksScreen({super.key});

  @override
  State<AddMultipleStocksScreen> createState() =>
      _AddMultipleStocksScreenState();
}

class _AddMultipleStocksScreenState extends State<AddMultipleStocksScreen> {
  // 추가된 종목 리스트
  final List<PortfolioItem> _addedStocks = [];
  // API 서비스 인스턴스
  final _apiService = StockApiService();
  // 저장 중 상태
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 상단 앱바
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '보유 종목 추가',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        // 완료 버튼
        actions: [
          if (_addedStocks.isNotEmpty)
            TextButton(
              onPressed: _isSaving ? null : _onCompleteTap,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Text(
                      '완료 (${_addedStocks.length})',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _addedStocks.isEmpty ? _buildEmptyState() : _buildStockList(),
      // 하단 종목 추가 버튼 (FAB 대신 고정 버튼)
      bottomNavigationBar: _buildAddButton(),
    );
  }

  /// 빈 상태 위젯
  /// 종목이 하나도 추가되지 않았을 때 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_chart,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '보유한 종목을 추가해주세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '하단의 + 버튼을 눌러 종목을 추가할 수 있습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// 종목 리스트 위젯
  /// 추가된 종목들을 카드 형태로 표시
  Widget _buildStockList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _addedStocks.length,
      itemBuilder: (context, index) {
        final stock = _addedStocks[index];
        return _buildStockCard(stock, index);
      },
    );
  }

  /// 개별 종목 카드 위젯
  /// 종목 정보와 삭제 버튼 표시
  Widget _buildStockCard(PortfolioItem stock, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // 종목 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 종목명
                Text(
                  stock.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                // 종목 코드
                Text(
                  stock.ticker,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                // 매수가 및 보유 수량
                Row(
                  children: [
                    Text(
                      '매수가: ${stock.buyPrice.toStringAsFixed(0)}원',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '수량: ${stock.quantity}주',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 삭제 버튼
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.grey.shade400,
            ),
            onPressed: () => _removeStock(index),
          ),
        ],
      ),
    );
  }

  /// 하단 종목 추가 버튼
  /// 새로운 종목을 추가하는 버튼
  Widget _buildAddButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _onAddStockTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            '종목 추가',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  /// 종목 추가 버튼 클릭 시
  /// 기존의 add_stock_bottom_sheet 호출
  Future<void> _onAddStockTap() async {
    final result = await showAddStockBottomSheet(context);
    if (result != null) {
      setState(() {
        _addedStocks.add(result);
      });
    }
  }

  /// 종목 삭제
  /// 리스트에서 특정 종목 제거
  void _removeStock(int index) {
    setState(() {
      _addedStocks.removeAt(index);
    });
  }

  /// 완료 버튼 클릭 시
  /// 추가된 종목들을 서버에 저장하고 메인 화면으로 이동
  Future<void> _onCompleteTap() async {
    if (_addedStocks.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // 각 종목을 서버에 POST /portfolio로 전송
      // Body: {"stock_name": "...", "stock_code": "...", "avg_price": ..., "quantity": ...}
      // Header: Authorization: Bearer <JWT 토큰>
      bool allSuccess = true;
      for (final stock in _addedStocks) {
        final success = await _apiService.addPortfolioItem(stock);
        if (!success) {
          allSuccess = false;
          debugPrint('종목 저장 실패: ${stock.name}');
        } else {
          debugPrint('종목 저장 성공: ${stock.name}');
        }
      }

      if (!mounted) return;

      if (allSuccess) {
        // 모든 종목 저장 성공 시 메인 화면으로 이동 (새로고침 요청 포함)
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
          arguments: 'refresh', // 새로고침 요청 인자 전달
        );
      } else {
        // 일부 실패 시 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('일부 종목 저장에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        setState(() => _isSaving = false);
      }
    } catch (e) {
      debugPrint('종목 저장 중 오류 발생: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('종목 저장 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      setState(() => _isSaving = false);
    }
  }
}
