import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StockChart extends StatelessWidget {
  final List<double> priceHistory;
  final bool isPositive;
  final double height;
  final bool showAxis;

  const StockChart({
    super.key,
    required this.priceHistory,
    required this.isPositive,
    this.height = 200,
    this.showAxis = true,
  });

  @override
  Widget build(BuildContext context) {
    final spots = priceHistory
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final minY = priceHistory.reduce(min);
    final maxY = priceHistory.reduce(max);
    final padding = (maxY - minY) * 0.1;

    final gradientColors = isPositive
        ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
        : [const Color(0xFFC62828), const Color(0xFFEF5350)];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showAxis,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: showAxis,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showAxis,
                reservedSize: 30,
                interval: 7,
                getTitlesWidget: (value, meta) {
                  final day = value.toInt();
                  if (day % 7 == 0 && day < priceHistory.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${day + 1}일',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: showAxis,
                reservedSize: 55,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value >= 1000
                        ? '${(value / 1000).toStringAsFixed(0)}K'
                        : value.toStringAsFixed(0),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (priceHistory.length - 1).toDouble(),
          minY: minY - padding,
          maxY: maxY + padding,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              gradient: LinearGradient(colors: gradientColors),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((c) => c.withValues(alpha: 0.15))
                      .toList(),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.blueGrey.shade800,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    spot.y >= 1000 ? spot.y.toStringAsFixed(0) : spot.y.toStringAsFixed(2),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MiniStockChart extends StatelessWidget {
  final List<double> priceHistory;
  final bool isPositive;

  const MiniStockChart({
    super.key,
    required this.priceHistory,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return StockChart(
      priceHistory: priceHistory,
      isPositive: isPositive,
      height: 50,
      showAxis: false,
    );
  }
}
