import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/kakao_login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/add_multiple_stocks_screen.dart';

void main() {
  runApp(const StockRecommenderApp());
}

class StockRecommenderApp extends StatelessWidget {
  const StockRecommenderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '주식 추천',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansKrTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      // 스플래시 화면을 초기 화면으로 설정
      home: const SplashScreen(),
      // 네임드 라우트: 스플래시 → 로그인 → 온보딩 → (종목 추가) → 메인 전환용
      routes: {
        '/login': (context) => const KakaoLoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(
              userName: '홍길동', // TODO: 실제 로그인한 사용자 이름으로 변경
            ),
        '/add-stocks': (context) => const AddMultipleStocksScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [HomeScreen(), SettingsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      // bottomNavigationBar: Container(
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withValues(alpha: 0.05),
      //         blurRadius: 10,
      //         offset: const Offset(0, -2),
      //       ),
      //     ],
      //   ),
      //   child: NavigationBar(
      //     selectedIndex: _currentIndex,
      //     onDestinationSelected: (index) {
      //       setState(() => _currentIndex = index);
      //     },
      //     backgroundColor: Colors.white,
      //     surfaceTintColor: Colors.white,
      //     indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
      //     destinations: const [
      //       NavigationDestination(
      //         icon: Icon(Icons.home_outlined),
      //         selectedIcon: Icon(Icons.home),
      //         label: '홈',
      //       ),
      //       NavigationDestination(
      //         icon: Icon(Icons.settings_outlined),
      //         selectedIcon: Icon(
      //           Icons.settings,
      //           color: Colors.black87,
      //           size: 26,
      //         ),
      //         label: '설정',
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
