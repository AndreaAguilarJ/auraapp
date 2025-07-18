import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../features/shared_space/domain/models/mood_compass_data.dart';
import '../../../../features/shared_space/presentation/widgets/status_selector_widget.dart';
import '../../../../features/shared_space/presentation/widgets/context_note_widget.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla ultra-moderna de la Brújula de Estado y Ánimo con efectos visuales avanzados
class MoodCompassScreen extends StatefulWidget {
  const MoodCompassScreen({Key? key}) : super(key: key);

  @override
  State<MoodCompassScreen> createState() => _MoodCompassScreenState();
}

class _MoodCompassScreenState extends State<MoodCompassScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _updateController;
  late AnimationController _compassController;
  late AnimationController _energyController;
  late AnimationController _particleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _updateAnimation;
  late Animation<double> _compassRotation;
  late Animation<double> _energyWave;
  late Animation<double> _particleFlow;
  late Animation<double> _pulseScale;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _compassController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _energyController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Configurar animaciones
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _updateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _updateController,
      curve: Curves.elasticOut,
    ));

    _compassRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _compassController,
      curve: Curves.linear,
    ));

    _energyWave = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _energyController,
      curve: Curves.easeInOutSine,
    ));

    _particleFlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _pulseScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    // Iniciar animaciones
    _fadeController.forward();
    _compassController.repeat();
    _energyController.repeat(reverse: true);
    _particleController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _updateController.dispose();
    _compassController.dispose();
    _energyController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateMoodCompass() async {
    final provider = Provider.of<MoodCompassProvider>(context, listen: false);

    _updateController.forward().then((_) {
      _updateController.reset();
    });

    try {
      // Determinar qué estado de ánimo está seleccionado actualmente
      String? selectedMoodName;
      for (final entry in MoodCompassProvider.moodMap.entries) {
        if (provider.selectedMood.positivity == entry.value.positivity &&
            provider.selectedMood.energy == entry.value.energy) {
          selectedMoodName = entry.key;
          break;
        }
      }

      if (selectedMoodName == null) {
        throw Exception("Por favor, selecciona un estado de ánimo");
      }

      await provider.updateMoodCompassByName(
        moodName: selectedMoodName,
        contextNote: _noteController.text,
      );

      if (mounted) {
        _showSuccessSnackbar(selectedMoodName);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    }
  }

  void _showSuccessSnackbar(String moodName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: AuraSpacing.s),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: Theme.of(context).energyGradient,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AuraSpacing.m),
              Expanded(
                child: Text(
                  '✨ Tu estado "$moodName" ha sido compartido',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(AuraSpacing.m),
      ),
    );
  }

  void _showErrorSnackbar(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: AuraSpacing.s),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade600,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AuraSpacing.m),
              Expanded(
                child: Text(
                  'Error al actualizar: $error',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(AuraSpacing.m),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Consumer<MoodCompassProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            // Fondo dinámico
            _buildDynamicBackground(theme, size),
            // Partículas emocionales
            _buildEmotionalParticles(theme, size),
            // Contenido principal
            FadeTransition(
              opacity: _fadeAnimation,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AuraSpacing.l),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header ultra-moderno
                          _buildUltraModernHeader(theme),
                          const SizedBox(height: AuraSpacing.xl),

                          // Estado actual si existe
                          if (provider.currentData != null)
                            _buildCurrentStatusCard(theme, provider.currentData!),

                          if (provider.currentData != null)
                            const SizedBox(height: AuraSpacing.xl),

                          // Brújula emocional moderna
                          _buildModernEmotionalCompass(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),

                          // Selector de estado modernizado
                          _buildModernStatusSection(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),

                          // Nota contextual moderna
                          _buildModernContextNoteSection(theme),
                          const SizedBox(height: AuraSpacing.xl),

                          // Botón de actualización futurista
                          _buildFuturisticUpdateButton(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDynamicBackground(ThemeData theme, Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_compassRotation, _energyWave]),
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0 + (_energyWave.value * 0.3),
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.secondary.withOpacity(0.03),
                theme.colorScheme.tertiary.withOpacity(0.02),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: CompassBackgroundPainter(
              compassRotation: _compassRotation.value,
              energyWave: _energyWave.value,
              theme: theme,
            ),
            size: size,
          ),
        );
      },
    );
  }

  Widget _buildEmotionalParticles(ThemeData theme, Size size) {
    return AnimatedBuilder(
      animation: _particleFlow,
      builder: (context, child) {
        return CustomPaint(
          painter: EmotionalParticlesPainter(
            animation: _particleFlow.value,
            theme: theme,
          ),
          size: size,
        );
      },
    );
  }

  Widget _buildUltraModernHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseScale.value,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: theme.energyGradient,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.explore_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: AuraSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => theme.connectionGradient.createShader(bounds),
                    child: Text(
                      'Brújula Emocional',
                      style: AuraTypography.headlineLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Comparte tu estado del alma',
                    style: AuraTypography.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentStatusCard(ThemeData theme, MoodCompassData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Última actualización: ${_formatTime(data.lastUpdated)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (data.contextNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${data.contextNote}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).toInt()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernEmotionalCompass(ThemeData theme, MoodCompassProvider provider) {
    // Lista de estados de ánimo disponibles (obtenidos del mapa definido en el provider)
    final moodNames = MoodCompassProvider.moodMap.keys.toList();

    // Estado para rastrear el estado de ánimo seleccionado actualmente
    String? _selectedMoodName;

    // Para cada estado de ánimo en el mapa, verificar si las coordenadas coinciden con el seleccionado actualmente
    for (final entry in MoodCompassProvider.moodMap.entries) {
      if (provider.selectedMood.positivity == entry.value.positivity &&
          provider.selectedMood.energy == entry.value.energy) {
        _selectedMoodName = entry.key;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te sientes en este momento?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el estado de ánimo que mejor represente cómo te sientes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
        const SizedBox(height: 16),

        // Wrap de botones de estados de ánimo
        Wrap(
          spacing: 8.0,
          runSpacing: 12.0,
          children: moodNames.map((moodName) {
            // Determinar si este estado de ánimo está seleccionado
            final isSelected = _selectedMoodName == moodName;

            // Obtener las coordenadas para este estado de ánimo para darle colores acordes
            final coordinates = MoodCompassProvider.moodMap[moodName]!
;
            // Determinar color basado en positividad (rojo para negativo, verde para positivo)
            final baseColor = coordinates.positivity > 0
                ? Color.lerp(Colors.yellow, Colors.green, (coordinates.positivity.abs() / 1.0))!
                : Color.lerp(Colors.orange, Colors.red, (coordinates.positivity.abs() / 1.0))!;

            // Determinar brillo basado en energía
            final brightness = coordinates.energy > 0 ? 1.0 : 0.7;

            return ElevatedButton(
              onPressed: () {
                // Cuando se presiona un botón, llamar a setMood con las coordenadas correspondientes
                provider.setMood(MoodCompassProvider.moodMap[moodName]!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? baseColor.withOpacity(0.7 * brightness)
                    : theme.colorScheme.surface.withAlpha((0.1 * 255).toInt()),
                foregroundColor: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? baseColor
                        : theme.colorScheme.onSurface.withAlpha((0.2 * 255).toInt()),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Agregar un ícono que represente el estado de ánimo
                  Icon(
                    _getMoodIcon(moodName),
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(moodName),
                  if (isSelected)
                    const SizedBox(width: 8),
                  if (isSelected)
                    const Icon(Icons.check, size: 18),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper para obtener un ícono apropiado para cada estado de ánimo
  IconData _getMoodIcon(String moodName) {
    switch (moodName) {
      case 'Feliz': return Icons.sentiment_very_satisfied;
      case 'Enérgico': return Icons.bolt;
      case 'Tranquilo': return Icons.spa;
      case 'Cansado': return Icons.bedtime;
      case 'Estresado': return Icons.psychology;
      case 'Triste': return Icons.sentiment_very_dissatisfied;
      case 'Enfadado': return Icons.whatshot;
      default: return Icons.mood;
    }
  }

  Widget _buildModernStatusSection(ThemeData theme, MoodCompassProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te gustaría aparecer?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        StatusSelectorWidget(
          currentStatus: provider.selectedStatus,
          onStatusChanged: provider.setStatus,
        ),
      ],
    );
  }

  Widget _buildModernContextNoteSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Algo más que quieras compartir?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Opcional - Máximo 140 caracteres',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
        const SizedBox(height: 16),
        ContextNoteWidget(
          controller: _noteController,
          maxLength: 140,
        ),
      ],
    );
  }

  Widget _buildFuturisticUpdateButton(ThemeData theme, MoodCompassProvider provider) {
    return AnimatedBuilder(
      animation: _updateController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_updateController.value * 0.05),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _updateMoodCompass,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Actualizar mi Aura',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}

/// Painter personalizado para el fondo de la brújula
class CompassBackgroundPainter extends CustomPainter {
  final double compassRotation;
  final double energyWave;
  final ThemeData theme;

  CompassBackgroundPainter({
    required this.compassRotation,
    required this.energyWave,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    // Círculos concéntricos de energía
    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = theme.colorScheme.primary.withOpacity(
          0.1 * (1 - i * 0.2) * (0.5 + 0.5 * math.sin(energyWave * math.pi + i)),
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 + i;

      final currentRadius = radius * (0.3 + i * 0.2) * (1 + energyWave * 0.1);
      canvas.drawCircle(center, currentRadius, paint);
    }

    // Líneas radiales de la brújula (girando lentamente)
    final linePaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + compassRotation * 0.1;
      final startRadius = radius * 0.5;
      final endRadius = radius * 0.9;

      final start = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );

      final end = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(start, end, linePaint);
    }

    // Puntos cardinales emocionales
    final pointPaint = Paint()
      ..color = theme.colorScheme.tertiary.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final pointRadius = 4.0 + 2.0 * math.sin(energyWave * math.pi * 2 + i);

      final point = Offset(
        center.dx + math.cos(angle) * radius * 0.8,
        center.dy + math.sin(angle) * radius * 0.8,
      );

      canvas.drawCircle(point, pointRadius, pointPaint);
    }

    // Ondas de energía emocional
    final wavePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = energyWave * 200 + i * 60;

      path.moveTo(0, size.height * 0.2 + i * size.height * 0.3);

      for (double x = 0; x <= size.width; x += 20) {
        final y = (size.height * 0.2 + i * size.height * 0.3) +
                  math.sin((x + waveOffset) * 0.01) * 25;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(CompassBackgroundPainter oldDelegate) {
    return oldDelegate.compassRotation != compassRotation ||
           oldDelegate.energyWave != energyWave;
  }
}

/// Painter personalizado para partículas emocionales
class EmotionalParticlesPainter extends CustomPainter {
  final double animation;
  final ThemeData theme;
  late final List<EmotionalParticle> particles;

  EmotionalParticlesPainter({
    required this.animation,
    required this.theme,
  }) {
    particles = _generateEmotionalParticles();
  }

  List<EmotionalParticle> _generateEmotionalParticles() {
    final particleList = <EmotionalParticle>[];
    final random = math.Random(456); // Seed fijo para consistencia

    for (int i = 0; i < 40; i++) {
      particleList.add(EmotionalParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1.5 + random.nextDouble() * 3,
        speed: 0.02 + random.nextDouble() * 0.08,
        opacity: 0.15 + random.nextDouble() * 0.4,
        phase: random.nextDouble() * math.pi * 2,
        emotion: EmotionType.values[random.nextInt(EmotionType.values.length)],
      ));
    }
    return particleList;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final color = _getEmotionColor(particle.emotion);

      final paint = Paint()
        ..color = color.withOpacity(
          particle.opacity * (0.7 + 0.3 * math.sin(animation * math.pi * 2 + particle.phase))
        )
        ..style = PaintingStyle.fill;

      final x = (particle.x + animation * particle.speed) % 1.0 * size.width;
      final y = (particle.y + animation * particle.speed * 0.4) % 1.0 * size.height;

      // Efecto de respiración emocional
      final emotionalPulse = 1.0 + 0.3 * math.sin(animation * math.pi * 3 + particle.phase);

      // Forma diferente según la emoción
      switch (particle.emotion) {
        case EmotionType.joy:
          // Estrella para alegría
          _drawStar(canvas, Offset(x, y), particle.size * emotionalPulse, paint);
          break;
        case EmotionType.love:
          // Corazón para amor
          _drawHeart(canvas, Offset(x, y), particle.size * emotionalPulse, paint);
          break;
        case EmotionType.peace:
          // Círculo para paz
          canvas.drawCircle(Offset(x, y), particle.size * emotionalPulse, paint);
          break;
        case EmotionType.energy:
          // Rayo para energía
          _drawLightning(canvas, Offset(x, y), particle.size * emotionalPulse, paint);
          break;
        default:
          canvas.drawCircle(Offset(x, y), particle.size * emotionalPulse, paint);
      }

      // Estela emocional
      if (particle.size > 2) {
        final trailPaint = Paint()
          ..color = color.withOpacity(particle.opacity * 0.2)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x - 4, y - 3),
          particle.size * 0.3 * emotionalPulse,
          trailPaint,
        );
      }
    }
  }

  Color _getEmotionColor(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.joy:
        return Colors.amber;
      case EmotionType.love:
        return Colors.pink;
      case EmotionType.peace:
        return Colors.blue;
      case EmotionType.energy:
        return Colors.orange;
      default:
        return theme.colorScheme.primary;
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final points = 5;
    final outerRadius = size;
    final innerRadius = size * 0.4;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final scale = size / 10;

    path.moveTo(center.dx, center.dy + 4 * scale);
    path.cubicTo(
      center.dx - 6 * scale, center.dy - 2 * scale,
      center.dx - 10 * scale, center.dy - 6 * scale,
      center.dx, center.dy - 2 * scale,
    );
    path.cubicTo(
      center.dx + 10 * scale, center.dy - 6 * scale,
      center.dx + 6 * scale, center.dy - 2 * scale,
      center.dx, center.dy + 4 * scale,
    );

    canvas.drawPath(path, paint);
  }

  void _drawLightning(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final scale = size / 8;

    path.moveTo(center.dx - 2 * scale, center.dy - 4 * scale);
    path.lineTo(center.dx + 1 * scale, center.dy - 1 * scale);
    path.lineTo(center.dx - 1 * scale, center.dy - 1 * scale);
    path.lineTo(center.dx + 2 * scale, center.dy + 4 * scale);
    path.lineTo(center.dx - 1 * scale, center.dy + 1 * scale);
    path.lineTo(center.dx + 1 * scale, center.dy + 1 * scale);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(EmotionalParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

enum EmotionType {
  joy,
  love,
  peace,
  energy,
}

class EmotionalParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;
  final EmotionType emotion;

  EmotionalParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.emotion,
  });
}
