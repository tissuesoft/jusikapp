// 종목 추가 하단 시트(Bottom Sheet) 위젯 파일
// "종목 추가" 버튼 탭 시 하단에서 올라오는 입력 폼을 제공한다

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/portfolio.dart';
import '../data/mock_data.dart';
import '../utils/formatters.dart';

/// 종목 추가 하단 시트를 표시하는 함수
/// context를 받아 showModalBottomSheet를 호출한다
/// 종목 저장 시 PortfolioItem을 반환하고, 취소 시 null을 반환
Future<PortfolioItem?> showAddStockBottomSheet(BuildContext context) {
  return showModalBottomSheet<PortfolioItem>(
    context: context,
    isScrollControlled: true, // 키보드가 올라올 때 시트가 밀려 올라가도록
    backgroundColor: Colors.transparent,
    builder: (context) => const _AddStockBottomSheet(),
  );
}

/// 종목 추가 하단 시트 내부 위젯 (StatefulWidget)
/// 종목 검색, 매수가, 보유 수량 입력 폼과 예상 투자금액 표시
class _AddStockBottomSheet extends StatefulWidget {
  const _AddStockBottomSheet();

  @override
  State<_AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<_AddStockBottomSheet> {
  final _searchController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _quantityController = TextEditingController(text: '1');

  String? _selectedStockName; // 선택된 종목명
  String? _selectedStockTicker; // 선택된 종목 코드
  double? _selectedCurrentPrice; // 선택된 종목의 현재가
  bool _showSearchResults = false; // 검색 결과 표시 여부

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// 매수가 입력값을 double로 파싱
  double get _buyPrice {
    final text = _priceController.text.replaceAll(',', '');
    return double.tryParse(text) ?? 0;
  }

  /// 보유 수량 입력값을 int로 파싱
  int get _quantity {
    return int.tryParse(_quantityController.text) ?? 0;
  }

  /// 예상 투자금액 = 매수가 × 보유 수량
  double get _estimatedAmount => _buyPrice * _quantity;

  /// 종목 검색 결과 필터링
  /// 입력된 텍스트로 종목명 또는 티커 코드를 검색
  List<Map<String, String>> get _filteredStocks {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return [];

    // 한국 + 미국 전체 종목에서 검색
    final results = <Map<String, String>>[];
    for (final stock in allStocks) {
      if (stock.name.toLowerCase().contains(query) ||
          stock.ticker.toLowerCase().contains(query)) {
        results.add({
          'name': stock.name,
          'ticker': stock.ticker,
          'price': stock.currentPrice.toString(),
          'currency': stock.currency,
        });
      }
    }
    return results;
  }

  /// 검색 결과에서 종목을 선택했을 때 호출
  void _selectStock(Map<String, String> stock) {
    setState(() {
      _selectedStockName = stock['name'];
      _selectedStockTicker = stock['ticker'];
      _selectedCurrentPrice = double.tryParse(stock['price'] ?? '0');
      _searchController.text = stock['name']!;
      _showSearchResults = false;
    });
  }

  /// "종목 저장" 버튼 탭 시 호출
  /// 유효성 검사 후 PortfolioItem을 생성하여 반환
  void _saveStock() {
    if (_selectedStockName == null || _buyPrice <= 0 || _quantity <= 0) {
      // 필수 입력값이 없으면 스낵바로 안내
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 올바르게 입력해주세요.')));
      return;
    }

    final item = PortfolioItem(
      name: _selectedStockName!,
      ticker: _selectedStockTicker!,
      buyPrice: _buyPrice,
      currentPrice: _selectedCurrentPrice ?? _buyPrice,
      quantity: _quantity,
    );

    Navigator.pop(context, item);
  }

  @override
  Widget build(BuildContext context) {
    // 키보드 높이만큼 패딩을 추가하여 입력 필드가 가려지지 않도록 함
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // 하단 시트 둥근 모서리 + 흰색 배경
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 드래그 핸들
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // 헤더: "종목 추가" + 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '종목 추가',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  // 닫기(X) 버튼
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 종목 검색 라벨
              const Text(
                '종목 검색',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // 종목 검색 입력 필드
              _buildSearchField(),

              // 검색 결과 드롭다운
              if (_showSearchResults && _filteredStocks.isNotEmpty)
                _buildSearchResults(),

              const SizedBox(height: 24),

              // 매수가 라벨
              const Text(
                '매수가',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // 매수가 입력 필드 (숫자 + "원" 접미사)
              _buildPriceField(),

              const SizedBox(height: 24),

              // 보유 수량 라벨
              const Text(
                '보유 수량',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // 보유 수량 입력 필드
              _buildQuantityField(),

              const SizedBox(height: 20),

              // 예상 투자금액 표시
              _buildEstimatedAmount(),

              const SizedBox(height: 24),

              // "종목 저장" 버튼
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 종목 검색 입력 필드 위젯
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _showSearchResults = value.isNotEmpty;
            // 텍스트가 변경되면 이전 선택 초기화
            if (_selectedStockName != null && value != _selectedStockName) {
              _selectedStockName = null;
              _selectedStockTicker = null;
              _selectedCurrentPrice = null;
            }
          });
        },
        decoration: InputDecoration(
          hintText: '종목명 또는 코드 입력',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// 종목 검색 결과 드롭다운 목록
  Widget _buildSearchResults() {
    final results = _filteredStocks;
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: results.length,
        separatorBuilder: (_, _) =>
            Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (context, index) {
          final stock = results[index];
          return ListTile(
            dense: true,
            title: Text(
              stock['name']!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              stock['ticker']!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            trailing: Text(
              formatPrice(double.parse(stock['price']!), stock['currency']!),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            onTap: () => _selectStock(stock),
          );
        },
      ),
    );
  }

  /// 매수가 입력 필드 (숫자 입력 + "원" 접미사)
  Widget _buildPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _priceController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}), // 예상 투자금액 갱신
        decoration: InputDecoration(
          suffixText: '원',
          suffixStyle: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  /// 보유 수량 입력 필드
  Widget _buildQuantityField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}), // 예상 투자금액 갱신
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  /// 예상 투자금액 표시 영역
  Widget _buildEstimatedAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '예상 투자금액',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
        Text(
          formatPrice(_estimatedAmount, '₩'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }

  /// "종목 저장" 버튼 위젯
  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _saveStock,
          style: ElevatedButton.styleFrom(
            // 이미지와 동일한 보라색 계열 버튼
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check, size: 20),
              SizedBox(width: 8),
              Text(
                '종목 저장',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
