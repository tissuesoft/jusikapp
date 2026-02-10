// 주식 종목 데이터 모델 및 관련 열거형을 정의하는 파일

/// 투자 추천 의견을 나타내는 열거형
enum Recommendation {
  strongBuy, // 강력 매수 추천
  buy, // 매수 추천
  hold, // 관망 (보유 유지)
  sell, // 매도 추천
  strongSell, // 강력 매도 추천
}

/// 주식이 상장된 거래소(시장)를 나타내는 열거형
enum Market {
  kospi, // 한국 코스피 시장
  kosdaq, // 한국 코스닥 시장
  nyse, // 미국 뉴욕증권거래소
  nasdaq, // 미국 나스닥 시장
}

/// 개별 주식 종목의 정보를 담는 불변(immutable) 데이터 모델 클래스
class Stock {
  final String name; // 종목명
  final String ticker; // 종목 티커(심볼) 코드
  final double currentPrice; // 현재가
  final double changePercent; // 전일 대비 변동률(%)
  final double changeAmount; // 전일 대비 변동 금액
  final Recommendation recommendation; // 투자 추천 의견
  final Market market; // 상장 거래소
  final String currency; // 거래 통화 (예: KRW, USD)
  final double marketCap; // 시가총액
  final double per; // 주가수익비율(PER)
  final double volume; // 거래량
  final List<double> priceHistory; // 과거 가격 이력 목록
  final String sector; // 업종(섹터)
  final String description; // 종목 설명

  const Stock({
    required this.name,
    required this.ticker,
    required this.currentPrice,
    required this.changePercent,
    required this.changeAmount,
    required this.recommendation,
    required this.market,
    required this.currency,
    required this.marketCap,
    required this.per,
    required this.volume,
    required this.priceHistory,
    required this.sector,
    required this.description,
  });

  /// 한국 시장(코스피 또는 코스닥) 상장 종목인지 여부를 반환한다
  bool get isKorean => market == Market.kospi || market == Market.kosdaq;

  /// 전일 대비 변동률이 0 이상(상승 또는 보합)인지 여부를 반환한다
  bool get isPositive => changePercent >= 0;

  /// 상장 거래소의 표시용 라벨 문자열을 반환한다
  String get marketLabel {
    switch (market) {
      case Market.kospi:
        return 'KOSPI';
      case Market.kosdaq:
        return 'KOSDAQ';
      case Market.nyse:
        return 'NYSE';
      case Market.nasdaq:
        return 'NASDAQ';
    }
  }

  /// 투자 추천 의견의 한국어 라벨 문자열을 반환한다
  String get recommendationLabel {
    switch (recommendation) {
      case Recommendation.strongBuy:
        return '강력 매수';
      case Recommendation.buy:
        return '매수';
      case Recommendation.hold:
        return '관망';
      case Recommendation.sell:
        return '매도';
      case Recommendation.strongSell:
        return '강력 매도';
    }
  }
}
