import 'package:flutter/material.dart';
import '../models/stock.dart';

class RecommendationBadge extends StatelessWidget {
  final Recommendation recommendation;
  final bool compact;

  const RecommendationBadge({
    super.key,
    required this.recommendation,
    this.compact = false,
  });

  Color get _backgroundColor {
    switch (recommendation) {
      case Recommendation.strongBuy:
        return const Color(0xFFE8F5E9);
      case Recommendation.buy:
        return const Color(0xFFF1F8E9);
      case Recommendation.hold:
        return const Color(0xFFFFF8E1);
      case Recommendation.sell:
        return const Color(0xFFFBE9E7);
      case Recommendation.strongSell:
        return const Color(0xFFFFEBEE);
    }
  }

  Color get _textColor {
    switch (recommendation) {
      case Recommendation.strongBuy:
        return const Color(0xFF2E7D32);
      case Recommendation.buy:
        return const Color(0xFF558B2F);
      case Recommendation.hold:
        return const Color(0xFFF9A825);
      case Recommendation.sell:
        return const Color(0xFFE64A19);
      case Recommendation.strongSell:
        return const Color(0xFFC62828);
    }
  }

  String get _label {
    switch (recommendation) {
      case Recommendation.strongBuy:
        return '강력 매수';
      case Recommendation.buy:
        return '매수';
      case Recommendation.hold:
        return '관망';
      case Recommendation.sell:
        return '매도';
      case Recommendation.strongSell:
        return '강력 매도';
    }
  }

  IconData get _icon {
    switch (recommendation) {
      case Recommendation.strongBuy:
        return Icons.keyboard_double_arrow_up;
      case Recommendation.buy:
        return Icons.arrow_upward;
      case Recommendation.hold:
        return Icons.remove;
      case Recommendation.sell:
        return Icons.arrow_downward;
      case Recommendation.strongSell:
        return Icons.keyboard_double_arrow_down;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: compact ? 14 : 16, color: _textColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
