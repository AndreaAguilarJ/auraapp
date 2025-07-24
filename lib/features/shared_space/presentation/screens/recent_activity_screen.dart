import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui';
import '../../../../shared/providers/activity_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../features/shared_space/domain/models/activity_item.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla ultra-moderna de actividad reciente con efectos visuales avanzados
class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({Key? key}) : super(key: key);

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatingAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores de animación
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOutSine,
    ));

    // Iniciar animaciones
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _floatingController.repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeActivities();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _initializeActivities() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      final userId = authProvider.currentUser!.id;
      final partnerId = authProvider.currentUser!.partnerId;

      await activityProvider.initialize(userId, partnerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo con gradiente dinámico
          _buildDynamicBackground(theme, size),
          // Partículas flotantes
          _buildFloatingParticles(theme, size),
          // Contenido principal
          Consumer2<ActivityProvider, AuthProvider>(
            builder: (context, activityProvider, authProvider, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(theme, activityProvider),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBackground(ThemeData theme, Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _floatingAnimation]),
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.2 + (_pulseAnimation.value * 0.2),
              colors: [
                theme.colorScheme.secondary.withValues(alpha: 0.08),
                theme.colorScheme.tertiary.withValues(alpha: 0.04),
                theme.colorScheme.primary.withValues(alpha: 0.02),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: ActivityBackgroundPainter(
              animation: _floatingAnimation.value,
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
      animation: _shimmerAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ActivityParticlesPainter(
            animation: _shimmerAnimation.value,
            theme: theme,
          ),
          size: size,
        );
      },
    );
  }

  Widget _buildContent(ThemeData theme, ActivityProvider activityProvider) {
    if (activityProvider.isLoading) {
      return _buildUltraModernLoadingState(theme);
    }

    if (activityProvider.errorMessage != null) {
      return _buildModernErrorState(theme, activityProvider);
    }

    if (activityProvider.activities.isEmpty) {
      return _buildModernEmptyState(theme);
    }

    return _buildModernActivitiesList(theme, activityProvider);
  }

  Widget _buildUltraModernLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Indicador de carga glassmorphism
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.secondary.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                          strokeWidth: 3,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AuraSpacing.xl),
          ShaderMask(
            shaderCallback: (bounds) => theme.connectionGradient.createShader(bounds),
            child: Text(
              'Sincronizando momentos...',
              style: AuraTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AuraSpacing.s),
          Text(
            'Recuperando la historia de vuestra conexión',
            style: AuraTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernErrorState(ThemeData theme, ActivityProvider activityProvider) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AuraSpacing.l),
        padding: const EdgeInsets.all(AuraSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.errorContainer.withOpacity(0.3),
              theme.colorScheme.error.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.error,
                        theme.colorScheme.error.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AuraSpacing.l),
                Text(
                  'Conexión interrumpida',
                  style: AuraTypography.headlineSmall.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AuraSpacing.s),
                Text(
                  activityProvider.errorMessage ?? 'Error desconocido',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AuraSpacing.l),
                ModernButton(
                  text: 'Reconectar',
                  icon: Icons.refresh_rounded,
                  onPressed: () => activityProvider.refresh(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: theme.serenityGradient,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AuraSpacing.xl),
          ShaderMask(
            shaderCallback: (bounds) => theme.connectionGradient.createShader(bounds),
            child: Text(
              'Vuestra historia comienza aquí',
              style: AuraTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AuraSpacing.m),
          Text(
            'Cada momento compartido se convertirá en un recuerdo especial.\nComenzad a crear vuestra timeline emocional.',
            style: AuraTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernActivitiesList(ThemeData theme, ActivityProvider activityProvider) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header con estadísticas
        SliverToBoxAdapter(
          child: _buildActivityHeader(theme, activityProvider),
        ),

        // Lista de actividades
        SliverList.builder(
          itemCount: activityProvider.activities.length,
          itemBuilder: (context, index) {
            final activity = activityProvider.activities[index];
            return _buildModernActivityItem(theme, activity, index);
          },
        ),

        // Espaciado final
        const SliverToBoxAdapter(
          child: SizedBox(height: AuraSpacing.xl),
        ),
      ],
    );
  }

  Widget _buildActivityHeader(ThemeData theme, ActivityProvider activityProvider) {
    return Container(
      margin: const EdgeInsets.all(AuraSpacing.l),
      padding: const EdgeInsets.all(AuraSpacing.l),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: theme.energyGradient,
                    ),
                    child: const Icon(
                      Icons.timeline_rounded,
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
                          'Timeline Emocional',
                          style: AuraTypography.headlineSmall.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${activityProvider.activities.length} momentos compartidos',
                          style: AuraTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.m),

              // Estadísticas rápidas
              Row(
                children: [
                  Expanded(child: _buildStatChip(theme, Icons.favorite_rounded, 'Conexiones', '${activityProvider.activities.length}')),
                  const SizedBox(width: AuraSpacing.s),
                  Expanded(child: _buildStatChip(theme, Icons.schedule_rounded, 'Hoy', '3')),
                  const SizedBox(width: AuraSpacing.s),
                  Expanded(child: _buildStatChip(theme, Icons.trending_up_rounded, 'Tendencia', '+12%')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(ThemeData theme, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AuraSpacing.s,
        vertical: AuraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            value,
            style: AuraTypography.labelMedium.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AuraTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActivityItem(ThemeData theme, ActivityItem activity, int index) {
    // Delay para animación escalonada
    final delay = Duration(milliseconds: 100 * index);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 400 + (index * 50)),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutBack,
          builder: (context, animValue, child) {
            return Transform.translate(
              offset: Offset(50 * (1 - animValue), 0),
              child: Opacity(
                opacity: animValue.clamp(0.0, 1.0),
                child: Container(
                  margin: EdgeInsets.only(
                    left: AuraSpacing.l,
                    right: AuraSpacing.l,
                    bottom: AuraSpacing.m,
                  ),
                  child: _buildActivityCard(theme, activity),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityCard(ThemeData theme, ActivityItem activity) {
    final activityIcon = _getActivityIcon(activity.type.toString());
    final activityColor = _getActivityColor(theme, activity.type.toString());
    final timeAgo = _getTimeAgo(activity.timestamp);

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.m),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            activityColor.withOpacity(0.1),
            activityColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: activityColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: activityColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              // Ícono de actividad
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      activityColor,
                      activityColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activityColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  activityIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AuraSpacing.m),

              // Contenido de la actividad
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: AuraTypography.bodyLarge.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: AuraTypography.labelSmall.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AuraSpacing.xs),
                    Text(
                      activity.description,
                      style: AuraTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Metadata adicional
                    if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
                      const SizedBox(height: AuraSpacing.s),
                      _buildActivityMetadata(theme, activity.metadata!),
                    ],
                  ],
                ),
              ),

              // Indicador de estado
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activityColor,
                  boxShadow: [
                    BoxShadow(
                      color: activityColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityMetadata(ThemeData theme, Map<String, dynamic> metadata) {
    return Wrap(
      spacing: AuraSpacing.xs,
      runSpacing: AuraSpacing.xs,
      children: metadata.entries.take(3).map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.s,
            vertical: AuraSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: AuraTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _getActivityIcon(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'mood_update':
      case 'activitytype.mood_update':
        return Icons.psychology_rounded;
      case 'thought_pulse':
      case 'activitytype.thought_pulse':
        return Icons.favorite_rounded;
      case 'connection':
      case 'activitytype.connection':
        return Icons.link_rounded;
      case 'message':
      case 'activitytype.message':
        return Icons.chat_bubble_rounded;
      case 'photo':
      case 'activitytype.photo':
        return Icons.photo_camera_rounded;
      case 'location':
      case 'activitytype.location':
        return Icons.location_on_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }

  Color _getActivityColor(ThemeData theme, String activityType) {
    switch (activityType.toLowerCase()) {
      case 'mood_update':
      case 'activitytype.mood_update':
        return theme.colorScheme.primary;
      case 'thought_pulse':
      case 'activitytype.thought_pulse':
        return Colors.pink;
      case 'connection':
      case 'activitytype.connection':
        return theme.colorScheme.secondary;
      case 'message':
      case 'activitytype.message':
        return Colors.blue;
      case 'photo':
      case 'activitytype.photo':
        return Colors.purple;
      case 'location':
      case 'activitytype.location':
        return Colors.green;
      default:
        return theme.colorScheme.tertiary;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}sem';
    }
  }
}

/// Painter personalizado para el fondo de actividades
class ActivityBackgroundPainter extends CustomPainter {
  final double animation;
  final ThemeData theme;

  ActivityBackgroundPainter({
    required this.animation,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Crear ondas sutiles en el fondo
    final paint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveOffset = animation * 150 + i * 80;

      path.moveTo(0, size.height * 0.3 + i * size.height * 0.2);

      for (double x = 0; x <= size.width; x += 15) {
        final y = (size.height * 0.3 + i * size.height * 0.2) +
                  math.sin((x + waveOffset) * 0.008) * 20;
        path.lineTo(x, y);
      }

      canvas.drawPath(path, paint);
    }

    // Añadir círculos flotantes
    final circlePaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = (size.width * 0.1) + (i * size.width * 0.12);
      final y = size.height * 0.2 +
                math.sin(animation + i * 0.5) * size.height * 0.3;
      final radius = 8 + math.sin(animation * 2 + i) * 4;

      canvas.drawCircle(Offset(x, y), radius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(ActivityBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Painter personalizado para partículas de actividad
class ActivityParticlesPainter extends CustomPainter {
  final double animation;
  final ThemeData theme;
  late final List<ActivityParticle> particles;

  ActivityParticlesPainter({
    required this.animation,
    required this.theme,
  }) {
    particles = _generateParticles();
  }

  List<ActivityParticle> _generateParticles() {
    final particleList = <ActivityParticle>[];
    final random = math.Random(123); // Seed fijo

    for (int i = 0; i < 30; i++) {
      particleList.add(ActivityParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1 + random.nextDouble() * 2,
        speed: 0.05 + random.nextDouble() * 0.15,
        opacity: 0.2 + random.nextDouble() * 0.4,
        phase: random.nextDouble() * math.pi * 2,
        color: i % 4 == 0
            ? theme.colorScheme.primary
            : i % 4 == 1
                ? theme.colorScheme.secondary
                : i % 4 == 2
                    ? theme.colorScheme.tertiary
                    : Colors.pink,
      ));
    }
    return particleList;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Clamp opacity to valid range to prevent assertion errors
      final calculatedOpacity = particle.opacity * (0.6 + 0.4 * math.sin(animation * math.pi + particle.phase));
      final clampedOpacity = math.max(0.0, math.min(1.0, calculatedOpacity));

      final paint = Paint()
        ..color = particle.color.withOpacity(clampedOpacity)
        ..style = PaintingStyle.fill;

      final x = (particle.x + animation * particle.speed) % 1.0 * size.width;
      final y = (particle.y + animation * particle.speed * 0.3) % 1.0 * size.height;

      // Efecto de pulsación
      final pulseScale = 1.0 + 0.2 * math.sin(animation * math.pi * 3 + particle.phase);

      canvas.drawCircle(
        Offset(x, y),
        particle.size * pulseScale,
        paint,
      );

      // Estela sutil
      if (particle.size > 1.5) {
        final trailPaint = Paint()
          ..color = particle.color.withOpacity(particle.opacity * 0.2)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x - 3, y - 2),
          particle.size * 0.4 * pulseScale,
          trailPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ActivityParticlesPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

class ActivityParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double phase;
  final Color color;

  ActivityParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
    required this.color,
  });
}
