// AI 분석 채팅 화면 파일
// 보유 종목의 AI 분석 결과를 채팅 형태로 보여주고,
// 사용자가 추가 질문을 입력하면 모의 응답을 제공한다

import 'package:flutter/material.dart';
import '../models/portfolio.dart';
import '../models/chat_message.dart';
import '../data/mock_ai_responses.dart';
import '../constants/colors.dart';

/// AI 분석 채팅 화면 (StatefulWidget)
/// 종목 정보를 전달받아 채팅 인터페이스로 AI 분석 결과를 표시한다
class AiAnalysisScreen extends StatefulWidget {
  final PortfolioItem item; // 분석할 보유 종목 정보

  const AiAnalysisScreen({super.key, required this.item});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  // 채팅 메시지 목록
  final List<ChatMessage> _messages = [];
  // 텍스트 입력 컨트롤러
  final TextEditingController _textController = TextEditingController();
  // 스크롤 컨트롤러 (새 메시지 시 자동 스크롤)
  final ScrollController _scrollController = ScrollController();
  // 모의 응답 인덱스 (순환 사용)
  int _responseIndex = 0;
  // AI 타이핑 애니메이션 표시 여부
  bool _isAiTyping = false;

  @override
  void initState() {
    super.initState();
    // 초기 AI 분석 메시지 로드
    _loadInitialMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 초기 메시지(인사 + 자동 분석)를 지연 로드하여 채팅 효과를 준다
  Future<void> _loadInitialMessages() async {
    final initialMessages = getInitialMessages(
      widget.item.name,
      widget.item.ticker,
    );

    // 각 메시지를 순차적으로 추가하여 실제 채팅처럼 보이게 함
    for (final message in initialMessages) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      setState(() {
        _messages.add(message);
      });
      _scrollToBottom();
    }
  }

