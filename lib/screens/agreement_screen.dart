// 약관 동의 화면 파일
// 로그인 후 needAgreement가 true일 때 표시되며,
// 이용약관·개인정보처리방침 동의 후 POST /auth/agreements 호출하여 메인으로 이동

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/stock_api_service.dart';
import '../services/push_service.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';

/// 약관 동의 화면
/// 필수: 이용약관, 개인정보처리방침 체크 후 "동의하고 계속하기"로 POST /auth/agreements 호출
class AgreementScreen extends StatefulWidget {
  const AgreementScreen({super.key});

  @override
  State<AgreementScreen> createState() => _AgreementScreenState();
}

class _AgreementScreenState extends State<AgreementScreen> {
  bool _agreedTerms = false;
  bool _agreedPrivacy = false;
  bool _agreedMarketing = false;
  bool _isSubmitting = false;

  final _apiService = StockApiService();

  bool get _canSubmit => _agreedTerms && _agreedPrivacy && !_isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text(
          '약관 동의',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('서비스 이용을 위해 아래 약관에 동의해 주세요.'),
                  const SizedBox(height: 20),
                  _buildDocumentSection(
                    title: '이용약관',
                    preview: '본 약관은 서비스가 제공하는 주식 포트폴리오 관리, AI 분석 채팅, 알림 등 '
                        '모든 기능의 이용 조건 및 이용자와 서비스 운영자 간의 권리·의무를 정함을 목적으로 합니다.',
                    onViewFull: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServiceScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection(
                    title: '개인정보 처리방침',
                    preview: '서비스는 이용자의 개인정보를 중요시하며, 「개인정보 보호법」 등 관련 법령을 준수합니다. '
                        '수집·이용·보관·파기하는 개인정보에 관한 사항을 담습니다.',
                    onViewFull: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildCheckbox(
                    value: _agreedTerms,
                    onChanged: (v) => setState(() => _agreedTerms = v ?? false),
                    label: '이용약관에 동의합니다 (필수)',
                  ),
                  const SizedBox(height: 12),
                  _buildCheckbox(
                    value: _agreedPrivacy,
                    onChanged: (v) => setState(() => _agreedPrivacy = v ?? false),
                    label: '개인정보 처리방침에 동의합니다 (필수)',
                  ),
                  const SizedBox(height: 12),
                  _buildCheckbox(
                    value: _agreedMarketing,
                    onChanged: (v) => setState(() => _agreedMarketing = v ?? false),
                    label: '마케팅 수신 동의 (선택)',
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildDocumentSection({
    required String title,
    required String preview,
    required VoidCallback onViewFull,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: onViewFull,
                child: const Text('전체 보기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            preview,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.45,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_agreedTerms || !_agreedPrivacy)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '필수 항목(이용약관, 개인정보 처리방침)에 모두 동의해 주세요.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _canSubmit ? _onSubmit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '동의하고 계속하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _apiService.sendAgreements(
        agreedTerms: _agreedTerms,
        agreedPrivacy: _agreedPrivacy,
        agreedMarketing: _agreedMarketing,
      );

      if (!mounted) return;

      if (result == null) {
        _showError('약관 동의 처리에 실패했습니다. 네트워크를 확인한 뒤 다시 시도해 주세요.');
        setState(() => _isSubmitting = false);
        return;
      }

      final needAgreement = result['needAgreement'] as bool? ?? true;

      if (needAgreement) {
        _showError('동의가 완료되지 않았습니다. 다시 시도해 주세요.');
      } else {
        await PushService.registerTokenWithBackend();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/main');
        return;
      }
    } catch (e) {
      if (mounted) {
        _showError('오류가 발생했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
