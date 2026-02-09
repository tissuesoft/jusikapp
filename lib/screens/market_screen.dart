import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/stock.dart';
import '../widgets/stock_card.dart';
import 'stock_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  final bool isKorean;

  const MarketScreen({super.key, required this.isKorean});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'change';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Stock> _getStocks(int tabIndex) {
    final stocks = widget.isKorean ? koreanStocks : usStocks;
    List<Stock> filtered;

    if (widget.isKorean) {
      filtered = tabIndex == 0
          ? stocks.where((s) => s.market == Market.kospi).toList()
          : stocks.where((s) => s.market == Market.kosdaq).toList();
    } else {
      filtered = tabIndex == 0
          ? stocks.where((s) => s.market == Market.nasdaq).toList()
          : stocks.where((s) => s.market == Market.nyse).toList();
    }

    switch (_sortBy) {
      case 'change':
        filtered.sort((a, b) => b.changePercent.compareTo(a.changePercent));
        break;
      case 'price':
        filtered.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tab1Label = widget.isKorean ? 'KOSPI' : 'NASDAQ';
    final tab2Label = widget.isKorean ? 'KOSDAQ' : 'NYSE';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.isKorean ? '한국 시장' : '미국 시장',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (_) => setState(() {}),
          labelColor: const Color(0xFF1565C0),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1565C0),
          indicatorWeight: 3,
          tabs: [
            Tab(text: tab1Label),
            Tab(text: tab2Label),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStockList(0),
                _buildStockList(1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            '정렬:',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          _buildSortChip('등락률', 'change'),
          const SizedBox(width: 6),
          _buildSortChip('가격', 'price'),
          const SizedBox(width: 6),
          _buildSortChip('이름', 'name'),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1565C0) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildStockList(int tabIndex) {
    final stocks = _getStocks(tabIndex);

    if (stocks.isEmpty) {
      return const Center(
        child: Text('해당 시장의 종목이 없습니다.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        return StockCard(
          stock: stocks[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  StockDetailScreen(stock: stocks[index]),
            ),
          ),
        );
      },
    );
  }
}
