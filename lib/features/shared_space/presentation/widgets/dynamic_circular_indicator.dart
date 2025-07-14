import 'package:flutter/material.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/models/user_status.dart';

/// Indicador circular dinámico que muestra el estado/ánimo de la pareja
class DynamicCircularIndicator extends StatefulWidget {
  final double size;
  final MoodCompassProvider provider;
  final VoidCallback? onTap;

  const DynamicCircularIndicator({
    Key? key,
    this.size = 200.0,
    required this.provider,
    this.onTap,
  }) : super(key: key);

  @override
  State<DynamicCircularIndicator> createState() => _DynamicCircularIndicatorState();
}

class _DynamicCircularIndicatorState extends State<DynamicCircularIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _transitionController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _transitionAnimation;

  UserStatus? _previousStatus;
  Color _currentColor = AppColors.statusAvailable;

  @override
  void initState() {
    super.initState();
    
    // Controlador para el pulso de frescura
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Controlador para el glow de frescura
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Controlador para transiciones de estado
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Configurar animaciones
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeOutQuart,
    ));

    _transitionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.elasticOut,
    ));

    // Inicializar estado
    _updateAnimations();
  }

  @override
  void didUpdateWidget(DynamicCircularIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final partnerStatus = widget.provider.partnerMoodSnapshot?.status;
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;

    // Detectar cambio de estado para animación de transición
    if (partnerStatus != _previousStatus && partnerStatus != null) {
      _previousStatus = partnerStatus;
      _currentColor = _getStatusColor(partnerStatus);
      _transitionController.forward(from: 0.0);
    } else if (partnerStatus != null) {
      _currentColor = _getStatusColor(partnerStatus);
    }

    // Animar pulso basado en frescura
    if (freshnessLevel > 0.7) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Animar glow para actualizaciones muy recientes
    if (freshnessLevel > 0.9) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.reset();
    }
  }

  /// Calcula el color del indicador con ajustes de humor
  Color _calculateIndicatorColor() {
    if (widget.provider.partnerMoodSnapshot == null) {
      return AppColors.backgroundLight.withValues(alpha: 0.3);
    }

    return _getStatusColor(widget.provider.partnerMoodSnapshot!.status);
  }

  /// Calcula la intensidad del glow basado en frescura
  double _calculateGlowIntensity() {
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;
    return (freshnessLevel * 0.8).clamp(0.0, 0.8);
  }

  /// Obtiene el color para un UserStatus
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.available:
        return AppColors.statusAvailable;
      case UserStatus.busy:
        return AppColors.statusBusy;
      case UserStatus.resting:
        return AppColors.statusResting;
      case UserStatus.traveling:
        return AppColors.statusTraveling;
      case UserStatus.offline:
        return AppColors.statusOffline;
    }
  }

  /// Obtiene el icono para un UserStatus
  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.available:
        return Icons.check_circle;
      case UserStatus.busy:
        return Icons.work;
      case UserStatus.resting:
        return Icons.bedtime;
      case UserStatus.traveling:
        return Icons.airplanemode_active;
      case UserStatus.offline:
        return Icons.cloud_off;
    }
  }

  /// Construye los círculos de glow animados
  Widget _buildGlowRings() {
    final glowIntensity = _calculateGlowIntensity();
    if (glowIntensity <= 0.1) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow exterior
            Container(
              width: widget.size * (1.0 + (_glowAnimation.value * 0.3)),
              height: widget.size * (1.0 + (_glowAnimation.value * 0.3)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: glowIntensity * 0.6),
                    blurRadius: 20.0 * _glowAnimation.value,
                    spreadRadius: 5.0 * _glowAnimation.value,
                  ),
                ],
              ),
            ),
            // Glow interior
            Container(
              width: widget.size * (1.0 + (_glowAnimation.value * 0.15)),
              height: widget.size * (1.0 + (_glowAnimation.value * 0.15)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentColor.withValues(alpha: glowIntensity * 0.4),
                    blurRadius: 10.0 * _glowAnimation.value,
                    spreadRadius: 2.0 * _glowAnimation.value,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye el círculo principal con estado
  Widget _buildMainCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _transitionAnimation]),
      builder: (context, child) {
        final scale = 1.0 + (_transitionAnimation.value * 0.1);
        final pulseScale = _pulseAnimation.value;
        
        return Transform.scale(
          scale: scale * pulseScale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _calculateIndicatorColor(),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentColor.withValues(alpha: 0.3),
                  blurRadius: 15.0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: _buildCircleContent(),
          ),
        );
      },
    );
  }

  /// Construye el contenido dentro del círculo
  Widget _buildCircleContent() {
    if (widget.provider.partnerMoodSnapshot == null) {
      return const Center(
        child: Icon(
          Icons.favorite_border,
          size: 60,
          color: Colors.white70,
        ),
      );
    }

    final partnerStatus = widget.provider.partnerMoodSnapshot!.status;
    final freshnessLevel = widget.provider.partnerMoodSnapshot?.freshness ?? 0.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono del estado
          AnimatedScale(
            scale: 1.0 + (freshnessLevel * 0.2),
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _getStatusIcon(partnerStatus),
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Texto del estado
          Text(
            partnerStatus.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (freshnessLevel > 0.5) ...[
            const SizedBox(height: 4),
            // Indicador de frescura
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getFreshnessText(freshnessLevel),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Obtiene el texto descriptivo de la frescura
  String _getFreshnessText(double freshnessLevel) {
    if (freshnessLevel > 0.9) {
      return 'Ahora mismo';
    } else if (freshnessLevel > 0.7) {
      return 'Muy reciente';
    } else if (freshnessLevel > 0.5) {
      return 'Reciente';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actualizar animaciones cuando cambie el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimations();
    });

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: widget.size * 1.5,
        height: widget.size * 1.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anillos de glow
            _buildGlowRings(),
            // Círculo principal
            _buildMainCircle(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _transitionController.dispose();
    super.dispose();
  }
}
