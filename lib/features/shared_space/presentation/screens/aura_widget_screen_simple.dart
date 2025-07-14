import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../core/constants/app_styles.dart';
import '../widgets/simple_thought_button.dart';
import '../../domain/models/thought_pulse.dart';
import '../../domain/models/user_status.dart';

/// Pantalla principal que integra todos los componentes del Widget Aura
class AuraWidgetScreen extends StatefulWidget {
  const AuraWidgetScreen({Key? key}) : super(key: key);

  @override
  State<AuraWidgetScreen> createState() => _AuraWidgetScreenState();
}

class _AuraWidgetScreenState extends State<AuraWidgetScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Widget Aura'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<MoodCompassProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: AppTypography.bodyMStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.loadPartnerData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              children: [
                // Widget principal de conexión
                _buildConnectionWidget(provider),
                const SizedBox(height: AppSpacing.l),
                
                // Botón de pulso de pensamiento
                _buildThoughtPulseButton(provider),
                const SizedBox(height: AppSpacing.l),
                
                // Estado de la pareja
                if (provider.partnerMoodSnapshot != null) 
                  _buildPartnerStatus(provider),
                const SizedBox(height: AppSpacing.l),
                
                // Pulsos recientes
                _buildRecentPulses(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildConnectionWidget(MoodCompassProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryTeal.withValues(alpha: 0.1),
            AppColors.primaryViolet.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(
          color: AppColors.primaryTeal.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // Indicador de conexión
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: provider.isConnected ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        provider.isConnected 
                            ? AppColors.primaryTeal
                            : AppColors.textSecondary,
                        provider.isConnected 
                            ? AppColors.primaryTeal.withValues(alpha: 0.3)
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isConnected 
                            ? AppColors.primaryTeal
                            : AppColors.textSecondary).withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    provider.isConnected ? Icons.favorite : Icons.favorite_border,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            provider.isConnected ? 'Conectado' : 'Sin conexión',
            style: AppTypography.headingSStyle.copyWith(
              color: provider.isConnected 
                  ? AppColors.primaryTeal 
                  : AppColors.textSecondary,
            ),
          ),
          if (provider.lastConnection != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Última conexión: ${_formatTime(provider.lastConnection!)}',
              style: AppTypography.bodySStyle,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThoughtPulseButton(MoodCompassProvider provider) {
    return SimpleThoughtButton(
      provider: provider,
      onPressed: provider.canSendPulse 
          ? () => _sendThoughtPulse(provider)
          : null,
    );
  }

  Widget _buildPartnerStatus(MoodCompassProvider provider) {
    final snapshot = provider.partnerMoodSnapshot!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  getStatusIcon(snapshot.status),
                  color: getStatusColor(snapshot.status),
                  size: 32,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu pareja',
                        style: AppTypography.bodySStyle,
                      ),
                      Text(
                        snapshot.status.displayName,
                        style: AppTypography.headingSStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (snapshot.contextNote.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.m),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Text(
                  '"${snapshot.contextNote}"',
                  style: AppTypography.bodyMStyle.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPulses(MoodCompassProvider provider) {
    final pulses = provider.recentPulses.take(5).toList();
    
    if (pulses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'No hay pulsos recientes',
                  style: AppTypography.bodyMStyle.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pulsos recientes',
              style: AppTypography.headingSStyle,
            ),
            const SizedBox(height: AppSpacing.m),
            ...pulses.map((pulse) => _buildPulseItem(pulse)),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseItem(ThoughtPulse pulse) {
    final isFromMe = pulse.fromUserId == context.read<MoodCompassProvider>().currentMoodSnapshot?.userId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: isFromMe 
            ? AppColors.primaryTeal.withValues(alpha: 0.1)
            : AppColors.primaryViolet.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Row(
        children: [
          Text(
            pulse.type.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFromMe ? 'Tú' : 'Tu pareja',
                  style: AppTypography.bodySStyle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  pulse.type.displayName,
                  style: AppTypography.bodySStyle,
                ),
              ],
            ),
          ),
          Text(
            _formatTime(pulse.timestamp),
            style: AppTypography.bodySStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendThoughtPulse(MoodCompassProvider provider) async {
    await provider.sendThoughtPulse(
      type: ThoughtPulseType.basic,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pulso enviado! 💖'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}

// Helper functions for UserStatus icon and color
IconData getStatusIcon(UserStatus status) {
  switch (status.value) {
    case 'available':
      return Icons.check_circle;
    case 'busy':
      return Icons.work;
    case 'resting':
      return Icons.bedtime;
    case 'traveling':
      return Icons.airplanemode_active;
    case 'offline':
      return Icons.cloud_off;
    default:
      return Icons.person;
  }
}

Color getStatusColor(UserStatus status) {
  switch (status.value) {
    case 'available':
      return AppColors.statusAvailable;
    case 'busy':
      return AppColors.statusBusy;
    case 'resting':
      return AppColors.statusResting;
    case 'traveling':
      return AppColors.statusTraveling;
    case 'offline':
      return AppColors.statusOffline;
    default:
      return AppColors.statusAvailable;
  }
}
