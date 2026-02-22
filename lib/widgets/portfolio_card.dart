// 포트폴리오 보유 종목 카드 위젯 파일
// 개별 보유 종목의 매수가, 현재가, 보유수량, 평가금액, 수익률을 표시한다

import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../utils/formatters.dart';
import '../constants/colors.dart';

/// 개별 보유 종목 정보를 카드 형태로 표시하는 위젯
/// 이미지 디자인 기준: 종목명/코드, 수익률, 매수가/현재가, 보유수량/평가금액, AI 분석 보기
/// 오른쪽 상단 X 아이콘으로 삭제 확인 팝업 후 삭제 콜백 호출 가능
class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback? onAiAnalysisTap;

  /// 삭제 확인 후 실제 삭제 시 호출 (선택)
  final VoidCallback? onDeleteTap;

  const PortfolioCard({
    super.key,
    required this.item,
    this.onAiAnalysisTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 상단: 종목명/코드 + 수익률/손익금액
                _buildHeader(),
                const SizedBox(height: 20),
                // 중간: 매수가, 현재가, 보유 수량, 평가 금액 그리드
                _buildInfoGrid(),
                const SizedBox(height: 16),
                // 하단: AI 분석 보기 버튼
                _buildAiAnalysisButton(),
              ],
            ),
          ),
          // 오른쪽 상단: 삭제(X) 아이콘
          if (onDeleteTap != null)
            Positioned(
              top: 12,
              right: 12,
              child: InkWell(
                onTap: () => _showDeleteConfirmDialog(context),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 22,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "해당 종목을 삭제하시겠습니까?" 확인 다이얼로그 표시 후 확인 시 onDeleteTap 호출
  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        // title: const Text('해당 종목을 삭제 하시겠습니까?'),
        content: const Text(
          '해당 종목을 삭제 하시겠습니까?\n삭제 후 복구 불가능합니다.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          // 취소: 회색 배경 버튼
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade800,
            ),
            child: const Text('취소'),
          ),
          const SizedBox(width: 12),
          // 삭제: 앱 메인 컬러(파란색) 배경 버튼
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && onDeleteTap != null) {
        onDeleteTap!();
      }
    });
  }

  /// 카드 상단 영역: 종목명/코드(좌측) + 내 자산대비 지표(우측) — 세로 가운데 정렬
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측: 종목명, 종목 코드
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.ticker,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        // 우측: "내 자산대비" — 위: 두 % | 아래: 두 금액 (2×2 형식, 왼쪽 정렬)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '내 자산대비',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 6),
            // 첫째 줄: +0.1%   +9504900.0%
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.isPositive ? '+' : ''}${item.displayChangePercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getStockColor(item.isPositive),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${item.isPositive ? '+' : ''}${item.displayProfitRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.getStockColor(item.isPositive),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 둘째 줄: +₩100   +₩190,098
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.isPositive ? '+' : ''}${formatPrice(item.displayChangeAmount, '₩')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getStockColor(item.isPositive),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${item.isPositive ? '+' : ''}${formatPrice(item.displayProfit, '₩')}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.getStockColor(item.isPositive),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 중간 정보 그리드: 매수가, 현재가, 보유 수량, 평가 금액을 2×2 그리드로 표시
  Widget _buildInfoGrid() {
    return Column(
      children: [
        // 첫 번째 줄: 매수가 + 현재가
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('매수가', formatPrice(item.buyPrice, '₩')),
            ),
            Expanded(
              child: _buildInfoItem('현재가', formatPrice(item.currentPrice, '₩')),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 두 번째 줄: 보유 수량 + 평가 금액
        Row(
          children: [
            Expanded(child: _buildInfoItem('보유 수량', '${item.quantity}주')),
            Expanded(
              child: _buildInfoItem(
                '평가 금액',
                formatPrice(item.totalCurrentAmount, '₩'),
              ),
            ),
          ],
        ),
        // 세 번째 줄: 어제 대비 ±원, ±% (전일 종가가 있을 때만 표시)
        if (item.hasPreviousClose) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  '어제 대비',
                  '${item.isDayPositive ? '+' : ''}${formatPrice(item.dayChangeAmount, '₩')}',
                  valueColor: AppColors.getStockColor(item.isDayPositive),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  '어제 대비(%)',
                  '${item.isDayPositive ? '+' : ''}${item.dayChangePercent.toStringAsFixed(1)}%',
                  valueColor: AppColors.getStockColor(item.isDayPositive),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// 개별 정보 항목: 라벨(회색) + 값(볼드) 세로 배치
  /// [valueColor] 지정 시 값 텍스트 색상(상승 빨강/하락 파랑 등)
  Widget _buildInfoItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  /// 하단 AI 분석 보기 버튼 영역
  Widget _buildAiAnalysisButton() {
    return InkWell(
      onTap: onAiAnalysisTap,
      child: Container(
        padding: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI 분석 보기',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
