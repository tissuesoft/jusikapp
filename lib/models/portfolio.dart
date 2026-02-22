// 포트폴리오 보유 종목 모델 정의 파일
// 사용자가 보유한 개별 종목의 매수 정보와 현재 평가 정보를 담는다

/// 포트폴리오 요약 정보를 담는 데이터 클래스
/// 서버 응답의 "summary" 객체를 파싱하여 사용한다
class PortfolioSummary {
  final double totalInvestAmount;  // 총 매입 금액
  final double totalCurrentValue;  // 총 평가 금액
  final double totalProfit;        // 총 평가 손익
  final double totalProfitRate;    // 총 수익률 (%)
  final int stockCount;            // 보유 종목 수

  const PortfolioSummary({
    required this.totalInvestAmount,
    required this.totalCurrentValue,
    required this.totalProfit,
    required this.totalProfitRate,
    required this.stockCount,
  });

  /// JSON 데이터를 PortfolioSummary 객체로 변환하는 팩토리 생성자
  /// 서버 응답의 "summary" 부분을 Dart 객체로 파싱할 때 사용한다
  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      totalInvestAmount: (json['total_invest_amount'] as num).toDouble(),
      totalCurrentValue: (json['total_current_value'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num).toDouble(),
      totalProfitRate: (json['total_profit_rate'] as num).toDouble(),
      stockCount: (json['stock_count'] as num).toInt(),
    );
  }
}

/// 포트폴리오 홈 API 응답 전체를 담는 클래스
/// summary(요약 정보) + stocks(종목 리스트)를 함께 관리한다
class PortfolioHomeResponse {
  final PortfolioSummary summary; // 포트폴리오 요약 정보
  final List<PortfolioItem> stocks; // 보유 종목 리스트

  const PortfolioHomeResponse({
    required this.summary,
    required this.stocks,
  });

  /// JSON 데이터를 PortfolioHomeResponse 객체로 변환하는 팩토리 생성자
  /// 서버 응답 전체({ summary: {...}, stocks: [...] })를 파싱한다
  /// 종목은 등록 순서(order 또는 배열 인덱스)를 보존한다
  factory PortfolioHomeResponse.fromJson(Map<String, dynamic> json) {
    final rawStocks = json['stocks'] as List<dynamic>;
    return PortfolioHomeResponse(
      summary: PortfolioSummary.fromJson(json['summary'] as Map<String, dynamic>),
      // 등록 순서 = 서버의 order 필드 또는 배열 인덱스
      stocks: rawStocks
          .asMap()
          .entries
          .map((e) => PortfolioItem.fromJson(
                e.value as Map<String, dynamic>,
                orderIndex: e.key,
              ))
          .toList(),
    );
  }
}

/// 포트폴리오 내 개별 보유 종목 정보를 담는 데이터 클래스
class PortfolioItem {
  final String name;         // 종목명
  final String ticker;       // 종목 코드
  final double buyPrice;     // 매수가 (1주당)
  final double currentPrice; // 현재가 (1주당)
  final int quantity;        // 보유 수량
  /// 등록 순서 (목록 정렬용, 서버에서 오지 않으면 배열 인덱스 사용)
  final int order;
  /// 서버에서 부여한 포트폴리오(종목) ID — 채팅 기록 조회 시 사용 (GET /portfolio/{id}/messages)
  final int? portfolioId;
  /// 서버에서 내려준 변동 금액 (원) — 없으면 profitLoss 사용
  final double? changeAmount;
  /// 서버에서 내려준 변동률(수익률, %) — 없으면 returnPercent 사용
  final double? changePercent;
  /// 전일 종가 — 어제 대비 ±원, ±% 계산용 (서버에서 optional)
  final double? previousClose;
  /// 서버에서 내려준 총 평가 금액 (current_value) — 없으면 currentPrice × quantity 사용
  final double? currentValue;
  /// 서버에서 내려준 평가 손익 (profit) — 없으면 profitLoss 사용
  final double? profit;
  /// 서버에서 내려준 수익률(%, profit_rate) — 없으면 returnPercent 사용
  final double? profitRate;

  const PortfolioItem({
    required this.name,
    required this.ticker,
    required this.buyPrice,
    required this.currentPrice,
    required this.quantity,
    this.order = 0,
    this.portfolioId,
    this.changeAmount,
    this.changePercent,
    this.previousClose,
    this.currentValue,
    this.profit,
    this.profitRate,
  });

  /// JSON에서 숫자 필드 읽기 (snake_case/camelCase 지원, 없으면 null)
  static double? _readNum(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return null;
    return (v as num).toDouble();
  }

