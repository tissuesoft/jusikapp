// 개인정보 처리방침 화면 파일
// 앱의 개인정보 처리방침을 표시하는 화면

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// 개인정보 처리방침 화면 위젯 (StatelessWidget)
/// 스크롤 가능한 텍스트로 개인정보 처리방침 내용 표시
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 상단 앱바 - 뒤로가기 버튼 + "개인정보 처리방침" 타이틀
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '개인정보 처리방침',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      // 스크롤 가능한 본문
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionContent(
              '[ai 주식 종목 뉴스 분석] AI 주식 종목 뉴스 분석(이하 "서비스")는 이용자의 개인정보를 중요시하며, '
              '「개인정보 보호법」 등 관련 법령을 준수합니다. 본 처리방침은 서비스에서 수집·이용·보관·파기하는 개인정보에 관한 사항을 담습니다.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('제1조 (수집하는 개인정보 항목 및 수집 방법)'),
            _buildSectionContent(
              '1. 수집 항목\n'
              '   - 회원 식별 정보: 카카오 계정 연동 시 카카오 회원번호(kakao_id), 서비스 내 부여 사용자 ID(user_id)\n'
              '   - 투자 관련 정보: 보유 종목(종목명·종목코드), 평균 매수가, 보유 수량\n'
              '   - 서비스 이용 정보: 종목별 AI 채팅 내용(질문·답변), 대화 요약(memory_summary)\n'
              '   - 기기 정보: 푸시 알림 발송을 위한 FCM(Firebase Cloud Messaging) 디바이스 토큰, 기기 유형(Android/iOS)\n'
              '   - 알림 이력: 이벤트 알림 제목·내용·발송 시각(종목 코드·포트폴리오 ID와 연계)\n\n'
              '2. 수집 방법\n'
              '   - 카카오 로그인 시 카카오 API를 통해 회원번호 수집\n'
              '   - 앱 내 종목 추가·채팅 입력·푸시 토큰 등록 시 이용자가 입력·동의한 정보 수집',
            ),

            _buildSectionTitle('제2조 (개인정보의 이용 목적)'),
            _buildSectionContent(
              '- 회원 식별, 로그인·로그아웃 등 서비스 이용 자격 관리\n'
              '- 보유 종목·평단가·수량 기반 홈 화면·현재가·손익 정보 제공\n'
              '- 종목별 AI 분석 채팅 제공(질문·답변 생성·저장·대화 요약)\n'
              '- 가격 급등락(±5%), 공시 발생, 장 마감 시 푸시 알림 및 앱 내 알림 목록 제공\n'
              '- 서비스 개선·오류 처리·법적 분쟁 대응',
            ),

            _buildSectionTitle('제3조 (개인정보의 제3자 제공 및 위탁)'),
            _buildSectionContent(
              '1. 제3자 제공\n'
              '   - 별도 동의 없이 이용자 개인정보를 제3자에게 판매·이전하지 않습니다.\n\n'
              '2. 처리 위탁(외부 서비스 이용)\n'
              '   서비스 제공을 위해 아래와 같이 개인정보가 처리·전달될 수 있습니다.\n\n'
              '   - 데이터 저장·관리: Supabase(데이터베이스·호스팅) — 회원정보, 포트폴리오, 채팅, 알림, 푸시 토큰 등 저장\n'
              '   - 로그인: 카카오 — 카카오 회원번호 수집·연동\n'
              '   - AI 채팅: OpenAI — 채팅 내용, 보유 정보·뉴스·공시·시세 요약 등 분석용으로 전달·처리\n'
              '   - 뉴스 검색: 네이버 검색 API — 종목명 기반 뉴스 검색(검색어 전달)\n'
              '   - 공시 조회: 금융감독원 DART — 종목별 공시 조회(종목·기업 정보 연계)\n'
              '   - 주가 조회: Yahoo Finance — 종목 코드 기반 시세 조회\n'
              '   - 푸시 알림: Google Firebase(FCM) — 디바이스 토큰 저장·알림 발송\n\n'
              '   위탁받은 업체는 해당 목적 범위 내에서만 정보를 처리하며, 법령이 정한 보안·관리 조치를 하도록 요구합니다.',
            ),

            _buildSectionTitle('제4조 (개인정보의 보유 및 이용 기간)'),
            _buildSectionContent(
              '- 회원 탈퇴 시: 탈퇴 처리와 동시에 수집된 개인정보(회원정보, 포트폴리오, 채팅, 알림, 푸시 토큰 등)를 삭제합니다. 단, 법령에서 보존 의무가 있는 경우 해당 기간 동안 보관 후 파기합니다.\n'
              '- 로그인 세션: JWT 토큰 유효기간(예: 7일) 동안 인증에 이용되며, 서버에 별도 저장하지 않을 수 있습니다.\n'
              '- 법령에 따른 보존: 예) 전자상거래 등에서의 소비자 보호에 관한 법률, 통신비밀보호법 등에 따라 필요한 경우 해당 기간 보존 후 파기합니다.',
            ),

            _buildSectionTitle('제5조 (이용자의 권리)'),
            _buildSectionContent(
              '- 회원 탈퇴(계정 삭제)를 요청하시면 제4조에 따라 관련 개인정보를 삭제합니다. (DELETE /auth/withdraw 등 서비스에서 안내하는 방법)\n'
              '- 개인정보 열람·정정·삭제·처리정지 요청은 서비스 문의 채널 또는 개인정보보호 담당자에게 요청하실 수 있으며, 법령에 따라 처리합니다.',
            ),

            _buildSectionTitle('제6조 (개인정보의 안전성 확보)'),
            _buildSectionContent(
              '- 개인정보는 암호화·접근 제한·백업 등 기술·관리적 조치를 통해 안전하게 관리합니다.\n'
              '- 외부 위탁 업체에 대해서도 동일 수준의 보호를 요구합니다.',
            ),

            _buildSectionTitle('제7조 (처리방침의 변경)'),
            _buildSectionContent(
              '- 본 개인정보 처리방침은 법령·서비스 정책 변경에 따라 수정될 수 있으며, 변경 시 서비스 내 공지 또는 앱 업데이트 등으로 안내합니다.',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Text(
                '시행일: 2026년 2월 22일',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  height: 1.7,
                ),
              ),
            ),

            _buildSectionTitle('제8조 (문의)'),
            _buildSectionContent(
              '- 개인정보 처리 관련 문의: softtissue9697@gmail.com',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 섹션 제목 위젯
  /// 각 항목의 제목을 굵은 글씨로 표시
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  /// 섹션 내용 위젯
  /// 각 항목의 본문 내용을 표시
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade700,
        height: 1.7,
      ),
    );
  }
}
