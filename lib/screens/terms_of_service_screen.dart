// 이용약관 화면 파일
// 앱의 서비스 이용약관을 표시하는 화면

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// 이용약관 화면 위젯 (StatelessWidget)
/// 스크롤 가능한 텍스트로 서비스 이용약관 내용 표시
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 상단 앱바 - 뒤로가기 버튼 + "이용약관" 타이틀
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '이용약관',
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
              '[ai 주식 종목 뉴스 분석] AI 주식 종목 뉴스 분석(이하 "서비스") 이용약관입니다. '
              '서비스를 이용하시면 본 약관에 동의한 것으로 간주됩니다.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('제1조 (목적)'),
            _buildSectionContent(
              '본 약관은 서비스가 제공하는 주식 포트폴리오 관리, AI 분석 채팅, 알림 등 모든 기능의 이용 조건 및 '
              '이용자와 서비스 운영자 간의 권리·의무를 정함을 목적으로 합니다.',
            ),

            _buildSectionTitle('제2조 (정의)'),
            _buildSectionContent(
              '- "서비스": 주식 종목 추가·관리, 현재가·전일대비 조회, AI 채팅 분석, 가격·공시·장마감 알림 등을 제공하는 애플리케이션 및 관련 API·백엔드 서비스를 말합니다.\n'
              '- "이용자": 카카오 계정으로 로그인하여 서비스를 이용하는 회원을 말합니다.\n'
              '- "콘텐츠": 이용자가 입력한 채팅, 보유 종목 정보, 알림 내역 등 서비스 내에서 생성·저장되는 모든 데이터를 말합니다.',
            ),

            _buildSectionTitle('제3조 (약관의 효력 및 변경)'),
            _buildSectionContent(
              '- 서비스 이용 시 본 약관에 동의한 것으로 봅니다.\n'
              '- 운영자는 법령 또는 서비스 정책에 따라 약관을 변경할 수 있으며, 변경 시 서비스 내 공지·앱 업데이트·이메일 등으로 안내합니다. 변경 후에도 이용을 계속하면 변경된 약관에 동의한 것으로 봅니다.',
            ),

            _buildSectionTitle('제4조 (서비스의 내용)'),
            _buildSectionContent(
              '서비스는 다음 기능을 포함할 수 있으며, 필요에 따라 추가·변경·중단될 수 있습니다.\n\n'
              '- 카카오 계정을 이용한 회원 가입·로그인\n'
              '- 보유 종목 추가·삭제 및 평균 매수가·보유 수량 입력\n'
              '- 홈 화면에서 보유 종목별 현재가·전일 대비·손익·수익률 조회\n'
              '- 종목별 AI 분석 채팅(질문·답변·대화 저장 및 요약)\n'
              '- 보유 종목의 가격 급등락(전일 대비 ±5% 등), 공시 발생, 장 마감(예: 오후 8시) 시 푸시 알림 및 앱 내 알림 목록 제공\n'
              '- 회원 탈퇴 시 수집·저장된 개인정보 및 이용 데이터 삭제\n\n'
              '서비스는 실시간 시세·뉴스·공시 등을 가공하여 제공하나, 정보의 정확성·완전성을 보장하지 않습니다. '
              'AI 분석 내용은 참고용이며, 투자 판단과 책임은 전적으로 이용자에게 있습니다.',
            ),

            _buildSectionTitle('제5조 (이용자의 의무)'),
            _buildSectionContent(
              '이용자는 다음 행위를 해서는 안 됩니다.\n\n'
              '- 타인의 카카오 계정·개인정보 도용\n'
              '- 서비스·서버·DB 등에 대한 무단 접근·변조·파괴\n'
              '- 법령 또는 공서양속에 위반되는 이용\n'
              '- 서비스 운영을 방해하거나 다른 이용자에게 불편을 주는 행위\n'
              '- AI 분석 결과를 무단으로 상업적·재배포 목적으로 이용하는 등 서비스 이용약관·정책을 위반하는 행위\n\n'
              '위 반 시 서비스 이용 제한·계정 삭제·법적 조치 등이 취해질 수 있습니다.',
            ),

            _buildSectionTitle('제6조 (서비스의 제공·중단)'),
            _buildSectionContent(
              '- 서비스는 업무상·기술상 필요에 따라 일부 또는 전부를 일시적으로 중단하거나 변경할 수 있습니다. 중대한 중단·변경 시에는 사전 또는 사후에 공지할 수 있습니다.\n'
              '- 천재지변, 통신 장애, 제3자 서비스 장애 등으로 인한 서비스 중단·지연에 대해 운영자는 책임을 지지 않을 수 있습니다. 다만, 운영자의 고의·과실이 인정되는 경우에는 법령이 정한 범위 내에서 책임을 집니다.',
            ),

            _buildSectionTitle('제7조 (저작권 및 콘텐츠)'),
            _buildSectionContent(
              '- 서비스가 제공하는 UI·로고·설계 등에 대한 저작권은 운영자에게 있습니다.\n'
              '- 이용자가 입력·생성한 채팅·보유 종목 정보 등은 서비스 이용·개선·AI 분석을 위해 수집·저장·처리될 수 있으며, 이에 대해서는 개인정보 처리방침을 따릅니다.\n'
              '- AI가 생성한 답변은 서비스의 이용 범위 내에서만 참고용으로 제공되며, 무단 전재·배포·상업적 이용을 금지합니다.',
            ),

            _buildSectionTitle('제8조 (면책)'),
            _buildSectionContent(
              '- 모든 투자 결정 및 그에 따른 손익은 전적으로 이용자 본인의 책임이며, 서비스 및 운영자는 투자 결과와 무관하며 어떠한 책임도 지지 않습니다.\n'
              '- 서비스에서 제공하는 주가·뉴스·공시·AI 분석 내용은 참고용이며, 투자 권유·충당이 아니며, 투자 손익에 대한 책임은 이용자 본인에게 있습니다.\n'
              '- 이용자가 서비스 이용 과정에서 입은 손해(투자 손실, 데이터 유실, 제3자와의 분쟁 등)에 대해 운영자는 법령에 따라 책임이 인정되는 경우를 제외하고는 책임을 지지 않습니다.\n'
              '- 카카오·OpenAI·네이버·DART·Yahoo·Firebase·Supabase 등 제3자 서비스의 장애·정책 변경으로 인한 서비스 이용 제한·중단에 대해 운영자는 제3자와의 계약 범위 내에서만 대응하며, 그 밖의 책임을 지지 않을 수 있습니다.',
            ),

            _buildSectionTitle('제9조 (회원 탈퇴)'),
            _buildSectionContent(
              '- 이용자는 언제든지 회원 탈퇴를 요청할 수 있으며, 서비스가 안내하는 방법(예: 앱 내 탈퇴 버튼·API 호출)으로 처리됩니다.\n'
              '- 탈퇴 시 수집·저장된 회원 정보, 포트폴리오, 채팅, 알림, 푸시 토큰 등은 삭제됩니다. 자세한 내용은 개인정보 처리방침을 참고하세요.',
            ),

            _buildSectionTitle('제10조 (준거법 및 관할)'),
            _buildSectionContent(
              '- 본 약관은 대한민국 법률에 따릅니다.\n'
              '- 서비스와 이용자 간 분쟁이 발생한 경우, 운영자 소재지 관할 법원을 관할로 합니다. 다만, 이용자가 소비자보호법상 소비자인 경우에는 그 거주지 관할 법원으로 할 수 있습니다.',
            ),

            _buildSectionTitle('제11조 (문의)'),
            _buildSectionContent(
              '- 이용약관·서비스 이용 관련 문의: softtissue9697@gmail.com',
            ),

            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
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