  /// JSON 데이터를 PortfolioItem 객체로 변환하는 팩토리 생성자
  /// 서버 응답(Map)을 Dart 객체로 파싱할 때 사용한다
  /// [orderIndex] 서버에 order 필드가 없을 때 사용할 등록 순서(배열 인덱스)
  /// 예시 JSON: { "stock_name": "삼성전자", "avg_price": 160000, "current_price": 28700, "current_value": 574000, "quantity": 10 }
  factory PortfolioItem.fromJson(Map<String, dynamic> json, {int? orderIndex}) {
    final orderFromJson = (json['order'] as num?)?.toInt() ??
        (json['display_order'] as num?)?.toInt();
    return PortfolioItem(
      name: json['stock_name'] as String,                        // 종목명
      ticker: (json['stock_code'] as String?) ?? '',             // 종목코드 (없으면 빈 문자열)
      buyPrice: (json['avg_price'] as num).toDouble(),           // 매수가
      // current_price (또는 currentPrice)가 있으면 사용, 없으면 매수가를 현재가로 설정
      currentPrice: _readNum(json, 'current_price') ?? _readNum(json, 'currentPrice') ?? (json['avg_price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),               // 보유 수량
      order: orderFromJson ?? orderIndex ?? 0,                    // 등록 순서
      portfolioId: (json['portfolio_id'] as num?)?.toInt(),     // 채팅 기록 조회용 ID
      changeAmount: (json['change_amount'] as num?)?.toDouble(), // 변동 금액(원)
      changePercent: (json['change_percent'] as num?)?.toDouble(), // 변동률(수익률 %)
      previousClose: (json['previous_close'] as num?)?.toDouble(), // 전일 종가 (어제 대비용)
      // current_value (또는 currentValue) — 카드 영역에 표시할 총 평가 금액
      currentValue: _readNum(json, 'current_value') ?? _readNum(json, 'currentValue'),
      profit: _readNum(json, 'profit'),
      profitRate: _readNum(json, 'profit_rate') ?? _readNum(json, 'profitRate'),
    );
  }

  /// 표시용 변동 금액 — 서버 값 우선, 없으면 매수가/현재가 기준 계산
  double get displayChangeAmount => changeAmount ?? profitLoss;

  /// 표시용 변동률(수익률 %) — 서버 값 우선, 없으면 계산
  double get displayChangePercent => changePercent ?? returnPercent;

  /// 표시용 손익 금액 — 서버 profit 우선, 없으면 profitLoss
  double get displayProfit => profit ?? profitLoss;

  /// 표시용 수익률(%) — 서버 profit_rate 우선, 없으면 returnPercent
  double get displayProfitRate => profitRate ?? returnPercent;

  /// 총 매입 금액 = 매수가 × 보유 수량
  double get totalBuyAmount => buyPrice * quantity;

  /// 총 평가 금액 — 서버 current_value 우선, 없으면 현재가 × 보유 수량
  double get totalCurrentAmount => currentValue ?? (currentPrice * quantity);

  /// 평가 손익 = 총 평가 금액 - 총 매입 금액
  double get profitLoss => totalCurrentAmount - totalBuyAmount;

  /// 수익률(%) = (평가 손익 / 총 매입 금액) × 100
  double get returnPercent => (profitLoss / totalBuyAmount) * 100;

  /// 수익 여부 (표시용 변동률 기준, 0 이상이면 true)
  bool get isPositive => displayChangePercent >= 0;

  /// 어제 대비 변동 금액 (1주 기준) — 전일 종가가 있을 때만 유효
  double get dayChangeAmount =>
      previousClose != null ? currentPrice - previousClose! : 0.0;

  /// 어제 대비 변동률(%) — 전일 종가가 있을 때만 유효
  double get dayChangePercent => previousClose != null && previousClose! != 0
      ? (dayChangeAmount / previousClose!) * 100
      : 0.0;

  /// 어제 대비 상승 여부 (표시용)
  bool get isDayPositive => dayChangeAmount >= 0;

  /// 전일 종가 존재 여부 (어제 대비 표시 가능 여부)
  bool get hasPreviousClose => previousClose != null;
}

/// GET /portfolio/{portfolioId}/messages 응답의 메시지 한 건
/// 채팅 기록 조회 시 서버가 반환하는 구조를 파싱할 때 사용
class PortfolioChatMessageDto {
  final int chatMessageId;
  final int portfolioId;
  final String role;   // "user" | "assistant"
  final String message;
  final String createdAt;

  const PortfolioChatMessageDto({
    required this.chatMessageId,
    required this.portfolioId,
    required this.role,
    required this.message,
    required this.createdAt,
  });

  factory PortfolioChatMessageDto.fromJson(Map<String, dynamic> json) {
    return PortfolioChatMessageDto(
      chatMessageId: (json['chat_message_id'] as num).toInt(),
      portfolioId: (json['portfolio_id'] as num).toInt(),
      role: json['role'] as String,
      message: json['message'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
