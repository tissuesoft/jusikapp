// 포트폴리오 보유 종목 모델 정의 파일
// 사용자가 보유한 개별 종목의 매수 정보와 현재 평가 정보를 담는다

/// 포트폴리오 내 개별 보유 종목 정보를 담는 데이터 클래스
class PortfolioItem {
  final String name;         // 종목명
  final String ticker;       // 종목 코드
  final double buyPrice;     // 매수가 (1주당)
  final double currentPrice; // 현재가 (1주당)
  final int quantity;        // 보유 수량

  const PortfolioItem({
    required this.name,
    required this.ticker,
    required this.buyPrice,
    required this.currentPrice,
    required this.quantity,
  });

  /// 총 매입 금액 = 매수가 × 보유 수량
  double get totalBuyAmount => buyPrice * quantity;

  /// 총 평가 금액 = 현재가 × 보유 수량
  double get totalCurrentAmount => currentPrice * quantity;

  /// 평가 손익 = 총 평가 금액 - 총 매입 금액
  double get profitLoss => totalCurrentAmount - totalBuyAmount;

  /// 수익률(%) = (평가 손익 / 총 매입 금액) × 100
  double get returnPercent => (profitLoss / totalBuyAmount) * 100;

  /// 수익 여부 (수익률 0 이상이면 true)
  bool get isPositive => returnPercent >= 0;
}
