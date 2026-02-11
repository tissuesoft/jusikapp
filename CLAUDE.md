# CLAUDE.md - 프로젝트 규칙

## 간단한 주석
- 함수나 변수 클래스 정의에 간단한 주석 작성

## 초보자를 위한 설명
- 플러터를 처음 배우는 초보자 수준의 개발자에 맞춰 메소드 및 플러터 함수 주석 추가
- ex)  Widget _buildPriceField => Widget과 _buildPriceField함수에 대해 각각 나누어 주석
- ex) StatefulWidget override Static 등 주요키워드에 대한 주석 설명 추가
- 코드 컨텍스트가 다음으로 어디로 진행되는지 주석 설명 추가

## 코드 작성 규칙

- 언어: Dart (Flutter)
- 테마 색상: 파란색 계열 (`0xFF2563EB`)
- 상승: 빨간색 (`0xFFC62828`), 하락: 파란색 (`0xFF2563EB`)
- 추천 등급: 강력매수, 매수, 관망, 매도, 강력매도
- 시장: KOSPI, KOSDAQ, NYSE, NASDAQ
- 모든 금액 표시는 `formatters.dart`의 유틸 함수를 사용한다.
- 한국 원화는 `₩`, 미국 달러는 `$` 기호를 사용한다.
