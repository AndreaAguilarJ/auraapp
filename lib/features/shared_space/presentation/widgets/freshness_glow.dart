import 'package:flutter/material.dart';
import '../../../../shared/providers/mood_compass_provider.dart';

/// Sistema de indicadores temporales que comunican inmediatez
class FreshnessGlow extends StatefulWidget {
  final Widget child;
  final MoodCompassProvider provider;
  final bool showTimeText;
  final double intensity;

  const FreshnessGlow({
    Key? key,
    required this.child,
    required this.provider,
    this.showTimeText = true,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  State<FreshnessGlow> createState() => _FreshnessGlowState();
}

class _FreshnessGlowState extends State<FreshnessGlow>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para el glow principal
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controlador para pulsos adicionales
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador para fade in/out
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Configurar animaciones
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _updateAnimations();
  }

  @override
  void didUpdateWidget(FreshnessGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;

    if (freshnessLevel > 0.1) {
      // Fade in del glow
      _fadeController.forward();
      
      // Glow constante
      if (!_glowController.isAnimating) {
        _glowController.repeat(reverse: true);
      }
      // Pulsos adicionales para alta frescura
      if (freshnessLevel > 0.8) {
        if (!_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        }
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    } else {
      // Fade out del glow
      _fadeController.reverse();
      _glowController.stop();
      _pulseController.stop();
    }
  }

  /// Calcula el color del glow basado en frescura
  Color _calculateGlowColor(double freshnessLevel) {
    if (freshnessLevel > 0.9) {
      // Verde brillante para muy reciente
      return const Color(0xFF00FF88);
    } else if (freshnessLevel > 0.7) {
      // Verde-azul para reciente
      return const Color(0xFF00CCAA);
    } else if (freshnessLevel > 0.5) {
      // Azul para moderadamente reciente
      return const Color(0xFF0099CC);
    } else if (freshnessLevel > 0.3) {
      // Azul tenue para algo reciente
      return const Color(0xFF0066AA);
    } else {
      // Azul muy tenue para poco reciente
      return const Color(0xFF004488);
    }
  }

  /// Calcula la intensidad del glow
  double _calculateGlowIntensity(double freshnessLevel) {
    return (freshnessLevel * widget.intensity).clamp(0.0, 1.0);
  }

  /// Obtiene el texto descriptivo del tiempo
  String _getLastUpdateText() {
    final partnerMoodSnapshot = widget.provider.partnerMoodSnapshot;
    if (partnerMoodSnapshot == null) return '';
    final lastUpdate = partnerMoodSnapshot.lastUpdated;
    final now = DateTime.now();
    final diff = now.difference(lastUpdate);
    if (diff.inMinutes < 1) return 'ahora mismo';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }

  /// Construye los anillos de glow
  Widget _buildGlowRings(double freshnessLevel) {
    final glowColor = _calculateGlowColor(freshnessLevel);
    final glowIntensity = _calculateGlowIntensity(freshnessLevel);
    
    if (glowIntensity <= 0.05) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: Listenable.merge([_glowAnimation, _pulseAnimation, _fadeAnimation]),
      builder: (context, child) {
        final currentIntensity = glowIntensity * _glowAnimation.value * _fadeAnimation.value;
        final pulseScale = freshnessLevel > 0.8 ? _pulseAnimation.value : 1.0;
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: (currentIntensity * 0.3)),
                    blurRadius: 40.0 * pulseScale,
                    spreadRadius: 20.0 * pulseScale,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: (currentIntensity * 0.5)),
                    blurRadius: 25.0 * pulseScale,
                    spreadRadius: 10.0 * pulseScale,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: (currentIntensity * 0.7)),
                    blurRadius: 15.0 * pulseScale,
                    spreadRadius: 5.0 * pulseScale,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye el texto de tiempo si está habilitado
  Widget _buildTimeText() {
    if (!widget.showTimeText) return const SizedBox.shrink();
    final timeText = _getLastUpdateText();
    if (timeText.isEmpty) return const SizedBox.shrink();
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;
    final textColor = _calculateGlowColor(freshnessLevel);
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value * 0.8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: textColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Text(
              timeText,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;

    // Actualizar animaciones cuando cambie el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations();
    });

    return Stack(
      alignment: Alignment.center,
      children: [
        // Anillos de glow
        _buildGlowRings(freshnessLevel),
        // Widget hijo
        widget.child,
        // Texto de tiempo (posicionado debajo)
        if (widget.showTimeText)
          Positioned(
            bottom: -35,
            child: _buildTimeText(),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

/// Widget helper para aplicar frescura a elementos específicos
class FreshnessIndicator extends StatelessWidget {
  final double freshnessLevel;
  final Widget child;
  final bool showDot;

  const FreshnessIndicator({
    Key? key,
    required this.freshnessLevel,
    required this.child,
    this.showDot = true,
  }) : super(key: key);

  Color _getFreshnessColor() {
    if (freshnessLevel > 0.9) {
      return const Color(0xFF00FF88);
    } else if (freshnessLevel > 0.7) {
      return const Color(0xFF00CCAA);
    } else if (freshnessLevel > 0.5) {
      return const Color(0xFF0099CC);
    } else if (freshnessLevel > 0.3) {
      return const Color(0xFF0066AA);
    } else {
      return const Color(0xFF004488);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (freshnessLevel <= 0.1) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showDot && freshnessLevel > 0.7)
          Positioned(
            top: -5,
            right: -5,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getFreshnessColor(),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getFreshnessColor().withValues(alpha: 0.6),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
