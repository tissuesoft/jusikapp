// 설정 화면 파일
// 알림, 앱 정보, 약관 및 정책, 지원 메뉴와 로그아웃 버튼을 표시한다
// 홈 화면 설정 아이콘 탭 또는 하단 네비게이션 '설정' 탭에서 진입한다

import 'package:flutter/material.dart';

/// 설정 화면 위젯
/// 섹션별 메뉴 항목, 로그아웃 버튼, 앱 버전 정보 푸터로 구성
class SettingsScreen extends StatelessWidget {
  // 앱바에 뒤로가기 버튼을 표시할지 여부 (네비게이션 탭에서는 false)
  final bool showBackButton;

  const SettingsScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 앱바: 뒤로가기(선택) + 중앙 "설정" 타이틀
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        title: const Text(
          '설정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade200,
            height: 1,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── 알림 섹션 ──
          _buildSectionHeader('알림'),
          _buildSettingsTile(
            icon: Icons.notifications,
            iconColor: const Color(0xFF1565C0),
            title: '알림 설정',
            subtitle: '가격 알림, 뉴스 알림',
            onTap: () {},
          ),
          _buildSectionDivider(),

          // ── 앱 정보 섹션 ──
          _buildSectionHeader('앱 정보'),
          _buildSettingsTile(
            icon: Icons.phone_android,
            iconColor: const Color(0xFF1565C0),
            title: '앱 버전 정보',
            trailing: 'v2.1.4',
            onTap: () {},
          ),
          _buildItemDivider(),
          _buildSettingsTile(
            icon: Icons.mail,
            iconColor: const Color(0xFF1565C0),
            title: '개발자 이메일',
            onTap: () {},
          ),
          _buildSectionDivider(),

          // ── 약관 및 정책 섹션 ──
          _buildSectionHeader('약관 및 정책'),
          _buildSettingsTile(
            icon: Icons.security,
            iconColor: const Color(0xFFE53935),
            title: '개인정보 처리방침',
            onTap: () {},
          ),
          _buildItemDivider(),
          _buildSettingsTile(
            icon: Icons.description,
            iconColor: const Color(0xFFE53935),
            title: '이용약관',
            onTap: () {},
          ),
          _buildSectionDivider(),

          // ── 지원 섹션 ──
          _buildSectionHeader('지원'),
          _buildSettingsTile(
            icon: Icons.help,
            iconColor: const Color(0xFF00897B),
            title: '도움말',
            onTap: () {},
          ),
          _buildItemDivider(),
          _buildSettingsTile(
            icon: Icons.chat_bubble,
            iconColor: const Color(0xFF00897B),
            title: '피드백 보내기',
            onTap: () {},
          ),

          const SizedBox(height: 32),

          // ── 로그아웃 버튼 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── 앱 버전 및 저작권 푸터 ──
          Center(
            child: Column(
              children: [
                Text(
                  'Stock Analysis AI v2.1.4',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 All rights reserved',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 섹션 헤더 (회색 라벨 텍스트)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  /// 설정 항목 타일 위젯
  /// [icon]: 좌측 아이콘, [iconColor]: 아이콘 배경색
  /// [title]: 항목명, [subtitle]: 부가 설명 (선택)
  /// [trailing]: 우측 추가 텍스트 (선택, 예: "v2.1.4")
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            // 색상 원형 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            // 타이틀 + 서브타이틀
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 우측 추가 텍스트 (버전 정보 등)
            if (trailing != null) ...[
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 4),
            ],
            // 우측 화살표 아이콘
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 간 구분선 (굵은 회색 배경)
  Widget _buildSectionDivider() {
    return Divider(height: 1, color: Colors.grey.shade100);
  }

  /// 같은 섹션 내 항목 간 구분선 (얇은 회색, 아이콘 영역 제외)
  Widget _buildItemDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 74),
      child: Divider(height: 1, color: Colors.grey.shade100),
    );
  }
}
