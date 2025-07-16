import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../core/constants/app_styles.dart';
import '../widgets/dynamic_circular_indicator.dart';
import '../widgets/thought_button.dart';
import '../widgets/freshness_glow.dart';
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
  late AnimationController _enterController;
  late AnimationController _backgroundController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Controlador para animación de entrada
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controlador para fondo dinámico
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Configurar animaciones de entrada
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _enterController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Inicializar datos y animaciones
    _initializeData();
    _enterController.forward();
    _backgroundController.repeat();
  }

  /// Inicializa los datos necesarios para el Widget Aura
  Future<void> _initializeData() async {
    // Carga inicial de datos
    try {
      final provider = context.read<MoodCompassProvider>();
      
      // Cargar configuración de relación
      await provider.loadRelationshipConfig();
      
      // Cargar datos de la pareja
      await provider.loadPartnerData();
      
      // Cargar pulsos de pensamiento recientes
      await provider.loadRecentThoughtPulses();
      
    } catch (e) {
      // El error se manejará en el provider
    }
  }

  /// Maneja el refresh de los datos
  Future<void> _handleRefresh() async {
    await _initializeData();
  }

  /// Construye el fondo animado
  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryTeal.withValues(alpha: 0.08),
              ],
              stops: [
                0.0 + (_backgroundController.value * 0.3),
                0.5 + (_backgroundController.value * 0.2),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  /// Construye el estado de carga
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingWidget(),
          const SizedBox(height: 24),
          Text(
            'Conectando con tu pareja...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado sin pareja
  Widget _buildNoPartnerState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.backgroundLight,
              border: Border.all(
                color: AppColors.primaryTeal.withValues(alpha: 0.3),
                width: 2.0,
              ),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.primaryTeal.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Conecta con tu pareja',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Configura tu relación para comenzar\na compartir tu aura emocional',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navegar a configuración
              // Navigator.pushNamed(context, '/setup');
            },
            icon: const Icon(Icons.settings),
            label: const Text('Configurar relación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado de error
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 80,
            color: AppColors.error.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Error de conexión',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el estado principal del Widget Aura
  Widget _buildMainState(MoodCompassProvider provider) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // Título
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Aura de ${_getPartnerName(provider)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Indicador circular principal con frescura
              SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FreshnessGlow(
                    provider: provider,
                    child: DynamicCircularIndicator(
                      size: 200,
                      provider: provider,
                      onTap: () => _showPartnerDetails(context, provider),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Información contextual si está disponible
              if (provider.partnerMoodSnapshot != null && 
                  provider.partnerMoodSnapshot!.contextNote.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildContextNote(provider.partnerMoodSnapshot!.contextNote),
                ),
              
              const SizedBox(height: 40),
              
              // Botón "Pienso en ti"
              FadeTransition(
                opacity: _fadeAnimation,
                child: ThoughtButton(
                  provider: provider,
                  onPressed: () => _sendThoughtPulse(provider),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Pulsos recientes
              if (provider.recentPulses.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildRecentPulses(provider),
                ),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene el nombre de la pareja (placeholder)
  String _getPartnerName(MoodCompassProvider provider) {
    // En el futuro, esto vendría de los datos de usuario
    return 'tu pareja';
  }

  /// Construye la nota contextual
  Widget _buildContextNote(String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: Colors.white.withValues(alpha: 0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de pulsos recientes
  Widget _buildRecentPulses(MoodCompassProvider provider) {
    final recentPulses = provider.recentPulses.take(3).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conexiones recientes',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...recentPulses.map((pulse) => _buildPulseItem(pulse)).toList(),
      ],
    );
  }

  /// Construye un elemento de pulso individual
  Widget _buildPulseItem(ThoughtPulse pulse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Text(
            pulse.type.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pulse.type.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  pulse.timeAgo,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (pulse.isReceived && !pulse.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryAmber,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Envía un pulso de pensamiento
  Future<void> _sendThoughtPulse(MoodCompassProvider provider) async {
    try {
      await provider.sendThoughtPulse(type: ThoughtPulseType.basic);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('💭 Pulso enviado'),
            backgroundColor: AppColors.primaryTeal,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Muestra los detalles de la pareja
  void _showPartnerDetails(BuildContext context, MoodCompassProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPartnerDetailsSheet(provider),
    );
  }

  /// Construye la hoja de detalles de la pareja
  Widget _buildPartnerDetailsSheet(MoodCompassProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Estado actual
          Row(
            children: [
              Icon(
                _getStatusIcon(provider.partnerMoodSnapshot?.status ?? UserStatus.offline),
                color: _getStatusColor(provider.partnerMoodSnapshot?.status ?? UserStatus.offline),
                size: 32,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.partnerMoodSnapshot?.status.displayName ?? 'Sin estado',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Actualizado ${_getTimeAgo(provider.partnerMoodSnapshot?.lastUpdated)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Niveles de humor si están disponibles
          if (provider.partnerMoodSnapshot != null) ...[
            _buildMoodIndicator('Energía', provider.partnerMoodSnapshot!.mood.energy),
            const SizedBox(height: 12),
            _buildMoodIndicator('Positividad', provider.partnerMoodSnapshot!.mood.positivity),
            const SizedBox(height: 24),
          ],
          
          // Nota contextual
          if (provider.partnerMoodSnapshot != null && provider.partnerMoodSnapshot!.contextNote.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contexto:',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                provider.partnerMoodSnapshot!.contextNote,
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Construye un indicador de humor
  Widget _buildMoodIndicator(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (value + 1.0) / 2.0, // Convertir de -1,1 a 0,1
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            value >= 0 ? AppColors.statusAvailable : AppColors.statusBusy,
          ),
        ),
      ],
    );
  }

  /// Obtiene el tiempo transcurrido desde una fecha
  String _getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'nunca';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else {
      return 'hace ${difference.inDays}d';
    }
  }

  // Helper methods for UserStatus
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo animado
          _buildAnimatedBackground(),
          
          // Contenido principal
          Consumer<MoodCompassProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return _buildLoadingState();
              }
              
              if (provider.errorMessage != null) {
                return _buildErrorState(provider.errorMessage!);
              }
              
              if (provider.partnerMoodSnapshot == null) {
                return _buildNoPartnerState();
              }
              
              return _buildMainState(provider);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _enterController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }
}
