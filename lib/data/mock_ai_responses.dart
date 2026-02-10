// 모의 AI 분석 응답 데이터 파일
// 각 보유 종목에 대한 AI 채팅 분석 시나리오를 제공한다
// 종목 ticker를 키로 사용하여 해당 종목의 대화 내역을 반환한다

import '../models/chat_message.dart';

/// 종목별 초기 AI 인사 메시지를 생성한다
/// [stockName]: 종목명
ChatMessage getGreetingMessage(String stockName) {
  return ChatMessage(
    sender: MessageSender.ai,
    text: '안녕하세요! $stockName에 대해 궁금한 점이 있으시군요. 무엇이든 물어보세요! 📊',
    timestamp: '오후 2:15',
  );
}

/// 종목별 초기 분석 메시지 목록을 생성한다
/// [stockName]: 종목명, [ticker]: 종목 코드
/// 인사 메시지 + 자동 분석 메시지를 포함한 리스트를 반환
List<ChatMessage> getInitialMessages(String stockName, String ticker) {
  // 종목별 맞춤 분석 데이터 조회
  final data = _stockAnalysisData[ticker];

  if (data == null) {
    // 분석 데이터가 없는 종목은 기본 인사만 반환
    return [
      getGreetingMessage(stockName),
    ];
  }

  return [
    // 인사 메시지
    getGreetingMessage(stockName),
    // 사용자 질문 (자동 생성)
    const ChatMessage(
      sender: MessageSender.user,
      text: '현재 투자 분석 결과를 알려주세요',
      timestamp: '오후 2:16',
    ),
    // AI 주요 호재/리스크 분석
    ChatMessage(
      sender: MessageSender.ai,
      text: '$stockName의 현재 투자 포인트를 분석해드릴게요:',
      timestamp: '오후 2:17',
      contentType: ContentType.infoCard,
      infoCard: data['infoCard'] as InfoCardData,
      additionalText: data['infoAdditional'] as String,
    ),
    // 사용자 추가 질문 (자동 생성)
    const ChatMessage(
      sender: MessageSender.user,
      text: '앞으로 전망은 어떤가요?',
      timestamp: '오후 2:18',
    ),
    // AI 전망 분석 (긍정/중립/부정 비율)
    ChatMessage(
      sender: MessageSender.ai,
      text: '$stockName의 중장기 전망을 분석해드릴게요:',
      timestamp: '오후 2:19',
      contentType: ContentType.sentiment,
      sentiment: data['sentiment'] as SentimentData,
      additionalText: data['sentimentAdditional'] as String,
    ),
  ];
}

/// 사용자가 직접 질문할 때 반환되는 모의 AI 응답 목록
/// 순서대로 반환되며, 마지막 응답 이후 순환된다
List<ChatMessage> getMockResponses(String stockName, String ticker) {
  return [
    ChatMessage(
      sender: MessageSender.ai,
      text: '$stockName의 최근 거래량이 평소 대비 약 35% 증가한 상태입니다. 기관 투자자의 매수세가 유입되고 있어 긍정적인 신호로 해석됩니다.',
      timestamp: '',
    ),
    ChatMessage(
      sender: MessageSender.ai,
      text: '현재 $stockName의 PER은 동종 업계 평균 대비 적정 수준이며, PBR 기준으로는 저평가 구간에 있습니다. 밸류에이션 매력이 존재합니다.',
      timestamp: '',
    ),
    ChatMessage(
      sender: MessageSender.ai,
      text: '기술적 분석 관점에서 $stockName은 20일 이동평균선을 지지선으로 반등하는 패턴을 보이고 있습니다. 단기 저항선 돌파 시 추가 상승 여력이 있습니다.',
      timestamp: '',
    ),
    ChatMessage(
      sender: MessageSender.ai,
      text: '$stockName 관련 리스크 요인으로는 환율 변동성과 글로벌 경기 둔화 우려가 있습니다. 다만 내수 매출 비중이 높아 영향은 제한적입니다.',
      timestamp: '',
    ),
    ChatMessage(
      sender: MessageSender.ai,
      text: '종합적으로 $stockName은 현재 적극적인 매수보다는 분할 매수 전략이 유효합니다. 목표가 도달 시 일부 차익 실현을 고려해보세요.',
      timestamp: '',
    ),
  ];
}

