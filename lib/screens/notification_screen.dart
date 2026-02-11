// 알림 화면 파일
// 사용자에게 전송된 알림 목록을 표시하는 화면

import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// 알림 데이터 모델 클래스
/// 알림의 제목, 내용, 시간, 읽음 여부, 타입 정보를 저장
class NotificationItem {
  final String title; // 알림 제목
  final String message; // 알림 내용
  final String time; // 알림 시간 (예: "2시간 전", "어제")
  final bool isRead; // 읽음 여부
  final NotificationType type; // 알림 타입 (주가, 뉴스, 시스템)

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

/// 알림 타입 열거형
/// 주가 알림, 뉴스 알림, 시스템 알림 세 가지 타입
enum NotificationType {
  stock, // 주가 관련 알림
  news, // 뉴스 관련 알림
  system, // 시스템 알림
}

/// 알림 화면 위젯 (StatelessWidget)
/// 상단 앱바 + 알림 목록으로 구성
class NotificationScreen extends StatelessWidget {
  final bool showBackButton; // 뒤로가기 버튼 표시 여부

  const NotificationScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // 상단 앱바
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: AppColors.cardBackground,
        elevation: 0,
        // showBackButton이 false면 leading을 null로 설정하여 뒤로가기 버튼 숨김
        leading: showBackButton
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
        // 전체 읽음 처리 버튼
        actions: [
          TextButton(
            onPressed: () {
              // TODO: 전체 알림 읽음 처리 로직
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
      // 알림 목록
      body: _buildNotificationList(),
    );
  }

  /// 알림 목록 위젯
  /// ListView.builder를 사용하여 알림 아이템들을 표시
  Widget _buildNotificationList() {
    // 모의 알림 데이터
    final notifications = _getMockNotifications();

    // 알림이 없는 경우
    if (notifications.isEmpty) {
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

    // 알림 목록 표시
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationCard(notification: notification);
      },
    );
  }

  /// 모의 알림 데이터 생성
  /// 실제 앱에서는 API나 로컬 저장소에서 가져와야 함
  List<NotificationItem> _getMockNotifications() {
    return [
      const NotificationItem(
        title: '삼성전자 주가 상승',
        message: '삼성전자가 전일 대비 3.2% 상승했습니다.',
        time: '10분 전',
        isRead: false,
        type: NotificationType.stock,
      ),
      const NotificationItem(
        title: 'AI 분석 완료',
        message: '보유 종목에 대한 AI 분석이 완료되었습니다.',
        time: '1시간 전',
        isRead: false,
        type: NotificationType.system,
      ),
      const NotificationItem(
        title: '테슬라 실적 발표',
        message: '테슬라가 분기 실적을 발표했습니다. 예상치를 상회했습니다.',
        time: '3시간 전',
        isRead: true,
        type: NotificationType.news,
      ),
      const NotificationItem(
        title: 'NAVER 목표가 상향',
        message: '증권사에서 NAVER 목표가를 280,000원으로 상향 조정했습니다.',
        time: '어제',
        isRead: true,
        type: NotificationType.stock,
      ),
      const NotificationItem(
        title: '시장 동향 업데이트',
        message: 'KOSPI 지수가 2,500선을 돌파했습니다.',
        time: '2일 전',
        isRead: true,
        type: NotificationType.news,
      ),
    ];
  }
}

/// 개별 알림 카드 위젯
/// 알림 정보를 카드 형태로 표시
class _NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        // 읽은 알림은 흰색, 읽지 않은 알림은 연한 파란색 배경
        color: notification.isRead
            ? AppColors.cardBackground
            : AppColors.notificationUnreadBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // 읽은 알림은 회색, 읽지 않은 알림은 파란색 테두리
          color: notification.isRead
              ? AppColors.border
              : AppColors.primaryOverlay20,
        ),
      ),
      child: InkWell(
        onTap: () {
          // TODO: 알림 클릭 시 상세 화면 이동 또는 읽음 처리
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 알림 타입 아이콘
              _buildIcon(),
              const SizedBox(width: 12),
              // 알림 내용 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목 + 읽지 않음 표시
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // 읽지 않은 알림 표시 점
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // 알림 메시지
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 시간 정보
                    Text(
                      notification.time,
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

  /// 알림 타입에 따른 아이콘 위젯
  /// stock: 차트 아이콘, news: 뉴스 아이콘, system: 시스템 아이콘
  Widget _buildIcon() {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.stock:
        // 주가 알림: 차트 아이콘, 파란색 계열
        iconData = Icons.trending_up;
        backgroundColor = AppColors.notificationStockBackground;
        iconColor = AppColors.notificationStock;
        break;
      case NotificationType.news:
        // 뉴스 알림: 뉴스페이퍼 아이콘, 주황색 계열
        iconData = Icons.article_outlined;
        backgroundColor = AppColors.notificationNewsBackground;
        iconColor = AppColors.notificationNews;
        break;
      case NotificationType.system:
        // 시스템 알림: 정보 아이콘, 보라색 계열
        iconData = Icons.info_outline;
        backgroundColor = AppColors.notificationSystemBackground;
        iconColor = AppColors.notificationSystem;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 22,
      ),
    );
  }
}
