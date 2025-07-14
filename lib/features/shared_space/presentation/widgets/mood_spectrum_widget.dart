import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/models/mood_coordinates.dart';

/// Widget de espectro de estado de ánimo interactivo en forma de brújula
class MoodSpectrumWidget extends StatefulWidget {
  final MoodCoordinates currentMood;
  final Function(MoodCoordinates) onMoodChanged;

  const MoodSpectrumWidget({
    Key? key,
    required this.currentMood,
    required this.onMoodChanged,
  }) : super(key: key);

  @override
  State<MoodSpectrumWidget> createState() => _MoodSpectrumWidgetState();
}

class _MoodSpectrumWidgetState extends State<MoodSpectrumWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    // Calcular la posición relativa al centro
    final localPosition = details.localPosition - center;
    final distance = localPosition.distance;

    if (distance <= radius) {
      // Convertir coordenadas de pantalla a coordenadas de ánimo
      final energy = (localPosition.dx / radius).clamp(-1.0, 1.0);
      final positivity = (-localPosition.dy / radius).clamp(-1.0, 1.0); // Invertir Y

      widget.onMoodChanged(MoodCoordinates(
        energy: energy,
        positivity: positivity,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      child: GestureDetector(
        onPanUpdate: (details) => _handlePanUpdate(details, const Size(300, 300)),
        onTapUp: (details) => _handlePanUpdate(
          DragUpdateDetails(
            localPosition: details.localPosition,
            globalPosition: details.globalPosition,
            delta: Offset.zero,
          ),
          const Size(300, 300),
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: MoodCompassPainter(
                currentMood: widget.currentMood,
                pulseScale: _pulseAnimation.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter para dibujar la brújula de estados de ánimo
class MoodCompassPainter extends CustomPainter {
  final MoodCoordinates currentMood;
  final double pulseScale;

  MoodCompassPainter({
    required this.currentMood,
    required this.pulseScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    // Dibujar círculo de fondo
    _drawBackground(canvas, center, radius);

    // Dibujar cuadrantes
    _drawQuadrants(canvas, center, radius);

    // Dibujar etiquetas de emociones
    _drawEmotionLabels(canvas, center, radius);

    // Dibujar el punto del usuario
    _drawUserPoint(canvas, center, radius);

    // Dibujar ejes
    _drawAxes(canvas, center, radius);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Borde del círculo
    final borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawQuadrants(Canvas canvas, Offset center, double radius) {
    final quadrantColors = [
      Colors.yellow.withOpacity(0.2), // Energético + Positivo
      Colors.green.withOpacity(0.2),  // Tranquilo + Positivo
      Colors.blue.withOpacity(0.2),   // Tranquilo + Negativo
      Colors.red.withOpacity(0.2),    // Energético + Negativo
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = quadrantColors[i]
        ..style = PaintingStyle.fill;

      final startAngle = (i * math.pi / 2) - (math.pi / 4);
      const sweepAngle = math.pi / 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
    }
  }

  void _drawEmotionLabels(Canvas canvas, Offset center, double radius) {
    final emotions = [
      {'label': 'Feliz', 'angle': math.pi / 4, 'color': Colors.yellow[700]!},
      {'label': 'Sereno', 'angle': 3 * math.pi / 4, 'color': Colors.green[700]!},
      {'label': 'Triste', 'angle': 5 * math.pi / 4, 'color': Colors.blue[700]!},
      {'label': 'Enojado', 'angle': 7 * math.pi / 4, 'color': Colors.red[700]!},
    ];

    for (final emotion in emotions) {
      final angle = emotion['angle'] as double;
      final color = emotion['color'] as Color;
      final label = emotion['label'] as String;

      // CORRECCIÓN: Calcular posición usando el centro como origen
      final labelRadius = radius + 25;
      final x = center.dx + labelRadius * math.cos(angle);
      final y = center.dy + labelRadius * math.sin(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Centrar el texto en la posición calculada
      final textOffset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, textOffset);

      // Dibujar punto indicador
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final pointRadius = radius * 0.85;
      final pointX = center.dx + pointRadius * math.cos(angle);
      final pointY = center.dy + pointRadius * math.sin(angle);

      canvas.drawCircle(Offset(pointX, pointY), 4, pointPaint);
    }
  }

  void _drawUserPoint(Canvas canvas, Offset center, double radius) {
    // CORRECCIÓN: Calcular posición del usuario usando el centro como origen
    final userX = center.dx + currentMood.energy * radius;
    final userY = center.dy - currentMood.positivity * radius; // Invertir Y para UI

    final userPosition = Offset(userX, userY);

    // Punto exterior con pulso
    final outerPaint = Paint()
      ..color = Colors.purple.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(userPosition, 15 * pulseScale, outerPaint);

    // Punto interior
    final innerPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    canvas.drawCircle(userPosition, 8, innerPaint);

    // Borde blanco
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(userPosition, 8, borderPaint);
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final axesPaint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Eje horizontal (Energía: Tranquilo ↔ Energético)
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axesPaint,
    );

    // Eje vertical (Positividad: Negativo ↔ Positivo)
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axesPaint,
    );

    // Etiquetas de los ejes
    _drawAxisLabels(canvas, center, radius);
  }

  void _drawAxisLabels(Canvas canvas, Offset center, double radius) {
    final labelStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final labels = [
      {'text': 'Tranquilo', 'x': center.dx - radius - 40, 'y': center.dy},
      {'text': 'Energético', 'x': center.dx + radius + 10, 'y': center.dy},
      {'text': 'Positivo', 'x': center.dx, 'y': center.dy - radius - 25},
      {'text': 'Negativo', 'x': center.dx, 'y': center.dy + radius + 15},
    ];

    for (final label in labels) {
      final textPainter = TextPainter(
        text: TextSpan(text: label['text'] as String, style: labelStyle),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      double x = label['x'] as double;
      double y = label['y'] as double;

      // Centrar las etiquetas verticales
      if (label['text'] == 'Positivo' || label['text'] == 'Negativo') {
        x -= textPainter.width / 2;
      }
      if (label['text'] == 'Tranquilo' || label['text'] == 'Energético') {
        y -= textPainter.height / 2;
      }

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
