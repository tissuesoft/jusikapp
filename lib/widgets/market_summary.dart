import 'package:flutter/material.dart';
import '../constants/colors.dart';

class MarketSummaryCard extends StatelessWidget {
  final String indexName;
  final String value;
  final String change;
  final bool isPositive;

  const MarketSummaryCard({
    super.key,
    required this.indexName,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            indexName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                // 주가 상승/하락에 따른 색상
                color: AppColors.getStockColor(isPositive),
                size: 20,
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  // 주가 상승/하락에 따른 색상
                  color: AppColors.getStockColor(isPositive),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
