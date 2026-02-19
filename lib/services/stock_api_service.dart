// 주식 API 서비스 파일
// 실시간 주식 가격 조회 등 API 호출을 담당한다

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../models/portfolio.dart';
// JWT 토큰 관리를 위한 AuthService import
import 'auth_service.dart';

/// 주식 API 서비스 클래스
/// 포트폴리오 아이템의 실시간 가격을 조회하는 기능을 제공
/// 모든 API 호출 시 AuthService에 저장된 JWT 토큰을 헤더에 포함한다
class StockApiService {
  /// 백엔드 베이스 URL (Android 에뮬레이터는 10.0.2.2:3000 사용)
  static String get _baseUrl => apiBaseUrl;

  /// 모든 API 요청에 공통으로 포함할 헤더를 생성하는 헬퍼 메서드
  /// AuthService에서 JWT 토큰을 가져와 Authorization 헤더에 추가한다
  /// [extraHeaders] 추가 헤더가 필요한 경우 (예: Content-Type) 병합한다
  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    // 1. AuthService에서 인증 헤더(Authorization: Bearer <토큰>)를 가져온다
    final headers = <String, String>{...AuthService.instance.authHeaders};
    // 2. 추가 헤더가 있으면 병합 (예: Content-Type: application/json)
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  /// 서버에서 포트폴리오 홈 데이터를 가져오는 GET 요청
  /// GET /portfolio/home 에서 요약 정보 + 보유 종목 리스트를 조회한다
  ///
  /// 서버 응답 구조: { "summary": { ... }, "stocks": [ ... ] }
  /// Header: Authorization: Bearer <JWT 토큰>
  /// 반환: PortfolioHomeResponse 객체 (실패 시 null)
  Future<PortfolioHomeResponse?> fetchPortfolioHome() async {
    try {
      print('📡 포트폴리오 홈 데이터 요청 시작: $_baseUrl/portfolio/home');
      
      // http.get으로 서버에서 포트폴리오 데이터를 조회
      // _buildHeaders()로 JWT 인증 헤더를 포함한다
      final headers = _buildHeaders();
      print('📤 요청 헤더: $headers');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/portfolio/home'),
        headers: headers,
      );

      print('📥 응답 상태 코드: ${response.statusCode}');
      print('📥 응답 본문: ${response.body}');

      // HTTP 상태 코드가 200(성공)인지 확인
      if (response.statusCode == 200) {
        // JSON 문자열을 Map으로 디코딩 후 PortfolioHomeResponse로 변환
        final data = json.decode(response.body) as Map<String, dynamic>;
        final result = PortfolioHomeResponse.fromJson(data);
        print('✅ 포트폴리오 데이터 파싱 성공: ${result.stocks.length}개 종목');
        return result;
      } else {
        print('❌ 포트폴리오 조회 실패: ${response.statusCode}');
        print('응답 본문: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ 포트폴리오 홈 API 호출 실패: $e');
      print('스택 트레이스: $stackTrace');
      return null;
    }
  }

  /// 포트폴리오 아이템의 현재가를 API에서 조회하여 업데이트
  ///
  /// [items] 업데이트할 포트폴리오 아이템 리스트
  /// 반환: 업데이트된 포트폴리오 아이템 리스트
  Future<List<PortfolioItem>> fetchPortfolioPrices(
    List<PortfolioItem> items,
  ) async {
    try {
      // TODO: 실제 API 호출로 교체
      // 현재는 Mock 동작: 2초 대기 후 랜덤 가격 변동 시뮬레이션
      await Future.delayed(const Duration(seconds: 2));

      // 각 종목의 현재가를 시뮬레이션 (±5% 범위 내 랜덤 변동)
      return items.map((item) {
        final randomChange =
            (item.currentPrice * 0.05) *
            (DateTime.now().millisecond % 10 - 5) /
            5;
        final newPrice = item.currentPrice + randomChange;

        return PortfolioItem(
          name: item.name,
          ticker: item.ticker,
          buyPrice: item.buyPrice,
          currentPrice: newPrice,
          quantity: item.quantity,
        );
      }).toList();

      /*
      // 실제 API 호출 예시 (사용 시 주석 해제)
      final tickers = items.map((e) => e.ticker).join(',');
      final response = await http.get(
        Uri.parse('$_baseUrl/stocks/prices?tickers=$tickers'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        return items.map((item) {
          final priceData = data[item.ticker];
          if (priceData != null) {
            return PortfolioItem(
              name: item.name,
              ticker: item.ticker,
              buyPrice: item.buyPrice,
              currentPrice: priceData['currentPrice'].toDouble(),
              quantity: item.quantity,
            );
          }
          return item;
        }).toList();
      } else {
        throw Exception('Failed to load stock prices');
      }
      */
    } catch (e) {
      // 에러 발생 시 기존 데이터를 그대로 반환
      print('API 호출 실패: $e');
      return items;
    }
  }

  /// 포트폴리오에 종목을 추가하는 POST 요청
  /// 서버에 종목명, 매수가, 수량을 전송한다
  ///
  /// [item] 추가할 포트폴리오 아이템
  /// 반환: 성공 시 true, 실패 시 false
  Future<bool> addPortfolioItem(PortfolioItem item) async {
    try {
      // http.post로 서버에 종목 데이터를 JSON 형태로 전송
      // _buildHeaders()로 JWT 인증 + Content-Type 헤더를 포함한다
      final response = await http.post(
        Uri.parse('$_baseUrl/portfolio'),
        headers: _buildHeaders(
          extraHeaders: {'Content-Type': 'application/json'},
        ),
        // PortfolioItem 데이터를 서버가 기대하는 형태로 변환
        body: json.encode({
          'stock_name': item.name, // 종목명 (예: "카카오뱅크")
          'avg_price': item.buyPrice, // 매수가 (예: 160000)
          'quantity': item.quantity, // 보유 수량 (예: 10)
        }),
      );

      // HTTP 상태 코드가 200번대(성공)인지 확인
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('포트폴리오 추가 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('포트폴리오 추가 API 호출 실패: $e');
      return false;
    }
  }

  /// 특정 종목의 현재가를 조회
  ///
  /// [ticker] 종목 코드
  /// 반환: 현재 가격 (실패 시 null)
  Future<double?> fetchStockPrice(String ticker) async {
    try {
      // TODO: 실제 API 호출로 교체
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock 동작: 랜덤 가격 반환
      return 50000.0 + (DateTime.now().millisecond * 10);

      /*
      // 실제 API 호출 예시 (사용 시 주석 해제)
      final response = await http.get(
        Uri.parse('$_baseUrl/stocks/$ticker/price'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['currentPrice'].toDouble();
      } else {
        return null;
      }
      */
    } catch (e) {
      print('API 호출 실패: $e');
      return null;
    }
  }
}
