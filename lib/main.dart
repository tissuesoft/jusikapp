import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// 카카오 SDK 초기화를 위한 import
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/kakao_login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/add_multiple_stocks_screen.dart';

void main() async {
  // Flutter 엔진 초기화 (카카오 SDK 초기화 전 필수)
  WidgetsFlutterBinding.ensureInitialized();

  // 카카오 SDK 초기화 - 네이티브 앱 키를 사용하여 SDK를 활성화
  KakaoSdk.init(nativeAppKey: '3a57d30e596cc6d2aa3b9e6b80a0a23f');

  // TODO: 키 해시 확인 후 이 코드 삭제
  // 카카오 개발자 사이트에 등록할 키 해시를 콘솔에 출력
  var keyHash = await KakaoSdk.origin;
  print('카카오 키 해시: $keyHash');

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
        '/add-stocks': (context) => const AddMultipleStocksScreen(),
        '/main': (context) => const MainScreen(),
      },
      // onGenerateRoute: 라우트 이동 시 arguments(인자)를 전달받기 위한 설정
      // '/onboarding' 라우트에 카카오 로그인에서 가져온 사용자 정보를 전달
      onGenerateRoute: (settings) {
        if (settings.name == '/onboarding') {
          // arguments로 전달된 Map에서 사용자 이름과 프로필 이미지 URL 추출
          final args = settings.arguments as Map<String, String?>?;
          return MaterialPageRoute(
            builder: (context) => OnboardingScreen(
              userName: args?['userName'] ?? '사용자',
              profileImageUrl: args?['profileImageUrl'],
            ),
          );
        }
        return null;
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
  
  // HomeScreen에 접근하기 위한 GlobalKey
  final GlobalKey _homeScreenKey = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 라우트 인자로 새로고침 요청이 있는지 확인
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'refresh') {
      // HomeScreen의 refreshPortfolio 메서드 호출 (dynamic 사용)
      final homeScreenState = _homeScreenKey.currentState;
      if (homeScreenState != null) {
        try {
          (homeScreenState as dynamic).refreshPortfolio();
        } catch (e) {
          print('새로고침 호출 실패: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeScreenKey),
          const SettingsScreen(),
        ],
      ),
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
