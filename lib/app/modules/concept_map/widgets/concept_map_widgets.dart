import 'dart:math' as math;
import 'package:flutter/material.dart';

class CoreNodeCard extends StatelessWidget {
  final String title;
  final String label;
  
  const CoreNodeCard({
    Key? key, 
    required this.title, 
    required this.label
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E60E8), Color(0xFF0046D5)],
          begin: Alignment.topLeft, 
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0056FF).withOpacity(0.25), 
            blurRadius: 12, 
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, color: Colors.white, size: 26),
          const SizedBox(height: 8),
          Text(
            title, 
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 12, 
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2), 
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label.toUpperCase(), 
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 8, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 0.3,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SubNodeCard extends StatelessWidget {
  final String title;
  final String moduleNum;
  final IconData icon;

  const SubNodeCard({
    Key? key, 
    required this.title, 
    required this.moduleNum, 
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 8, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FF), 
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF0056FF)),
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            textAlign: TextAlign.center, 
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 11, 
              color: Colors.black87, 
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            moduleNum, 
            maxLines: 1,
            style: TextStyle(
              fontSize: 9, 
              fontWeight: FontWeight.bold, 
              color: Colors.grey.shade400,
            ),
          )
        ],
      ),
    );
  }
}

class DynamicMindMapLinesPainter extends CustomPainter {
  final int nodeCount;
  final double canvasCenter;
  final double radius;

  DynamicMindMapLinesPainter({
    required this.nodeCount,
    required this.canvasCenter,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount == 0) return;

    final paint = Paint()
      ..color = const Color(0xFFBDD4FF) 
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(canvasCenter, canvasCenter);

    for (int i = 0; i < nodeCount; i++) {
      double angle = (2 * math.pi * i) / nodeCount;
      
      double targetX = canvasCenter + radius * math.cos(angle);
      double targetY = canvasCenter + radius * math.sin(angle);
      Offset targetOffset = Offset(targetX, targetY);

      _drawDashedLine(canvas, center, targetOffset, paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 6;
    const int dashSpace = 4;
    double distance = (p2 - p1).distance;
    double dx = (p2.dx - p1.dx) / distance;
    double dy = (p2.dy - p1.dy) / distance;
    double startX = p1.dx;
    double startY = p1.dy;

    while (distance >= 0) {
      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + dx * dashWidth, startY + dy * dashWidth),
        paint,
      );
      startX += dx * (dashWidth + dashSpace);
      startY += dy * (dashWidth + dashSpace);
      distance -= (dashWidth + dashSpace);
    }
  }

  @override
  bool shouldRepaint(covariant DynamicMindMapLinesPainter oldDelegate) {
    return oldDelegate.nodeCount != nodeCount || 
           oldDelegate.canvasCenter != canvasCenter || 
           oldDelegate.radius != radius;
  }
}