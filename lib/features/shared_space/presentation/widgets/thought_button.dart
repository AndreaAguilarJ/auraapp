import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../core/constants/app_styles.dart';
import '../../domain/models/thought_pulse.dart';

/// Botón para enviar "pulsos de pensamiento" cariñosos
class ThoughtButton extends StatefulWidget {
  final MoodCompassProvider provider;
  final VoidCallback? onPressed;
  final String? customText;
  final bool showCooldown;

  const ThoughtButton({
    Key? key,
    required this.provider,
    this.onPressed,
    this.customText,
    this.showCooldown = true,
  }) : super(key: key);

  @override
  State<ThoughtButton> createState() => _ThoughtButtonState();
}

class _ThoughtButtonState extends State<ThoughtButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _rippleController;
  late AnimationController _heartController;
  late AnimationController _cooldownController;
  
  late Animation<double> _pressAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _heartOpacityAnimation;
  late Animation<double> _heartScaleAnimation;
  late Animation<double> _cooldownAnimation;

  bool _isLoading = false;
  List<Widget> _floatingHearts = [];

  @override
  void initState() {
    super.initState();
    
    // Controlador para el efecto de presión
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    // Controlador para las ondas expansivas
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controlador para los corazones flotantes
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Controlador para el indicador de cooldown
    _cooldownController = AnimationController(
      duration: const Duration(seconds: 5), // Duración del cooldown
      vsync: this,
    );

    // Configurar animaciones
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _heartOpacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _heartScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeOut,
    ));

    _cooldownAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _cooldownController,
      curve: Curves.linear,
    ));

    // Listener para el cooldown
    _cooldownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {});
      }
    });
  }

  /// Maneja la acción de presionar el botón
  Future<void> _handlePress() async {
    if (!widget.provider.canSendPulse || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Animación de presión
    await _pressController.forward();
    
    // Feedback háptico
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.selectionClick();

    // Llamar callback personalizado o enviar pulso por defecto
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      await widget.provider.sendThoughtPulse(type: ThoughtPulseType.basic);
    }

    // Iniciar animaciones de éxito
    _startSuccessAnimations();

    // Iniciar cooldown si está habilitado
    if (widget.showCooldown) {
      _startCooldown();
    }

    setState(() {
      _isLoading = false;
    });

    // Regresar botón a estado normal
    await _pressController.reverse();
  }

  /// Inicia las animaciones de éxito (ondas y corazones)
  void _startSuccessAnimations() {
    // Ondas expansivas
    _rippleController.forward(from: 0.0);
    
    // Corazones flotantes
    _generateFloatingHearts();
    _heartController.forward(from: 0.0);
    
    // Limpiar corazones después de la animación
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _floatingHearts.clear();
        });
      }
    });
  }

  /// Genera corazones flotantes aleatorios
  void _generateFloatingHearts() {
    _floatingHearts.clear();
    final random = math.Random();
    
    for (int i = 0; i < 5; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final distance = 80.0 + (random.nextDouble() * 40.0);
      
      _floatingHearts.add(
        _FloatingHeart(
          angle: angle,
          distance: distance,
          delay: i * 0.1,
          animation: _heartController,
          opacityAnimation: _heartOpacityAnimation,
          scaleAnimation: _heartScaleAnimation,
        ),
      );
    }
  }

  /// Inicia el cooldown del botón
  void _startCooldown() {
    // Elimina la lógica de cooldownRemaining, ya que no existe en el provider
    // Si quieres implementar cooldown, debes agregar la lógica en el provider
    // Por ahora, simplemente no hagas nada aquí
  }

  /// Construye las ondas expansivas
  Widget _buildRipples() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Onda exterior
            Container(
              width: 120 * _rippleAnimation.value,
              height: 120 * _rippleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(
                    alpha: (1.0 - _rippleAnimation.value) * 0.8,
                  ),
                  width: 2.0,
                ),
              ),
            ),
            // Onda interior
            Container(
              width: 80 * _rippleAnimation.value,
              height: 80 * _rippleAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryTeal.withValues(
                    alpha: (1.0 - _rippleAnimation.value) * 0.6,
                  ),
                  width: 1.5,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construye los corazones flotantes
  Widget _buildFloatingHearts() {
    return Stack(
      alignment: Alignment.center,
      children: _floatingHearts,
    );
  }

  /// Construye el indicador de cooldown
  Widget _buildCooldownIndicator() {
    if (!widget.showCooldown || widget.provider.canSendPulse) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _cooldownAnimation,
        builder: (context, child) {
          // Elimina la lógica de remainingSeconds, ya que cooldownRemaining no existe
          return Stack(
            alignment: Alignment.center,
            children: [
              // Círculo de progreso
              CircularProgressIndicator(
                value: 1.0 - _cooldownAnimation.value,
                strokeWidth: 3.0,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryTeal.withValues(alpha: 0.8),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.provider.canSendPulse && !_isLoading;
    final buttonText = widget.customText ?? 'Pienso en ti';

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ondas expansivas
          _buildRipples(),
          // Corazones flotantes
          _buildFloatingHearts(),
          // Botón principal
          AnimatedBuilder(
            animation: _pressAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pressAnimation.value,
                child: GestureDetector(
                  onTapDown: canSend ? (_) => _handlePress() : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canSend 
                          ? AppColors.primaryTeal
                          : AppColors.primaryTeal.withValues(alpha: 0.5),
                      boxShadow: canSend ? [
                        BoxShadow(
                          color: AppColors.primaryTeal.withValues(alpha: 0.4),
                          blurRadius: 15.0,
                          offset: const Offset(0, 5),
                        ),
                      ] : [],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Contenido del botón
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        else
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                buttonText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        // Indicador de cooldown
                        _buildCooldownIndicator(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _rippleController.dispose();
    _heartController.dispose();
    _cooldownController.dispose();
    super.dispose();
  }
}

/// Widget para corazones flotantes individuales
class _FloatingHeart extends StatelessWidget {
  final double angle;
  final double distance;
  final double delay;
  final AnimationController animation;
  final Animation<double> opacityAnimation;
  final Animation<double> scaleAnimation;

  const _FloatingHeart({
    required this.angle,
    required this.distance,
    required this.delay,
    required this.animation,
    required this.opacityAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calcular progreso con delay
        final progress = ((animation.value - delay).clamp(0.0, 1.0));
        if (progress <= 0.0) return const SizedBox.shrink();

        // Calcular posición
        final x = math.cos(angle) * distance * progress;
        final y = math.sin(angle) * distance * progress;

        return Transform.translate(
          offset: Offset(x, y),
          child: Transform.scale(
            scale: scaleAnimation.value * progress,
            child: Opacity(
              opacity: opacityAnimation.value * (1.0 - progress * 0.3),
              child: const Icon(
                Icons.favorite,
                color: Colors.pinkAccent,
                size: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
