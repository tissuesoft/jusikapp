import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../utils/formatters.dart';
import '../constants/colors.dart';
import 'recommendation_badge.dart';

class StockCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;

  const StockCard({
    super.key,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildLeading(),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 12),
              _buildPrice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // 주가 상승/하락에 따른 배경색
        color: AppColors.getStockBackgroundColor(stock.isPositive),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          stock.isKorean
              ? stock.name.substring(0, 1)
              : stock.ticker.substring(0, 1),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // 주가 상승/하락에 따른 텍스트 색상
            color: AppColors.getStockColor(stock.isPositive),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stock.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              stock.ticker,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                stock.marketLabel,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            RecommendationBadge(
              recommendation: stock.recommendation,
              compact: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatPrice(stock.currentPrice, stock.currency),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatPercent(stock.changePercent),
          style: TextStyle(
            // 주가 상승/하락에 따른 색상
            color: AppColors.getStockColor(stock.isPositive),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
