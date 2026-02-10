// 포트폴리오 모의 데이터 파일
// 사용자의 보유 종목 더미 데이터를 제공한다

import '../models/portfolio.dart';

/// 사용자 보유 종목 목록 (이미지 기준 5종목)
final List<PortfolioItem> mockPortfolio = [
  PortfolioItem(
    name: '삼성전자',
    ticker: '005930',
    buyPrice: 80000,
    currentPrice: 94800,
    quantity: 50,
  ),
  PortfolioItem(
    name: 'SK하이닉스',
    ticker: '000660',
    buyPrice: 150000,
    currentPrice: 198150,
    quantity: 20,
  ),
  PortfolioItem(
    name: 'NAVER',
    ticker: '035420',
    buyPrice: 200000,
    currentPrice: 189600,
    quantity: 10,
  ),
  PortfolioItem(
    name: '카카오',
    ticker: '035720',
    buyPrice: 80000,
    currentPrice: 90240,
    quantity: 50,
  ),
  PortfolioItem(
    name: '현대차',
    ticker: '005380',
    buyPrice: 150000,
    currentPrice: 163050,
    quantity: 20,
  ),
];
