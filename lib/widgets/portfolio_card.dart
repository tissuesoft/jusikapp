// 포트폴리오 보유 종목 카드 위젯 파일
// 개별 보유 종목의 매수가, 현재가, 보유수량, 평가금액, 수익률을 표시한다

import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../utils/formatters.dart';
import '../constants/colors.dart';

/// 개별 보유 종목 정보를 카드 형태로 표시하는 위젯
/// 이미지 디자인 기준: 종목명/코드, 수익률, 매수가/현재가, 보유수량/평가금액, AI 분석 보기
class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;
  final VoidCallback? onAiAnalysisTap;

  const PortfolioCard({
    super.key,
    required this.item,
    this.onAiAnalysisTap,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
    );
  }

  /// 카드 상단 영역: 종목명/코드(좌측) + 수익률/손익금액(우측)
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 좌측: 종목명, 종목 코드
        Column(
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
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        // 우측: 수익률(%), 손익 금액
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.isPositive ? '+' : ''}${item.returnPercent.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                // 수익/손실에 따른 색상
                color: AppColors.getStockColor(item.isPositive),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${item.isPositive ? '+' : ''}${formatPrice(item.profitLoss, '₩')}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                // 수익/손실에 따른 색상
                color: AppColors.getStockColor(item.isPositive),
              ),
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
            Expanded(child: _buildInfoItem('매수가', formatPrice(item.buyPrice, '₩'))),
            Expanded(child: _buildInfoItem('현재가', formatPrice(item.currentPrice, '₩'))),
          ],
        ),
        const SizedBox(height: 12),
        // 두 번째 줄: 보유 수량 + 평가 금액
        Row(
          children: [
            Expanded(child: _buildInfoItem('보유 수량', '${item.quantity}주')),
            Expanded(child: _buildInfoItem('평가 금액', formatPrice(item.totalCurrentAmount, '₩'))),
          ],
        ),
      ],
    );
  }

  /// 개별 정보 항목: 라벨(회색) + 값(볼드) 세로 배치
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
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
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
