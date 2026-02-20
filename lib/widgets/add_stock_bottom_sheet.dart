// 종목 추가 하단 시트(Bottom Sheet) 위젯 파일
// "종목 추가" 버튼 탭 시 하단에서 올라오는 입력 폼을 제공한다

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/portfolio.dart';
import '../data/mock_data.dart';
import '../utils/formatters.dart';
import '../services/stock_api_service.dart';

/// 종목 추가 하단 시트를 표시하는 함수
/// [saveToServer] true면 버튼 탭 시 서버에 저장 후 반환, false면 카드만 추가용으로 PortfolioItem만 반환
Future<PortfolioItem?> showAddStockBottomSheet(
  BuildContext context, {
  bool saveToServer = true,
}) {
  return showModalBottomSheet<PortfolioItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddStockBottomSheet(saveToServer: saveToServer),
  );
}

/// 종목 추가 하단 시트 내부 위젯 (StatefulWidget)
/// 종목 검색, 매수가, 보유 수량 입력 폼과 예상 투자금액 표시
class _AddStockBottomSheet extends StatefulWidget {
  /// true: 버튼 탭 시 서버 저장 후 반환 / false: 검증만 하고 PortfolioItem 반환(완료 시 일괄 저장용)
  final bool saveToServer;

  const _AddStockBottomSheet({this.saveToServer = true});

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
  bool _isSaving = false; // 저장 중 상태
  String? _searchError; // 종목명 미입력 시 필드 하단 에러 문구
  String? _priceError; // 매수가 0원일 때 필드 하단 에러 문구
  String? _quantityError; // 보유 수량 0개일 때 필드 하단 에러 문구
  final _apiService = StockApiService(); // API 서비스 인스턴스

  /// 안내 메시지(SnackBar)를 안전하게 표시
  void _showMessage(String message, {Color? backgroundColor}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      debugPrint('ScaffoldMessenger를 찾지 못했습니다: $message');
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// 매수가 입력값을 double로 파싱
  double get _buyPrice {
    final text = _priceController.text.replaceAll(',', '').trim();
    return double.tryParse(text) ?? 0;
  }

  /// 보유 수량 입력값을 int로 파싱
  int get _quantity {
    return int.tryParse(_quantityController.text.trim()) ?? 0;
  }

  /// 매수가 형식 검증: 파싱 실패, 선행 0(0400 등) → false
  bool get _isPriceValid {
    final text = _priceController.text.replaceAll(',', '').trim();
    if (text.isEmpty) return false;
    if (double.tryParse(text) == null) return false;
    if (text.startsWith('0') && text.length > 1) return false;
    return true;
  }

  /// 보유 수량 형식 검증: 파싱 실패, 선행 0(0400 등) → false
  bool get _isQuantityValid {
    final text = _quantityController.text.trim();
    if (text.isEmpty) return false;
    if (int.tryParse(text) == null) return false;
    if (text.startsWith('0') && text.length > 1) return false;
    return true;
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

  /// "종목 추가" 버튼 탭 시 호출
  /// saveToServer true면 서버 저장 후 반환, false면 검증만 하고 PortfolioItem 반환(화면에 카드 추가용)
  Future<void> _onAddStockTap() async {
    if (_isSaving) return;
    _isSaving = true;
    setState(() {});

    FocusScope.of(context).unfocus();

    final stockName = _searchController.text.trim();

    final priceInvalid = !_isPriceValid;
    final quantityInvalid = !_isQuantityValid;
    final priceZero = _buyPrice <= 0;
    final quantityZero = _quantity <= 0;

    if (stockName.isEmpty ||
        priceInvalid ||
        quantityInvalid ||
        priceZero ||
        quantityZero) {
      setState(() {
        _isSaving = false;
        _searchError = stockName.isEmpty ? '필수 입력 값입니다' : null;
        _priceError = priceInvalid
            ? '입력된 값이 올바르지 않습니다'
            : (priceZero ? '매수가격은 0원 이상이어야 합니다' : null);
        _quantityError = quantityInvalid
            ? '입력된 값이 올바르지 않습니다'
            : (quantityZero ? '보유 수량은 최소 1개 이상이어야 합니다' : null);
      });
      if (stockName.isEmpty || quantityInvalid || quantityZero) {
        _showMessage('종목명을 입력하고, 매수가/수량을 올바르게 입력해주세요.');
      }
      return;
    }

    setState(() {
      _searchError = null;
      _priceError = null;
      _quantityError = null;
    });

    final item = PortfolioItem(
      name: stockName,
      ticker: _selectedStockTicker ?? '',
      buyPrice: _buyPrice,
      currentPrice: _selectedCurrentPrice ?? _buyPrice,
      quantity: _quantity,
    );

    if (!widget.saveToServer) {
      if (!mounted) return;
      Navigator.pop(context, item);
      return;
    }

    try {
      final success = await _apiService.addPortfolioItem(item);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context, item);
      } else {
        // 500 등 서버 에러 시: 매수가/수량 필드와 동일하게 _searchError 설정 후 setState
        setState(() {
          _isSaving = false;
          _searchError = '존재하지 않는 종목입니다';
        });
        _showMessage(
          '종목 저장에 실패했습니다. 다시 시도해주세요.',
          backgroundColor: Colors.red.shade400,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _searchError = '존재하지 않는 종목입니다';
      });
      _showMessage(
        '종목 저장 중 오류가 발생했습니다: $e',
        backgroundColor: Colors.red.shade400,
      );
    }
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

              // "종목 추가" 버튼
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 종목 검색 입력 필드 위젯
  /// _searchError가 있으면 테두리 빨간색 + 하단에 에러 문구 표시 (매수가/수량 필드와 동일 패턴)
  Widget _buildSearchField() {
    final hasError = _searchError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? Colors.red : Colors.grey.shade200,
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchError = null; // 입력 시 에러 제거 (매수가/수량 필드와 동일)
                _showSearchResults = value.isNotEmpty;
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
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _searchError!,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
        ],
      ],
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
  /// _priceError가 있으면 테두리 빨간색 + 하단에 에러 문구 표시
  Widget _buildPriceField() {
    final hasError = _priceError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {
              _priceError = null; // 입력 시 에러 제거
            }),
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
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _priceError!,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
        ],
      ],
    );
  }

  /// 보유 수량 입력 필드
  /// _quantityError가 있으면 테두리 빨간색 + 하단에 에러 문구 표시
  Widget _buildQuantityField() {
    final hasError = _quantityError != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: hasError ? Border.all(color: Colors.red, width: 1.5) : null,
          ),
          child: TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {
              _quantityError = null; // 입력 시 에러 제거
            }),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 15),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            _quantityError!,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
          ),
        ],
      ],
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

  /// "종목 추가" 버튼 위젯
  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _onAddStockTap,
          style: ElevatedButton.styleFrom(
            // 이미지와 동일한 보라색 계열 버튼
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '종목 추가',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