/// 종목 코드별 분석 데이터 맵
/// 주요 호재 정보 카드와 전망 분석 비율을 포함한다
final Map<String, Map<String, dynamic>> _stockAnalysisData = {
  // 삼성전자
  '005930': {
    'infoCard': const InfoCardData(
      title: '주요 호재',
      items: [
        'HBM3E 양산 및 AI 반도체 수요 급증',
        '파운드리 수주 확대 기대',
        '주주환원 정책 강화 발표',
      ],
    ),
    'infoAdditional': '특히 AI 서버용 고대역폭 메모리(HBM) 매출이 크게 성장하고 있어요.',
    'sentiment': const SentimentData(positive: 78, neutral: 15, negative: 7),
    'sentimentAdditional': 'AI 반도체 슈퍼사이클과 함께 중장기 성장이 기대됩니다.',
  },
  // SK하이닉스
  '000660': {
    'infoCard': const InfoCardData(
      title: '주요 호재',
      items: [
        'HBM3E 시장 점유율 1위 유지',
        'AI 서버 수요 폭발적 성장',
        '실적 서프라이즈 연속 달성',
      ],
    ),
    'infoAdditional': 'NVIDIA향 HBM 납품 물량 확대로 실적 호조가 이어지고 있어요.',
    'sentiment': const SentimentData(positive: 85, neutral: 10, negative: 5),
    'sentimentAdditional': 'AI 인프라 투자 확대 수혜주로 지속적인 상승 가능성이 높습니다.',
  },
  // NAVER
  '035420': {
    'infoCard': const InfoCardData(
      title: '주요 이슈',
      items: [
        'AI 검색 서비스 "큐:" 출시',
        '네이버 클라우드 성장세 둔화',
        '일본 라인야후 지분 문제',
      ],
    ),
    'infoAdditional': 'AI 전환 속도가 관건이며, 클라우드와 커머스 부문 실적이 주목됩니다.',
    'sentiment': const SentimentData(positive: 55, neutral: 30, negative: 15),
    'sentimentAdditional': 'AI 검색 전환 성공 여부에 따라 주가 방향이 결정될 전망입니다.',
  },
  // 카카오
  '035720': {
    'infoCard': const InfoCardData(
      title: '주요 호재',
      items: [
        '카카오톡 비즈니스 매출 성장',
        '콘텐츠 자회사 실적 개선 기대',
        '규제 리스크 완화 조짐',
      ],
    ),
    'infoAdditional': '특히 카카오톡 기반 광고·커머스 사업의 성장이 주목받고 있어요.',
    'sentiment': const SentimentData(positive: 60, neutral: 25, negative: 15),
    'sentimentAdditional': '규제 환경 안정화와 함께 점진적 회복이 예상됩니다.',
  },
  // 현대차
  '005380': {
    'infoCard': const InfoCardData(
      title: '주요 호재',
      items: [
        '미국 조지아 공장 본격 가동',
        '전기차 아이오닉 시리즈 호조',
        '인도법인 IPO 성공',
      ],
    ),
    'infoAdditional': '글로벌 판매량 증가와 전기차 라인업 확대가 긍정적입니다.',
    'sentiment': const SentimentData(positive: 75, neutral: 17, negative: 8),
    'sentimentAdditional': '전기차 전환 가속과 글로벌 시장 확대로 안정적 성장이 전망됩니다.',
  },
};

/// 추천 사용자 질문 목록 (채팅 하단에 표시할 수 있는 예시 질문)
List<String> getSuggestedQuestions(String stockName) {
  return [
    '오늘 급등/급락한 이유가 뭔가요?',
    '앞으로 전망은 어떤가요?',
    '$stockName의 적정 주가는?',
    '매수/매도 타이밍은 언제인가요?',
    '경쟁사 대비 장단점은?',
    '최근 뉴스 요약해줘',
  ];
}
