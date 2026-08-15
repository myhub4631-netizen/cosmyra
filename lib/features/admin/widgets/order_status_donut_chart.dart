import 'dart:math';
import 'package:flutter/material.dart';

class OrderStatusDonutChart extends StatelessWidget {
  const OrderStatusDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          width: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(180, 180),
                painter: _DonutChartPainter(),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '12,543',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Legend Metrics List
        _buildLegendRow('Delivered', '7,154 (57%)', const Color(0xFF3B82F6)),
        const SizedBox(height: 8),
        _buildLegendRow('Processing', '2,215 (18%)', const Color(0xFFF59E0B)),
        const SizedBox(height: 8),
        _buildLegendRow('Shipped', '1,542 (12%)', const Color(0xFF10B981)),
        const SizedBox(height: 8),
        _buildLegendRow('Cancelled', '1,632 (13%)', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildLegendRow(String title, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 5, backgroundColor: color),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 12, color: Color(0xFF111827), fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final strokeWidth = 24.0;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Segments percentages: Delivered 0.57, Processing 0.18, Shipped 0.12, Cancelled 0.13
    final segments = [
      {'pct': 0.57, 'color': const Color(0xFF3B82F6)},
      {'pct': 0.18, 'color': const Color(0xFFF59E0B)},
      {'pct': 0.12, 'color': const Color(0xFF10B981)},
      {'pct': 0.13, 'color': const Color(0xFFEF4444)},
    ];

    double startAngle = -pi / 2;

    for (var seg in segments) {
      final sweepAngle = (seg['pct'] as double) * 2 * pi;
      final paint = Paint()
        ..color = seg['color'] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // Draw arc with slight gap
      canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
