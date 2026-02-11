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
            // 최종 업데이트 날짜
            Text(
              '최종 업데이트: 2024년 1월 1일',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // 제1조 (목적)
            _buildSectionTitle('제1조 (목적)'),
            _buildSectionContent(
              '본 약관은 Stock Analysis AI(이하 "회사")가 제공하는 주식 분석 서비스(이하 "서비스")의 '
              '이용과 관련하여 회사와 이용자의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.',
            ),

            // 제2조 (정의)
            _buildSectionTitle('제2조 (정의)'),
            _buildSectionContent(
              '① "서비스"란 회사가 제공하는 AI 기반 주식 분석 및 투자 정보 제공 서비스를 의미합니다.\n'
              '② "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.\n'
              '③ "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며, 회사가 제공하는 서비스를 계속적으로 이용할 수 있는 자를 말합니다.',
            ),

            // 제3조 (약관의 게시와 개정)
            _buildSectionTitle('제3조 (약관의 게시와 개정)'),
            _buildSectionContent(
              '① 회사는 본 약관의 내용을 이용자가 쉽게 알 수 있도록 서비스 초기 화면 및 설정 메뉴에 게시합니다.\n'
              '② 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 본 약관을 개정할 수 있습니다.\n'
              '③ 회사가 약관을 개정할 경우에는 적용일자 및 개정사유를 명시하여 현행약관과 함께 서비스 초기화면에 그 적용일자 7일 이전부터 적용일자 전일까지 공지합니다.',
            ),

            // 제4조 (서비스의 제공 및 변경)
            _buildSectionTitle('제4조 (서비스의 제공 및 변경)'),
            _buildSectionContent(
              '① 회사는 다음과 같은 서비스를 제공합니다.\n'
              '   • AI 기반 주식 분석 정보\n'
              '   • 포트폴리오 관리 및 분석\n'
              '   • 주가 알림 서비스\n'
              '   • 투자 관련 뉴스 및 정보 제공\n\n'
              '② 회사는 필요한 경우 서비스의 내용을 변경할 수 있으며, 이 경우 변경된 서비스의 내용 및 제공일자를 명시하여 서비스를 통해 공지합니다.',
            ),

            // 제5조 (서비스 이용시간)
            _buildSectionTitle('제5조 (서비스 이용시간)'),
            _buildSectionContent(
              '① 서비스의 이용은 회사의 업무상 또는 기술상 특별한 지장이 없는 한 연중무휴, 1일 24시간을 원칙으로 합니다.\n'
              '② 회사는 서비스를 일정범위로 분할하여 각 범위별로 이용가능시간을 별도로 정할 수 있으며 이 경우 그 내용을 사전에 공지합니다.',
            ),

            // 제6조 (회원가입)
            _buildSectionTitle('제6조 (회원가입)'),
            _buildSectionContent(
              '① 이용자는 회사가 정한 가입 양식에 따라 회원정보를 기입한 후 본 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.\n'
              '② 회사는 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다.\n'
              '   • 등록 내용에 허위, 기재누락, 오기가 있는 경우\n'
              '   • 기타 회원으로 등록하는 것이 회사의 기술상 현저히 지장이 있다고 판단되는 경우',
            ),

            // 제7조 (회원 탈퇴 및 자격 상실)
            _buildSectionTitle('제7조 (회원 탈퇴 및 자격 상실)'),
            _buildSectionContent(
              '① 회원은 회사에 언제든지 탈퇴를 요청할 수 있으며 회사는 즉시 회원탈퇴를 처리합니다.\n'
              '② 회원이 다음 각 호의 사유에 해당하는 경우, 회사는 회원자격을 제한 및 정지시킬 수 있습니다.\n'
              '   • 가입 신청 시에 허위 내용을 등록한 경우\n'
              '   • 다른 사람의 서비스 이용을 방해하거나 그 정보를 도용하는 등 전자상거래 질서를 위협하는 경우\n'
              '   • 서비스를 이용하여 법령 또는 본 약관이 금지하거나 공서양속에 반하는 행위를 하는 경우',
            ),

            // 제8조 (이용자의 의무)
            _buildSectionTitle('제8조 (이용자의 의무)'),
            _buildSectionContent(
              '① 이용자는 다음 행위를 하여서는 안 됩니다.\n'
              '   • 신청 또는 변경 시 허위내용의 등록\n'
              '   • 타인의 정보 도용\n'
              '   • 회사가 게시한 정보의 변경\n'
              '   • 회사가 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시\n'
              '   • 회사 기타 제3자의 저작권 등 지적재산권에 대한 침해\n'
              '   • 회사 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위\n'
              '   • 외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 서비스에 공개 또는 게시하는 행위',
            ),

            // 제9조 (서비스 정보의 제공)
            _buildSectionTitle('제9조 (서비스 정보의 제공)'),
            _buildSectionContent(
              '① 회사가 제공하는 모든 투자 정보 및 분석 자료는 참고 자료일 뿐이며, 투자의 최종 판단 및 책임은 이용자 본인에게 있습니다.\n'
              '② 회사는 제공하는 정보의 정확성이나 신뢰성에 대해 보증하지 않으며, 서비스 이용으로 인한 투자 손실에 대해 책임지지 않습니다.\n'
              '③ 이용자는 서비스를 통해 얻은 정보를 본인의 투자 판단에만 활용해야 하며, 제3자에게 재배포하거나 상업적으로 이용할 수 없습니다.',
            ),

            // 제10조 (면책조항)
            _buildSectionTitle('제10조 (면책조항)'),
            _buildSectionContent(
              '① 회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.\n'
              '② 회사는 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여 책임을 지지 않습니다.\n'
              '③ 회사는 이용자가 서비스를 이용하여 기대하는 수익을 상실한 것에 대하여 책임을 지지 않으며, 서비스를 통하여 얻은 자료로 인한 손해에 관하여 책임을 지지 않습니다.',
            ),

            // 제11조 (분쟁의 해결)
            _buildSectionTitle('제11조 (분쟁의 해결)'),
            _buildSectionContent(
              '① 회사는 이용자가 제기하는 정당한 의견이나 불만을 반영하고 그 피해를 보상처리하기 위하여 피해보상처리기구를 설치·운영합니다.\n'
              '② 회사는 이용자로부터 제출되는 불만사항 및 의견은 우선적으로 그 사항을 처리합니다. 다만, 신속한 처리가 곤란한 경우에는 이용자에게 그 사유와 처리일정을 즉시 통보해 드립니다.\n'
              '③ 회사와 이용자 간에 발생한 분쟁은 전자거래기본법 제28조 및 동 시행령 제15조에 의하여 설치된 전자거래분쟁조정위원회의 조정에 따를 수 있습니다.',
            ),

            // 부칙
            _buildSectionTitle('부칙'),
            _buildSectionContent(
              '본 약관은 2024년 1월 1일부터 적용됩니다.',
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
