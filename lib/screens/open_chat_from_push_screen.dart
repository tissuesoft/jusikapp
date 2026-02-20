// 푸시 알림 탭 시 열리는 채팅 진입 화면
// portfolioId만 있을 때 포트폴리오 목록을 조회해 해당 종목의 AiAnalysisScreen으로 이동한다

import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../services/stock_api_service.dart';
import 'ai_analysis_screen.dart';

/// 푸시 알림에서 전달된 portfolioId로 포트폴리오를 조회한 뒤
/// 해당 종목의 AI 분석 채팅 화면(AiAnalysisScreen)으로 교체한다
class OpenChatFromPushScreen extends StatefulWidget {
  final int portfolioId;

  const OpenChatFromPushScreen({super.key, required this.portfolioId});

  @override
  State<OpenChatFromPushScreen> createState() => _OpenChatFromPushScreenState();
}

class _OpenChatFromPushScreenState extends State<OpenChatFromPushScreen> {
  final StockApiService _api = StockApiService();
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _resolveAndNavigate();
  }

  /// GET /portfolio/home으로 목록 조회 후 portfolioId에 해당하는 종목을 찾아 채팅 화면으로 이동
  Future<void> _resolveAndNavigate() async {
    final result = await _api.fetchPortfolioHome();
    if (!mounted) return;

    PortfolioItem? item;
    if (result != null) {
      final matched =
          result.stocks.where((e) => e.portfolioId == widget.portfolioId);
      item = matched.isNotEmpty ? matched.first : null;
    }

    setState(() => _resolved = true);

    if (!mounted) return;
    if (item != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => AiAnalysisScreen(item: item!),
        ),
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해당 종목을 찾을 수 없습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: _resolved
            ? const SizedBox.shrink()
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2563EB)),
                  SizedBox(height: 16),
                  Text(
                    '채팅을 불러오는 중...',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
      ),
    );
  }
}
