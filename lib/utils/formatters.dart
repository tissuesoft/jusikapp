import 'package:intl/intl.dart';

String formatPrice(double price, String currency) {
  if (currency == '₩') {
    return '₩${NumberFormat('#,###').format(price.toInt())}';
  }
  return '\$${NumberFormat('#,##0.00').format(price)}';
}

String formatChange(double change, String currency) {
  final sign = change >= 0 ? '+' : '';
  if (currency == '₩') {
    return '$sign${NumberFormat('#,###').format(change.toInt())}';
  }
  return '$sign${NumberFormat('#,##0.00').format(change)}';
}

String formatPercent(double percent) {
  final sign = percent >= 0 ? '+' : '';
  return '$sign${percent.toStringAsFixed(2)}%';
}

String formatVolume(double volume) {
  if (volume >= 1000000) {
    return '${(volume / 1000000).toStringAsFixed(1)}M';
  }
  if (volume >= 1000) {
    return '${(volume / 1000).toStringAsFixed(1)}K';
  }
  return volume.toStringAsFixed(0);
}

String formatMarketCap(double cap, String currency) {
  if (currency == '₩') {
    return '${cap.toStringAsFixed(1)}조원';
  }
  return '\$${cap.toStringAsFixed(0)}B';
}

String formatPER(double per) {
  return per.toStringAsFixed(1);
}
