import 'package:flutter/material.dart';
import 'dart:math' as math;

class HalfCylinderPawn extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelected;

  const HalfCylinderPawn({
    super.key,
    required this.color,
    required this.size,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.yellow, width: 3),
            )
          : null,
      child: CustomPaint(
        painter: HalfCylinderPainter(
          color: color,
        ),
      ),
    );
  }
}

class HalfCylinderPainter extends CustomPainter {
  final Color color;

  HalfCylinderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Calculate dimensions for the half cylinder
    final cylinderWidth = width * 0.8;
    final cylinderHeight = height * 0.85;
    final depth = width * 0.3; // Depth of the cylinder

    final centerX = width / 2;
    final baseY = height * 0.9;
    final topY = height * 0.15;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY + 3),
        width: cylinderWidth * 0.9,
        height: depth * 0.4,
      ),
      shadowPaint,
    );

    // Draw the base (bottom ellipse)
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withOpacity(0.6),
          color,
          color.withOpacity(0.6),
        ],
      ).createShader(Rect.fromLTWH(
        centerX - cylinderWidth / 2,
        baseY - depth / 2,
        cylinderWidth,
        depth,
      ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, baseY),
        width: cylinderWidth,
        height: depth,
      ),
      basePaint,
    );

    // Draw the side (rectangle connecting top and bottom)
    final sidePath = Path()
      ..moveTo(centerX - cylinderWidth / 2, topY)
      ..lineTo(centerX - cylinderWidth / 2, baseY)
      ..arcToPoint(
        Offset(centerX + cylinderWidth / 2, baseY),
        radius: Radius.circular(cylinderWidth / 2),
        clockwise: true,
      )
      ..lineTo(centerX + cylinderWidth / 2, topY)
      ..arcToPoint(
        Offset(centerX - cylinderWidth / 2, topY),
        radius: Radius.circular(cylinderWidth / 2),
        clockwise: false,
      )
      ..close();

    final sidePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withOpacity(0.7),
          color,
          color.withOpacity(0.9),
          color,
          color.withOpacity(0.7),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(
        centerX - cylinderWidth / 2,
        topY,
        cylinderWidth,
        cylinderHeight,
      ));

    canvas.drawPath(sidePath, sidePaint);

    // Draw the top (top ellipse)
    final topPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.5),
        radius: 0.8,
        colors: [
          color.withOpacity(1.0),
          color,
          color.withOpacity(0.8),
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(centerX, topY),
        width: cylinderWidth,
        height: depth,
      ));

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, topY),
        width: cylinderWidth,
        height: depth,
      ),
      topPaint,
    );

    // Add highlight on top edge
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(centerX, topY),
        width: cylinderWidth - 4,
        height: depth - 2,
      ),
      -math.pi,
      math.pi,
      false,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant HalfCylinderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
