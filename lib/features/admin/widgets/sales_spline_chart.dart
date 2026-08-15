import 'package:flutter/material.dart';

class SalesSplineChart extends StatelessWidget {
  const SalesSplineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          width: double.infinity,
          child: CustomPaint(
            painter: _SplineChartPainter(),
          ),
        ),
        const SizedBox(height: 12),
        // X-Axis Dates
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('01 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('05 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('10 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('15 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
            Text('20 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('25 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            Text('31 May', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
      ],
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    final dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Y-Axis Horizontal Gridlines
    final gridCount = 5;
    for (int i = 0; i <= gridCount; i++) {
      final y = (size.height / gridCount) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Data points (normalized 0..1 x and y)
    final points = [
      Offset(0.00, 0.70),
      Offset(0.08, 0.50),
      Offset(0.16, 0.60),
      Offset(0.24, 0.75),
      Offset(0.30, 0.68),
      Offset(0.36, 0.52),
      Offset(0.42, 0.38),
      Offset(0.48, 0.65),
      Offset(0.54, 0.55),
      Offset(0.60, 0.42),
      Offset(0.66, 0.58),
      Offset(0.72, 0.45),
      Offset(0.78, 0.50),
      Offset(0.84, 0.62),
      Offset(0.90, 0.48),
      Offset(1.00, 0.25),
    ];

    final path = Path();
    final fillPath = Path();

    final mappedPoints = points.map((p) {
      return Offset(p.dx * size.width, (1.0 - p.dy) * size.height);
    }).toList();

    path.moveTo(mappedPoints[0].dx, mappedPoints[0].dy);
    fillPath.moveTo(mappedPoints[0].dx, size.height);
    fillPath.lineTo(mappedPoints[0].dx, mappedPoints[0].dy);

    for (int i = 0; i < mappedPoints.length - 1; i++) {
      final p0 = mappedPoints[i];
      final p1 = mappedPoints[i + 1];

      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
      fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, p1.dx, p1.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Gradient Fill Under Line
    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF6366F1).withValues(alpha: 0.25),
        const Color(0xFF6366F1).withValues(alpha: 0.0),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw data node dots
    for (var pt in mappedPoints) {
      canvas.drawCircle(pt, 4, dotPaint);
      canvas.drawCircle(pt, 2, dotInnerPaint);
    }

    // Draw Highlight Tooltip Callout Box for "15 May ₹78,560" (around 50% width)
    final targetPt = mappedPoints[(mappedPoints.length * 0.52).toInt()];
    _drawCalloutTooltip(canvas, targetPt);
  }

  void _drawCalloutTooltip(Canvas canvas, Offset pt) {
    final tooltipWidth = 90.0;
    final tooltipHeight = 44.0;
    final rect = Rect.fromCenter(
      center: Offset(pt.dx, pt.dy - 35),
      width: tooltipWidth,
      height: tooltipHeight,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    final bgPaint = Paint()..color = Colors.white;

    canvas.drawRRect(rrect, bgPaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rrect, borderPaint);

    // Draw Text
    final textPainter = TextPainter(
      text: const TextSpan(
        children: [
          TextSpan(text: '15 May\n', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
          TextSpan(text: '₹78,560', style: TextStyle(fontSize: 12, color: Color(0xFF111827), fontWeight: FontWeight.w900)),
        ],
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(pt.dx - textPainter.width / 2, pt.dy - 50));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
