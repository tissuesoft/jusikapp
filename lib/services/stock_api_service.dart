// 주식 API 서비스 파일
// 실시간 주식 가격 조회 등 API 호출을 담당한다

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio.dart';

/// 주식 API 서비스 클래스
/// 포트폴리오 아이템의 실시간 가격을 조회하는 기능을 제공
class StockApiService {
  // TODO: 실제 API 엔드포인트로 교체 필요
  static const String _baseUrl = 'https://api.example.com';

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
        final randomChange = (item.currentPrice * 0.05) *
          (DateTime.now().millisecond % 10 - 5) / 5;
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
