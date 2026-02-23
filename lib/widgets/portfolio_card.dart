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
                // 상단: 종목명/코드(좌) + 전일대비·수익률(우), 세로 가운데 정렬
                _buildHeader(),
                // 구분선
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),
                const SizedBox(height: 16),
                // 중간: 매수가/현재가, 보유 수량/평가 금액 2열
                _buildInfoGrid(),
                // 구분선
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Divider(height: 1, color: Colors.grey.shade200),
                ),
                // 하단: AI 분석 보기
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

  /// 카드 상단: 종목명/코드(좌) + 전일대비·수익률(우), 형식 "+₩금액(퍼센트%)", 세로 가운데 정렬
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측: 종목명, 종목 코드
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
        // 우측: 전일대비·수익률 — 라벨/값 스타일을 현재가·평가 금액(_buildInfoItem)과 동일하게
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '전일대비',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              _formatAmountWithPercent(
                item.displayDayChangeAmount,
                item.displayDayChangePercent,
                item.isDayPositive,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: item.hasDayChangeData
                    ? AppColors.getStockColor(item.isDayPositive)
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '수익률',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              _formatAmountWithPercent(
                item.displayProfit,
                item.displayProfitRate,
                item.isPositive,
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getStockColor(item.isPositive),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// "+₩4,000(4.5%)" 형식 문자열 생성 (전일대비·수익률 표시용)
  String _formatAmountWithPercent(double amount, double percent, bool isPositive) {
    final sign = isPositive ? '+' : '';
    return '$sign${formatPrice(amount, '₩')}(${percent.toStringAsFixed(1)}%)';
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

  /// 하단 AI 분석 보기 버튼 영역 (상단 구분선은 상위에서 Divider로 처리)
  Widget _buildAiAnalysisButton() {
    return InkWell(
      onTap: onAiAnalysisTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
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

