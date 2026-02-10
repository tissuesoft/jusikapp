// AI 분석 채팅 메시지 모델 정의 파일
// 채팅 화면에서 사용되는 메시지 데이터 구조를 정의한다

/// 채팅 메시지 발신자 유형 (AI 봇 또는 사용자)
enum MessageSender {
  ai,   // AI 봇 메시지
  user, // 사용자 메시지
}

/// 메시지 내 특수 콘텐츠 유형 (일반 텍스트, 정보 카드, 전망 분석 등)
enum ContentType {
  text,       // 일반 텍스트 메시지
  infoCard,   // 주요 호재/이슈 정보 카드
  sentiment,  // 긍정/중립/부정 요인 분석 바
}

/// 정보 카드 내 데이터 항목 (제목 + 항목 리스트)
class InfoCardData {
  final String title;          // 카드 제목 (예: "주요 호재")
  final List<String> items;    // 세부 항목 리스트

  const InfoCardData({
    required this.title,
    required this.items,
  });
}

/// 전망 분석 요인 데이터 (긍정/중립/부정 비율)
class SentimentData {
  final double positive;  // 긍정 요인 비율 (0~100)
  final double neutral;   // 중립 요인 비율 (0~100)
  final double negative;  // 부정 요인 비율 (0~100)

  const SentimentData({
    required this.positive,
    required this.neutral,
    required this.negative,
  });
}

/// 채팅 메시지 한 건의 데이터 모델
class ChatMessage {
  final MessageSender sender;       // 메시지 발신자 (AI/사용자)
  final String text;                // 메시지 본문 텍스트
  final String timestamp;           // 표시용 타임스탬프 (예: "오후 2:15")
  final ContentType contentType;    // 콘텐츠 유형
  final InfoCardData? infoCard;     // 정보 카드 데이터 (contentType이 infoCard일 때)
  final SentimentData? sentiment;   // 전망 분석 데이터 (contentType이 sentiment일 때)
  final String? additionalText;     // 특수 콘텐츠 하단 추가 텍스트

  const ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.contentType = ContentType.text,
    this.infoCard,
    this.sentiment,
    this.additionalText,
  });
}
