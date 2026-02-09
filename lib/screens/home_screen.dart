import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/stock.dart';
import '../widgets/stock_card.dart';
import '../widgets/market_summary.dart';
import 'stock_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recommended = recommendedStocks;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: const Text(
                '오늘의 추천',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildMarketOverview()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: Color(0xFF2E7D32), size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    '추천 종목',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${recommended.length}종목',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final stock = recommended[index];
                return StockCard(
                  stock: stock,
                  onTap: () => _navigateToDetail(context, stock),
                );
              },
              childCount: recommended.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildMarketOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '시장 현황',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: MarketSummaryCard(
                  indexName: 'KOSPI',
                  value: '2,687.45',
                  change: '+1.23%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MarketSummaryCard(
                  indexName: 'KOSDAQ',
                  value: '892.31',
                  change: '-0.45%',
                  isPositive: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MarketSummaryCard(
                  indexName: 'NASDAQ',
                  value: '16,274.94',
                  change: '+0.87%',
                  isPositive: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MarketSummaryCard(
                  indexName: 'S&P 500',
                  value: '5,123.69',
                  change: '+0.52%',
                  isPositive: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Stock stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailScreen(stock: stock),
      ),
    );
  }
}
