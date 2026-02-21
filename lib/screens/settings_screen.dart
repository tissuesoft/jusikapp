// 설정 화면 파일
// 알림, 앱 정보, 약관 및 정책, 지원 메뉴와 로그아웃 버튼을 표시한다
// 홈 화면 설정 아이콘 탭 또는 하단 네비게이션 '설정' 탭에서 진입한다

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/notification_preferences.dart';
import '../services/stock_api_service.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

/// 설정 화면 위젯
/// 섹션별 메뉴 항목, 로그아웃 버튼, 앱 버전 정보 푸터로 구성
class SettingsScreen extends StatefulWidget {
  // 앱바에 뒤로가기 버튼을 표시할지 여부 (네비게이션 탭에서는 false)
  final bool showBackButton;

  const SettingsScreen({super.key, this.showBackButton = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// 설정 화면의 상태를 담는 클래스
/// 알림 on/off 등 변경 가능한 설정값을 보관
class _SettingsScreenState extends State<SettingsScreen> {
  // 알림 설정 토글 값 (true: 켜짐, false: 꺼짐) — 저장된 값으로 초기화
  bool _notificationEnabled = true;
  // 앱 버전 (package_info_plus로 로드, 예: 1.0.0+1 → "1.0.0 (1)")
  String _appVersion = '—';

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    _loadAppVersion();
  }

  /// package_info_plus로 실제 앱 버전·빌드 번호 로드
  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _appVersion = '${info.version}+${info.buildNumber}');
      }
    } catch (_) {}
  }

  /// 저장된 알림 수신 허용 여부를 불러와 상태에 반영
  Future<void> _loadNotificationPreference() async {
    final enabled = await NotificationPreferences.isEnabled();
    if (mounted) {
      setState(() => _notificationEnabled = enabled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 상단 앱바: 뒤로가기 버튼 + 중앙 "설정" 타이틀
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: Container(color: Colors.grey.shade200, height: 1),
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
            switchValue: _notificationEnabled,
            onSwitchChanged: (value) async {
              await NotificationPreferences.setEnabled(value);
              if (mounted) setState(() => _notificationEnabled = value);
            },
          ),
          _buildSectionDivider(),

          // ── 앱 정보 섹션 ──
          _buildSectionHeader('앱 정보'),
          _buildSettingsTile(
            icon: Icons.phone_android,
            iconColor: const Color(0xFF1565C0),
            title: '앱 버전 정보',
            trailing: _appVersion,
            showChevron: false,
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.mail,
            iconColor: const Color(0xFF1565C0),
            title: '개발자 이메일 : softtissue9697@gmail.com',
            titleFontSize: 12,
            titleMaxLines: 1,
            showChevron: false,
            onTap: () => _sendEmail(),
          ),
          _buildSectionDivider(),

          // ── 약관 및 정책 섹션 ──
          _buildSectionHeader('약관 및 정책'),
          _buildSettingsTile(
            icon: Icons.security,
            iconColor: const Color(0xFFE53935),
            title: '개인정보 처리방침',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyScreen(),
              ),
            ),
          ),
          _buildItemDivider(),
          _buildSettingsTile(
            icon: Icons.description,
            iconColor: const Color(0xFFE53935),
            title: '이용약관',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TermsOfServiceScreen(),
              ),
            ),
          ),
          _buildSectionDivider(),

          // ── 지원 섹션 ──
          const SizedBox(height: 32),

          // ── 로그아웃 버튼 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () async {
                await AuthService.instance.clearToken();
                if (!context.mounted) return;
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
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

          const SizedBox(height: 12),

          // ── 회원탈퇴 버튼 ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton(
              onPressed: () => _showWithdrawConfirm(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                '회원탈퇴',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
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
                  'Stock Analysis AI $_appVersion',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 All rights reserved',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 회원탈퇴 확인 다이얼로그 표시 후 동의 시 DELETE /auth/withdraw 호출, 성공 시 토큰 삭제 후 로그인 화면으로 이동
  Future<void> _showWithdrawConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text(
          '탈퇴 시 계정 및 관련 데이터가 삭제되며 복구할 수 없습니다.\n정말 탈퇴하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소', style: TextStyle(color: Colors.grey.shade700)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('탈퇴', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;

    final api = StockApiService();
    final success = await api.withdrawAccount();
    if (!context.mounted) return;
    if (success) {
      await AuthService.instance.clearToken();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('회원탈퇴가 완료되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('회원탈퇴에 실패했습니다. 잠시 후 다시 시도해 주세요.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
    }
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
  /// [trailing]: 우측 추가 텍스트 (선택, 예: "1.0.0+1")
  /// [showChevron]: false면 우측 화살표(>) 미표시 (앱 버전 정보 등)
  /// [titleFontSize]: 지정 시 타이틀 폰트 크기 (미지정 시 15)
  /// [titleMaxLines]: 지정 시 타이틀 한 줄 제한 (넘치면 말줄임)
  /// [switchValue], [onSwitchChanged]: 둘 다 주면 우측에 Switch 표시 (탭 이동 대신 토글용)
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    String? trailing,
    VoidCallback? onTap,
    bool showChevron = true,
    double? titleFontSize,
    int? titleMaxLines,
    bool? switchValue,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    final isSwitchTile = switchValue != null && onSwitchChanged != null;

    return InkWell(
      onTap: isSwitchTile
          ? () => onSwitchChanged(!switchValue)
          : (onTap ?? () {}),
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
                    maxLines: titleMaxLines,
                    overflow: titleMaxLines != null
                        ? TextOverflow.ellipsis
                        : null,
                    style: TextStyle(
                      fontSize: titleFontSize ?? 15,
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
            // 우측: Switch(알림 등) 또는 텍스트 + 화살표
            if (isSwitchTile) ...[
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: const Color(0xFF2563EB),
              ),
            ] else ...[
              if (trailing != null) ...[
                Text(
                  trailing,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                if (showChevron) const SizedBox(width: 4),
              ],
              if (showChevron)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade300,
                  size: 22,
                ),
            ],
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

  /// 개발자 이메일 작성
  /// url_launcher 패키지를 사용하여 기본 이메일 앱을 실행
  Future<void> _sendEmail() async {
    // mailto: URI 스킴 생성
    // scheme: 'mailto' - 이메일 프로토콜
    // path: 수신자 이메일 주소
    // queryParameters: 제목(subject), 본문(body) 등 추가 정보
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'softtissue9697@gmail.com',
      queryParameters: {
        'subject': '[Stock Analysis AI] 문의사항', // 이메일 제목
        'body': '문의 내용을 입력해주세요.', // 이메일 본문
      },
    );

    // URL을 열 수 있는지 확인 후 실행
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // 이메일 앱을 열 수 없는 경우
      // (이메일 클라이언트가 설치되지 않은 경우 등)
      debugPrint('이메일 앱을 열 수 없습니다: $emailUri');
    }
  }
}
