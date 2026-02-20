// 알림 화면 파일
// FCM 푸시로 수신한 알림 목록을 표시하고, 확인/미확인 구분, 탭 시 해당 종목 채팅으로 이동

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/notification_store.dart';
import 'open_chat_from_push_screen.dart';

/// 알림 화면 위젯 (StatefulWidget)
/// NotificationStore의 푸시 알림 목록을 표시, 읽음/미읽음 구분, 탭 시 종목 채팅 이동
class NotificationScreen extends StatefulWidget {
  final bool showBackButton;

  const NotificationScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationStore _store = NotificationStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          '알림',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: [
          if (_store.unreadCount > 0)
            TextButton(
              onPressed: () async {
                await _store.markAllAsRead();
              },
              child: Text(
                '모두 읽음',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final list = _store.sortedList;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '알림이 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 확인 안 함 / 확인함 구분하여 표시
    final unread = list.where((n) => !n.isRead).toList();
    final read = list.where((n) => n.isRead).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (unread.isNotEmpty) ...[
          _sectionHeader('확인하지 않음', unread.length),
          ...unread.map((n) => _NotificationCard(
                notification: n,
                onTap: () => _onNotificationTap(n),
              )),
        ],
        if (read.isNotEmpty) ...[
          _sectionHeader('확인함', read.length),
          ...read.map((n) => _NotificationCard(
                notification: n,
                onTap: () => _onNotificationTap(n),
              )),
        ],
      ],
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        '$title ($count)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Future<void> _onNotificationTap(StoredNotification n) async {
    await _store.markAsRead(n.id);
    if (!mounted) return;
    if (n.portfolioId != null) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => OpenChatFromPushScreen(portfolioId: n.portfolioId!),
        ),
      );
    }
  }
}

/// 개별 알림 카드 (푸시 제목·내용·시간, 읽음 여부에 따른 스타일)
class _NotificationCard extends StatelessWidget {
  final StoredNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.cardBackground
            : AppColors.notificationUnreadBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? AppColors.border : AppColors.primaryOverlay20,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  isRead ? FontWeight.w600 : FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // portfolioId가 있으면 종목 관련(차트), 없으면 시스템(정보)
    final hasStock = notification.portfolioId != null;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: hasStock
            ? AppColors.notificationStockBackground
            : AppColors.notificationSystemBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        hasStock ? Icons.trending_up : Icons.info_outline,
        color: hasStock
            ? AppColors.notificationStock
            : AppColors.notificationSystem,
        size: 22,
      ),
    );
  }

  static String _formatTime(DateTime at) {
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 2) return '어제';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${at.month}월 ${at.day}일';
  }
}
