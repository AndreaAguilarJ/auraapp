import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui'; // For Flutter's Size type
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla ultra-moderna del Widget Aura con diseño futurista
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
  late AnimationController _particleController;
  late AnimationController _breathingController;
  late AnimationController _floatingController;

  late Animation<double> _heartbeatAnimation;
  late Animation<double> _connectionPulse;
  late Animation<double> _thoughtRipple;
  late Animation<double> _particleAnimation;
  late Animation<double> _breathingScale;
  late Animation<double> _floatingOffset;

  @override
  void initState() {
    super.initState();

    // Animación de latido del corazón más suave
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animación de conexión entre las auras más fluida
    _connectionController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Animación para el botón "Pienso en ti"
    _thoughtController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Nueva animación de partículas flotantes
    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Animación de respiración para los elementos
    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Animación de flotación suave
    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _heartbeatAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _heartbeatController,
      curve: Curves.easeInOutSine,
    ));

    _connectionPulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionController,
      curve: Curves.easeInOutCubic,
    ));

    _thoughtRipple = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _thoughtController,
      curve: Curves.elasticOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _breathingScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOutSine,
    ));

    _floatingOffset = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    // Iniciar animaciones
    _heartbeatController.repeat(reverse: true);
    _connectionController.repeat();
    _particleController.repeat();
    _breathingController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _connectionController.dispose();
    _thoughtController.dispose();
    _particleController.dispose();
    _breathingController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildModernAppBar(theme),
      body: Stack(
        children: [
          // Fondo con gradiente dinámico
          _buildDynamicBackground(theme, size),
          // Partículas flotantes
          _buildFloatingParticles(theme, size),
          // Contenido principal
          Consumer<MoodCompassProvider>(
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
                            // Header ultra-moderno
                            _buildUltraModernHeader(theme, provider),
                            const SizedBox(height: AuraSpacing.xl),

                            // Widget principal rediseñado
                            _buildUltraModernConnectionWidget(theme, provider),
                            const SizedBox(height: AuraSpacing.xl),

                            // Botón futurista "Pienso en ti"
                            _buildFuturisticThoughtButton(theme, provider),
                            const SizedBox(height: AuraSpacing.l),

                            // Indicadores de estado modernos
                            _buildModernRelationshipIndicators(theme, provider),
                            const SizedBox(height: AuraSpacing.xl),

                            // Cards glassmorphism
                            _buildGlassmorphismCards(theme, provider),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: _buildUltraModernFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildDynamicBackground(ThemeData theme, Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_connectionPulse, _breathingScale]),
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.5 + (_connectionPulse.value * 0.3),
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
                theme.colorScheme.tertiary.withOpacity(0.02),
                theme.colorScheme.surface,
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: MeshGradientPainter(
              animation: _connectionPulse.value,
              theme: theme,
            ),
            size: size,
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles(ThemeData theme, Size size) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticleSystemPainter(
            animation: _particleAnimation.value,
            theme: theme,
          ),
          size: size,
        );
      },
    );
  }

  PreferredSizeWidget _buildModernAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.surface.withOpacity(0.8),
                  theme.colorScheme.surface.withOpacity(0.6),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface.withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.tune_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
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

  Widget _buildUltraModernHeader(ThemeData theme, MoodCompassProvider provider) {
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

  Widget _buildUltraModernConnectionWidget(ThemeData theme, MoodCompassProvider provider) {
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

  Widget _buildFuturisticThoughtButton(ThemeData theme, MoodCompassProvider provider) {
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

  Widget _buildModernRelationshipIndicators(ThemeData theme, MoodCompassProvider provider) {
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

  Widget _buildGlassmorphismCards(ThemeData theme, MoodCompassProvider provider) {
    return Column(
      children: [
        // Card de actividad reciente
        _buildGlassmorphismCard(
          theme,
          title: 'Actividad reciente',
          description: 'Tu pareja acaba de actualizar su estado',
          icon: Icons.notification_important_rounded,
          gradient: theme.energyGradient,
        ),
        const SizedBox(height: AuraSpacing.m),

        // Card de consejos de conexión
        _buildGlassmorphismCard(
          theme,
          title: 'Consejo del día',
          description: 'Comparte algo que te haga sonreír hoy',
          icon: Icons.lightbulb_rounded,
          gradient: theme.serenityGradient,
        ),
      ],
    );
  }

  Widget _buildGlassmorphismCard(
    ThemeData theme, {
    required String title,
    required String description,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AuraSpacing.m),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gradient,
                  ),
                  child: Icon(
                    icon,
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
                        title,
                        style: AuraTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        description,
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
      ),
    );
  }

  Widget _buildUltraModernFAB(ThemeData theme) {
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

/// Painter personalizado para el sistema de partículas
class ParticleSystemPainter extends CustomPainter {
  final double animation;
  final ThemeData theme;
  late final List<Particle> particles;

  ParticleSystemPainter({
    required this.animation,
    required this.theme,
  }) {
    particles = _generateParticles();
  }

  List<Particle> _generateParticles() {
    final particleList = <Particle>[];
    final random = math.Random(42); // Seed fijo para consistencia

    for (int i = 0; i < 50; i++) {
      particleList.add(Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 3,
        speed: 0.1 + random.nextDouble() * 0.3,
        opacity: 0.3 + random.nextDouble() * 0.7,
        color: i % 3 == 0
            ? theme.colorScheme.primary
            : i % 3 == 1
                ? theme.colorScheme.secondary
                : theme.colorScheme.tertiary,
      ));
    }
    return particleList;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(
          particle.opacity * (0.5 + 0.5 * math.sin(animation * math.pi * 2))
        )
        ..style = PaintingStyle.fill;

      final x = (particle.x + animation * particle.speed) % 1.0 * size.width;
      final y = (particle.y + animation * particle.speed * 0.5) % 1.0 * size.height;

      // Efecto de respiración en las partículas
      final breathScale = 1.0 + 0.3 * math.sin(animation * math.pi * 4 + particle.x * 10);

      canvas.drawCircle(
        Offset(x, y),
        particle.size * breathScale,
        paint,
      );

      // Estela de la partícula
      if (particle.size > 2) {
        final trailPaint = Paint()
          ..color = particle.color.withOpacity(particle.opacity * 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x - 5, y - 5),
          particle.size * 0.5 * breathScale,
          trailPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ParticleSystemPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });
}

/// Painter mejorado para el gradiente de malla con efectos dinámicos
class MeshGradientPainter extends CustomPainter {
  final double animation;
  final ThemeData theme;

  MeshGradientPainter({
    required this.animation,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear múltiples gradientes que se mueven
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          -0.5 + math.sin(animation * math.pi) * 0.3,
          -0.5 + math.cos(animation * math.pi * 0.7) * 0.3,
        ),
        radius: 0.8 + math.sin(animation * math.pi * 2) * 0.2,
        colors: [
          theme.colorScheme.primary.withOpacity(0.15),
          theme.colorScheme.primary.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          0.5 + math.cos(animation * math.pi * 1.3) * 0.4,
          0.5 + math.sin(animation * math.pi * 0.9) * 0.4,
        ),
        radius: 0.6 + math.cos(animation * math.pi * 1.5) * 0.2,
        colors: [
          theme.colorScheme.secondary.withOpacity(0.12),
          theme.colorScheme.secondary.withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final paint3 = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          math.sin(animation * math.pi * 0.8) * 0.5,
          math.cos(animation * math.pi * 1.2) * 0.5,
        ),
        radius: 0.9 + math.sin(animation * math.pi * 1.8) * 0.1,
        colors: [
          theme.colorScheme.tertiary.withOpacity(0.1),
          theme.colorScheme.tertiary.withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Dibujar los gradientes superpuestos
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);

    // Añadir ondas sutiles
    final wavePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final waveOffset = animation * 200 + i * 50;

      path.moveTo(0, size.height / 2);
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height / 2 +
                  math.sin((x + waveOffset) * 0.01) * 30 * (i + 1) * 0.2;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(MeshGradientPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