  /// 사용자가 메시지를 전송할 때 호출
  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final now = TimeOfDay.now();
    final timestamp =
        '${now.hour > 12 ? "오후" : "오전"} ${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')}';

    // 사용자 메시지 추가
    setState(() {
      _messages.add(
        ChatMessage(
          sender: MessageSender.user,
          text: text,
          timestamp: timestamp,
        ),
      );
      _isAiTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // AI 응답을 지연 후 추가 (타이핑 효과)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;

      final responses = getMockResponses(widget.item.name, widget.item.ticker);
      final response = responses[_responseIndex % responses.length];

      final responseTime = TimeOfDay.now();
      final responseTimestamp =
          '${responseTime.hour > 12 ? "오후" : "오전"} ${responseTime.hour > 12 ? responseTime.hour - 12 : responseTime.hour}:${responseTime.minute.toString().padLeft(2, '0')}';

      setState(() {
        _isAiTyping = false;
        _messages.add(
          ChatMessage(
            sender: response.sender,
            text: response.text,
            timestamp: responseTimestamp,
            contentType: response.contentType,
            infoCard: response.infoCard,
            sentiment: response.sentiment,
            additionalText: response.additionalText,
          ),
        );
        _responseIndex++;
      });
      _scrollToBottom();
    });
  }

  /// 메시지 목록을 맨 아래로 스크롤한다
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 수익률 표시용 텍스트
    final returnText =
        '${widget.item.isPositive ? '+' : ''}${widget.item.returnPercent.toStringAsFixed(1)}%';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      // 상단 앱바: 뒤로가기 + 종목명/수익률 + 차트 아이콘 + 더보기
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 종목명
            Text(
              widget.item.name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            // 오늘 수익률
            Text(
              '오늘 $returnText ${widget.item.isPositive ? '↗' : '↘'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                // AppColors.getStockColor() 헬퍼 메서드 사용
                // isPositive가 true면 stockUp(빨간색), false면 stockDown(파란색)
                color: AppColors.getStockColor(widget.item.isPositive),
              ),
            ),
          ],
        ),
        // actions: [
        //   // 차트 아이콘 버튼
        //   IconButton(
        //     icon: const Icon(Icons.show_chart, color: Colors.black54),
        //     onPressed: () {},
        //   ),
        //   // 더보기 버튼
        //   IconButton(
        //     icon: const Icon(Icons.more_vert, color: Colors.black54),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // 채팅 메시지 목록 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // 마지막이 타이핑 인디케이터인 경우
                if (index == _messages.length && _isAiTyping) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          // 하단 메시지 입력 영역
          _buildInputArea(),
        ],
      ),
    );
  }

  /// 개별 채팅 메시지 버블 위젯을 생성한다
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 메시지 좌측 아바타 아이콘
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // AI 아바타 배경색 - AppColors.primary 사용
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          // 메시지 내용 영역
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 메시지 버블 컨테이너
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    // 사용자 메시지는 primary 색상, AI 메시지는 흰색 배경
                    color: isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 메시지 본문 텍스트
                      Text(
                        message.text,
                        style: TextStyle(
                          fontSize: 14,
                          color: isUser ? Colors.white : Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      // 정보 카드 콘텐츠 (주요 호재/이슈)
                      if (message.contentType == ContentType.infoCard &&
                          message.infoCard != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(message.infoCard!),
                      ],
                      // 전망 분석 콘텐츠 (긍정/중립/부정)
                      if (message.contentType == ContentType.sentiment &&
                          message.sentiment != null) ...[
                        const SizedBox(height: 12),
                        _buildSentimentBars(message.sentiment!),
                      ],
                      // 추가 텍스트
                      if (message.additionalText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          message.additionalText!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isUser ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 타임스탬프
                if (message.timestamp.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message.timestamp,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ],
            ),
          ),
          // 사용자 메시지 우측 여백 (아바타 없음)
          if (isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }

  /// 정보 카드 위젯 (주요 호재/리스크 항목 표시)
  Widget _buildInfoCard(InfoCardData data) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 제목 + 아이콘
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.help_outline, size: 18, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 10),
          // 세부 항목 리스트 (불릿 포인트)
          ...data.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 전망 분석 바 위젯 (긍정/중립/부정 비율 표시)
  Widget _buildSentimentBars(SentimentData data) {
    return Column(
      children: [
        // 긍정 요인: stockUp(빨간색) 사용
        _buildSentimentRow('긍정 요인', data.positive, AppColors.stockUp),
        const SizedBox(height: 8),
        // 중립 요인: 주황색 (중립을 나타내는 색상)
        _buildSentimentRow('중립 요인', data.neutral, const Color(0xFFF57C00)),
        const SizedBox(height: 8),
        // 부정 요인: stockDown(파란색) 사용
        _buildSentimentRow('부정 요인', data.negative, AppColors.stockDown),
      ],
    );
  }

  /// 개별 전망 분석 바 행 위젯
  /// [label]: 요인명, [value]: 비율(0~100), [color]: 바 색상
  Widget _buildSentimentRow(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // 요인명 라벨
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 프로그레스 바 영역
          Expanded(
            child: Stack(
              children: [
                // 배경 바
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // 실제 비율 바
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 비율 텍스트
          Text(
            '${value.toInt()}%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// AI 타이핑 인디케이터 위젯 (점 세 개 애니메이션)
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI 아바타
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              // AI 아바타 배경색 - AppColors.primary 사용
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          // 타이핑 점 애니메이션
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  /// 하단 메시지 입력 영역 위젯
  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // "+" 버튼 (추가 기능용)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: Colors.grey.shade600, size: 22),
          ),
          const SizedBox(width: 8),
          // 텍스트 입력 필드
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: '${widget.item.name}에 대해 물어보세요...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                style: const TextStyle(fontSize: 14),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 전송 버튼
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                // 전송 버튼 배경색 - AppColors.primary 사용
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// AI 타이핑 중 점 세 개 애니메이션 위젯
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 반복 애니메이션 컨트롤러 (1초 주기)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            // 각 점에 위상 차이를 둬서 순차 애니메이션 효과
            final delay = index * 0.2;
            final value = (_controller.value + delay) % 1.0;
            // 사인 함수로 부드러운 위아래 움직임
            final opacity =
                (0.3 + 0.7 * (value < 0.5 ? value * 2 : (1 - value) * 2));

            return Container(
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade400.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
