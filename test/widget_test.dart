import 'package:flutter_test/flutter_test.dart';
import 'package:stock_recommender/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const StockRecommenderApp());
    await tester.pumpAndSettle();

    expect(find.text('오늘의 추천'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('한국'), findsOneWidget);
    expect(find.text('미국'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
  });
}
