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
            // 최종 업데이트 날짜
            Text(
              '최종 업데이트: 2024년 1월 1일',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // 1. 개인정보의 처리 목적
            _buildSectionTitle('1. 개인정보의 처리 목적'),
            _buildSectionContent(
              'Stock Analysis AI(이하 "회사")는 다음의 목적을 위하여 개인정보를 처리합니다. '
              '처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, '
              '이용 목적이 변경되는 경우에는 개인정보 보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.\n\n'
              '• 회원 가입 및 관리: 회원 가입의사 확인, 회원제 서비스 제공에 따른 본인 식별·인증\n'
              '• 서비스 제공: 맞춤형 주식 분석 서비스, AI 기반 투자 추천 서비스 제공\n'
              '• 고객 지원: 고객 문의 응대, 불만 처리 등 고객 지원 서비스 제공',
            ),

            // 2. 개인정보의 처리 및 보유 기간
            _buildSectionTitle('2. 개인정보의 처리 및 보유 기간'),
            _buildSectionContent(
              '회사는 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 '
              '동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.\n\n'
              '• 회원 가입 및 관리: 회원 탈퇴 시까지\n'
              '• 서비스 제공: 서비스 이용 종료 시까지\n'
              '• 고객 지원: 문의 처리 완료 후 1년',
            ),

            // 3. 처리하는 개인정보의 항목
            _buildSectionTitle('3. 처리하는 개인정보의 항목'),
            _buildSectionContent(
              '회사는 다음의 개인정보 항목을 처리하고 있습니다.\n\n'
              '• 필수 항목: 이름, 이메일 주소, 카카오톡 계정 정보\n'
              '• 선택 항목: 프로필 사진, 투자 성향 정보\n'
              '• 자동 수집 항목: 접속 IP 정보, 쿠키, 서비스 이용 기록',
            ),

            // 4. 개인정보의 제3자 제공
            _buildSectionTitle('4. 개인정보의 제3자 제공'),
            _buildSectionContent(
              '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. '
              '다만, 아래의 경우에는 예외로 합니다.\n\n'
              '• 이용자가 사전에 동의한 경우\n'
              '• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
            ),

            // 5. 개인정보의 파기
            _buildSectionTitle('5. 개인정보의 파기'),
            _buildSectionContent(
              '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 '
              '지체없이 해당 개인정보를 파기합니다.\n\n'
              '• 파기 절차: 이용자의 개인정보는 목적 달성 후 별도의 DB로 옮겨져 내부 방침 및 기타 관련 법령에 따라 일정 기간 저장된 후 파기됩니다.\n'
              '• 파기 방법: 전자적 파일 형태의 정보는 기록을 재생할 수 없는 기술적 방법을 사용합니다.',
            ),

            // 6. 정보주체의 권리·의무 및 행사방법
            _buildSectionTitle('6. 정보주체의 권리·의무 및 행사방법'),
            _buildSectionContent(
              '정보주체는 회사에 대해 언제든지 다음 각 호의 개인정보 보호 관련 권리를 행사할 수 있습니다.\n\n'
              '• 개인정보 열람 요구\n'
              '• 오류 등이 있을 경우 정정 요구\n'
              '• 삭제 요구\n'
              '• 처리정지 요구\n\n'
              '권리 행사는 회사에 대해 서면, 전자우편 등을 통하여 하실 수 있으며, '
              '회사는 이에 대해 지체없이 조치하겠습니다.',
            ),

            // 7. 개인정보 보호책임자
            _buildSectionTitle('7. 개인정보 보호책임자'),
            _buildSectionContent(
              '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, '
              '개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제를 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.\n\n'
              '• 이메일: softtissue9697@gmail.com\n\n'
              '정보주체는 회사의 서비스를 이용하시면서 발생한 모든 개인정보 보호 관련 문의, 불만처리, 피해구제 등에 관한 사항을 개인정보 보호책임자에게 문의하실 수 있습니다.',
            ),

            // 8. 개인정보 처리방침 변경
            _buildSectionTitle('8. 개인정보 처리방침 변경'),
            _buildSectionContent(
              '이 개인정보 처리방침은 2024년 1월 1일부터 적용되며, '
              '법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 '
              '변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.',
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
