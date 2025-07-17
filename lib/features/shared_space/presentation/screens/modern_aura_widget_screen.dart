import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui'; // For Flutter's Size type
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla rediseñada del Widget Aura - Moderno y expresivo
class ModernAuraWidgetScreen extends StatefulWidget {
  const ModernAuraWidgetScreen({Key? key}) : super(key: key);

  @override
  State<ModernAuraWidgetScreen> createState() => _ModernAuraWidgetScreenState();
}

class _ModernAuraWidgetScreenState extends State<ModernAuraWidgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _connectionController;
  late AnimationController _thoughtController;

  late Animation<double> _heartbeatAnimation;
  late Animation<double> _connectionPulse;
  late Animation<double> _thoughtRipple;

  @override
  void initState() {
    super.initState();

    // Animación de latido del corazón emocional
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animación de conexión entre las auras
    _connectionController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Animación para el botón "Pienso en ti"
    _thoughtController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartbeatAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOut,
    ));

    _connectionPulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOutSine,
    ));

    _thoughtRipple = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _thoughtController,
      curve: AuraAnimations.elastic,
    ));

    // Iniciar animaciones
    _heartbeatController.repeat(reverse: true);
    _connectionController.repeat();
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _connectionController.dispose();
    _thoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(theme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Consumer<MoodCompassProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return _buildLoadingState(theme);
            }

            if (provider.errorMessage != null) {
              return _buildErrorState(theme, provider);
            }

            return SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AuraSpacing.l),
                      child: Column(
                        children: [
                          // Header con saludo personalizado
                          _buildPersonalizedHeader(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),

                          // Widget principal de conexión emocional
                          _buildEmotionalConnectionWidget(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),

                          // Botón "Pienso en ti" rediseñado
                          _buildThoughtButton(theme, provider),
                          const SizedBox(height: AuraSpacing.l),

                          // Indicadores de estado de la relación
                          _buildRelationshipIndicators(theme, provider),
                          const SizedBox(height: AuraSpacing.xl),

                          // Cards de información contextual
                          _buildContextualCards(theme, provider),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildModernFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: AuraSpacing.s),
      ],
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
          ),
          const SizedBox(height: AuraSpacing.l),
          Text(
            'Conectando corazones...',
            style: AuraTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, MoodCompassProvider provider) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(AuraSpacing.l),
        child: Padding(
          padding: const EdgeInsets.all(AuraSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.heart_broken_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AuraSpacing.m),
              Text(
                'Conexión perdida',
                style: AuraTypography.headlineSmall.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: AuraSpacing.s),
              Text(
                provider.errorMessage ?? 'Error desconocido',
                style: AuraTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AuraSpacing.l),
              ModernButton(
                text: 'Reconectar',
                icon: Icons.refresh_rounded,
                onPressed: () {
                  provider.clearError();
                  provider.loadPartnerData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizedHeader(ThemeData theme, MoodCompassProvider provider) {
    final timeOfDay = DateTime.now().hour;
    final greeting = timeOfDay < 12 ? 'Buenos días' :
                    timeOfDay < 18 ? 'Buenas tardes' : 'Buenas noches';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AuraTypography.displaySmall.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: AuraSpacing.xs),
        ShaderMask(
          shaderCallback: (bounds) => theme.connectionGradient.createShader(bounds),
          child: Text(
            'Tu conexión está viva ✨',
            style: AuraTypography.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionalConnectionWidget(ThemeData theme, MoodCompassProvider provider) {
    return AnimatedBuilder(
      animation: Listenable.merge([_heartbeatAnimation, _connectionPulse]),
      builder: (context, child) {
        return Transform.scale(
          scale: _heartbeatAnimation.value,
          child: Card(
            elevation: 0,
            color: theme.colorScheme.surface.withValues(alpha: 0.8),
            child: Padding(
              padding: const EdgeInsets.all(AuraSpacing.xl),
              child: Column(
                children: [
                  // Auras conectadas visualmente
                  _buildConnectedAuras(theme, provider),
                  const SizedBox(height: AuraSpacing.l),

                  // Información del estado emocional
                  _buildEmotionalStatus(theme, provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnectedAuras(ThemeData theme, MoodCompassProvider provider) {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Línea de conexión animada
          AnimatedBuilder(
            animation: _connectionPulse,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 200),
                painter: ConnectionLinePainter(
                  progress: _connectionPulse.value,
                  color: theme.colorScheme.primary,
                ),
              );
            },
          ),

          // Aura del usuario (izquierda)
          Positioned(
            left: 20,
            child: _buildUserAura(theme, isPartner: false),
          ),

          // Aura de la pareja (derecha)
          Positioned(
            right: 20,
            child: _buildUserAura(theme, isPartner: true),
          ),

          // Corazón central de conexión
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: theme.intimacyGradient,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAura(ThemeData theme, {required bool isPartner}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPartner ? theme.serenityGradient : theme.energyGradient,
        boxShadow: [
          BoxShadow(
            color: (isPartner ? theme.colorScheme.tertiary : theme.colorScheme.secondary)
                .withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Icon(
        isPartner ? Icons.person_rounded : Icons.person_outline_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildEmotionalStatus(ThemeData theme, MoodCompassProvider provider) {
    // Obtener el estado actual del usuario
    final userMoodData = provider.currentData;
    final partnerMoodData = provider.partnerData;

    // Función helper para convertir coordenadas a nombre de estado de ánimo
    String getMoodNameFromCoordinates(double positivity, double energy) {
      // Buscar el estado de ánimo más cercano en el mapa
      String closestMood = 'Neutro';
      double closestDistance = double.infinity;

      for (final entry in MoodCompassProvider.moodMap.entries) {
        final distance = ((entry.value.positivity - positivity).abs() +
                        (entry.value.energy - energy).abs());
        if (distance < closestDistance) {
          closestDistance = distance;
          closestMood = entry.key;
        }
      }
      return closestMood;
    }

    // Determinar el estado del usuario
    String userStatus = 'Sin actualizar';
    IconData userIcon = Icons.psychology_rounded;
    Color userColor = theme.colorScheme.primary;

    if (userMoodData != null) {
      // Usar las coordenadas para determinar el estado de ánimo
      final moodCoords = userMoodData.mood;
      userStatus = getMoodNameFromCoordinates(moodCoords.positivity, moodCoords.energy);

      // Si hay una nota contextual, agregarla como información adicional
      if (userMoodData.contextNote.isNotEmpty) {
        userStatus = '$userStatus • ${userMoodData.contextNote}';
      }

      // Determinar ícono y color basado en el estado
      if (userStatus.contains('Feliz') || userStatus.contains('Energético') || userStatus.contains('Enérgico')) {
        userIcon = Icons.sentiment_very_satisfied_rounded;
        userColor = Colors.amber;
      } else if (userStatus.contains('Triste') || userStatus.contains('Melancólico')) {
        userIcon = Icons.sentiment_very_dissatisfied_rounded;
        userColor = Colors.blue;
      } else if (userStatus.contains('Estresado') || userStatus.contains('Ansioso')) {
        userIcon = Icons.psychology_alt_rounded;
        userColor = Colors.orange;
      } else if (userStatus.contains('Tranquilo') || userStatus.contains('Reflexivo')) {
        userIcon = Icons.spa_rounded;
        userColor = Colors.green;
      } else if (userStatus.contains('Cansado')) {
        userIcon = Icons.bedtime_rounded;
        userColor = Colors.indigo;
      } else if (userStatus.contains('Enfadado')) {
        userIcon = Icons.whatshot_rounded;
        userColor = Colors.red;
      }
    }

    // Determinar el estado de la pareja
    String partnerStatus = 'Sin conexión';
    IconData partnerIcon = Icons.person_outline_rounded;
    Color partnerColor = theme.colorScheme.tertiary;

    if (partnerMoodData != null) {
      // Usar las coordenadas para determinar el estado de ánimo de la pareja
      final moodCoords = partnerMoodData.mood;
      partnerStatus = getMoodNameFromCoordinates(moodCoords.positivity, moodCoords.energy);

      // Si hay una nota contextual, agregarla como información adicional
      if (partnerMoodData.contextNote.isNotEmpty) {
        partnerStatus = '$partnerStatus • ${partnerMoodData.contextNote}';
      }

      // Determinar ícono y color basado en el estado de la pareja
      if (partnerStatus.contains('Feliz') || partnerStatus.contains('Energético') || partnerStatus.contains('Enérgico')) {
        partnerIcon = Icons.sentiment_very_satisfied_rounded;
        partnerColor = Colors.amber;
      } else if (partnerStatus.contains('Triste') || partnerStatus.contains('Melancólico')) {
        partnerIcon = Icons.sentiment_very_dissatisfied_rounded;
        partnerColor = Colors.blue;
      } else if (partnerStatus.contains('Estresado') || partnerStatus.contains('Ansioso')) {
        partnerIcon = Icons.psychology_alt_rounded;
        partnerColor = Colors.orange;
      } else if (partnerStatus.contains('Tranquilo') || partnerStatus.contains('Reflexivo')) {
        partnerIcon = Icons.spa_rounded;
        partnerColor = Colors.green;
      } else if (partnerStatus.contains('Cansado')) {
        partnerIcon = Icons.bedtime_rounded;
        partnerColor = Colors.indigo;
      } else if (partnerStatus.contains('Enfadado')) {
        partnerIcon = Icons.whatshot_rounded;
        partnerColor = Colors.red;
      }
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            theme,
            title: 'Tu estado',
            status: userStatus,
            color: userColor,
            icon: userIcon,
            lastUpdated: userMoodData?.lastUpdated,
          ),
        ),
        const SizedBox(width: AuraSpacing.m),
        Expanded(
          child: _buildStatusCard(
            theme,
            title: 'Su estado',
            status: partnerStatus,
            color: partnerColor,
            icon: partnerIcon,
            lastUpdated: partnerMoodData?.lastUpdated,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    ThemeData theme, {
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    DateTime? lastUpdated, // Nuevo parámetro opcional
  }) {
    return Container(
      padding: const EdgeInsets.all(AuraSpacing.m),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: AuraSpacing.s),
          Text(
            title,
            style: AuraTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            status,
            style: AuraTypography.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Mostrar tiempo de última actualización si está disponible
          if (lastUpdated != null) ...[
            const SizedBox(height: AuraSpacing.xs),
            Text(
              _formatTimeAgo(lastUpdated),
              style: AuraTypography.labelSmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Método helper para formatear el tiempo transcurrido
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  Widget _buildThoughtButton(ThemeData theme, MoodCompassProvider provider) {
    return AnimatedBuilder(
      animation: _thoughtRipple,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Efecto de onda al tocar
            if (_thoughtRipple.value > 0)
              Transform.scale(
                scale: 1 + (_thoughtRipple.value * 0.5),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(
                      alpha: 0.3 * (1 - _thoughtRipple.value),
                    ),
                  ),
                ),
              ),

            // Botón principal
            GestureDetector(
              onTap: () {
                _thoughtController.forward().then((_) {
                  _thoughtController.reset();
                });
                _sendThoughtPulse();
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: theme.intimacyGradient,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: AuraSpacing.xs),
                    Text(
                      'Pienso\nen ti',
                      style: AuraTypography.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelationshipIndicators(ThemeData theme, MoodCompassProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildIndicatorChip(
            theme,
            icon: Icons.schedule_rounded,
            label: 'Última actualización',
            value: '2 min',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AuraSpacing.s),
        Expanded(
          child: _buildIndicatorChip(
            theme,
            icon: Icons.favorite_rounded,
            label: 'Conexión',
            value: 'Fuerte',
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(width: AuraSpacing.s),
        Expanded(
          child: _buildIndicatorChip(
            theme,
            icon: Icons.trending_up_rounded,
            label: 'Sincronía',
            value: '95%',
            color: theme.colorScheme.tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.m,
        vertical: AuraSpacing.s,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            label,
            style: AuraTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: AuraTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextualCards(ThemeData theme, MoodCompassProvider provider) {
    return Column(
      children: [
        // Card de actividad reciente
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.m),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: theme.energyGradient,
                  ),
                  child: Icon(
                    Icons.notification_important_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AuraSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividad reciente',
                        style: AuraTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Tu pareja acaba de actualizar su estado',
                        style: AuraTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AuraSpacing.m),

        // Card de consejos de conexión
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AuraSpacing.m),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: theme.serenityGradient,
                  ),
                  child: Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AuraSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consejo del día',
                        style: AuraTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Comparte algo que te haga sonreír hoy',
                        style: AuraTypography.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernFAB(ThemeData theme) {
    return FloatingActionButton(
      onPressed: () {
        // Navegar a la pantalla de configuración del estado
      },
      backgroundColor: theme.colorScheme.primary,
      child: const Icon(Icons.edit_rounded),
    );
  }

  void _sendThoughtPulse() {
    // Lógica para enviar el pulso de pensamiento
    print('💝 Pulso de pensamiento enviado');
  }
}

/// Painter personalizado para la línea de conexión animada
class ConnectionLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ConnectionLinePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final startX = 60.0;
    final endX = size.width - 60;
    final centerY = size.height / 2;

    // Línea curva que conecta las auras
    path.moveTo(startX, centerY);
    path.quadraticBezierTo(
      size.width / 2, centerY - 30,
      endX, centerY,
    );

    // Dibujar el path con efecto de progreso
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final extractedPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      canvas.drawPath(extractedPath, paint);
    }

    // Partículas de conexión
    if (progress > 0.5) {
      final particlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 3; i++) {
        final particleProgress = (progress - 0.5) * 2;
        final x = startX + (endX - startX) * particleProgress + (i * 20);
        final y = centerY + math.sin(progress * math.pi * 4 + i) * 10;

        canvas.drawCircle(
          Offset(x, y),
          3 * particleProgress,
          particlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
