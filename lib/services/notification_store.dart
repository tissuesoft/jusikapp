// 푸시 알림 목록 저장소
// FCM으로 수신한 알림을 로컬에 저장하고, 읽음/미읽음 구분 및 메인 배지 개수 제공

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 한 건 모델 (푸시로 수신한 항목)
class StoredNotification {
  final String id;
  final String title;
  final String body;
  final int? portfolioId; // 있으면 해당 종목 채팅으로 이동
  final DateTime createdAt;
  final bool isRead;

  const StoredNotification({
    required this.id,
    required this.title,
    required this.body,
    this.portfolioId,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'portfolioId': portfolioId,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
      };

  static StoredNotification fromJson(Map<String, dynamic> json) {
    return StoredNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      portfolioId: (json['portfolioId'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }

  StoredNotification copyWith({bool? isRead}) {
    return StoredNotification(
      id: id,
      title: title,
      body: body,
      portfolioId: portfolioId,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 푸시 알림 목록을 저장·조회·읽음 처리하며, 미읽음 개수 변경 시 알림
class NotificationStore extends ChangeNotifier {
  static const String _key = 'push_notifications';
  static final NotificationStore _instance = NotificationStore._();
  static NotificationStore get instance => _instance;

  NotificationStore._() {
    _load();
  }

  List<StoredNotification> _list = [];

  List<StoredNotification> get list => List.unmodifiable(_list);

  /// 최신순 정렬된 목록 (미읽음 먼저, 그 다음 시간 내림차순)
  List<StoredNotification> get sortedList {
    final l = List<StoredNotification>.from(_list);
    l.sort((a, b) {
      if (a.isRead != b.isRead) return a.isRead ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return l;
  }

  /// 미읽음 개수 (메인 알림 아이콘 배지용)
  int get unreadCount => _list.where((n) => !n.isRead).length;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = json.decode(raw) as List<dynamic>;
      _list = list
          .map((e) => StoredNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(_list.map((e) => e.toJson()).toList());
      await prefs.setString(_key, encoded);
    } catch (_) {}
    notifyListeners();
  }

  /// 푸시 수신 시 알림 목록에 추가 (PushService에서 호출)
  Future<void> add({
    required String title,
    required String body,
    int? portfolioId,
  }) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${title.hashCode}';
    _list.insert(
      0,
      StoredNotification(
        id: id,
        title: title,
        body: body,
        portfolioId: portfolioId,
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
    // 최대 개수 제한 (예: 200개)
    if (_list.length > 200) {
      _list = _list.take(200).toList();
    }
    await _save();
  }

  /// id에 해당하는 알림을 읽음 처리
  Future<void> markAsRead(String id) async {
    final i = _list.indexWhere((n) => n.id == id);
    if (i < 0) return;
    _list[i] = _list[i].copyWith(isRead: true);
    await _save();
  }

  /// 전체 읽음 처리
  Future<void> markAllAsRead() async {
    bool changed = false;
    for (var i = 0; i < _list.length; i++) {
      if (!_list[i].isRead) {
        _list[i] = _list[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) await _save();
  }
}
