import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/activity_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../features/shared_space/domain/models/activity_item.dart';

/// Pantalla que muestra la actividad reciente entre la pareja
class RecentActivityScreen extends StatefulWidget {
  const RecentActivityScreen({Key? key}) : super(key: key);

  @override
  State<RecentActivityScreen> createState() => _RecentActivityScreenState();
}

class _RecentActivityScreenState extends State<RecentActivityScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeActivities();
    });
  }

  Future<void> _initializeActivities() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final activityProvider = Provider.of<ActivityProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await activityProvider.initialize(
        authProvider.currentUser!.id,
        authProvider.currentUser!.partnerId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer2<ActivityProvider, AuthProvider>(
        builder: (context, activityProvider, authProvider, child) {
          if (activityProvider.isLoading) {
            return _buildLoadingState();
          }

          if (activityProvider.errorMessage != null) {
            return _buildErrorState(activityProvider.errorMessage!);
          }

          if (activityProvider.activities.isEmpty) {
            return _buildEmptyState();
          }

          return _buildActivitiesList(activityProvider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando actividad reciente...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white70,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar actividades',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Provider.of<ActivityProvider>(context, listen: false).refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.timeline,
              color: Colors.white70,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Sin actividad reciente',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Cuando tú o tu pareja actualicen su estado\no envíen mensajes, aparecerán aquí',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<ActivityProvider>(context, listen: false).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(ActivityProvider activityProvider) {
    return RefreshIndicator(
      onRefresh: () => activityProvider.refresh(),
      color: Colors.white,
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(activityProvider),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = activityProvider.activities[index];
                return _buildActivityItem(activity, activityProvider);
              },
              childCount: activityProvider.activities.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Espacio extra para navegación
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ActivityProvider activityProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timeline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Actividad Reciente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (activityProvider.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activityProvider.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                activityProvider.isConnected ? Icons.circle : Icons.circle_outlined,
                color: activityProvider.isConnected ? Colors.green : Colors.orange,
                size: 12,
              ),
              const SizedBox(width: 8),
              Text(
                activityProvider.isConnected
                    ? 'Sincronizado'
                    : 'Reconectando...',
                style: TextStyle(
                  color: activityProvider.isConnected ? Colors.green : Colors.orange,
                  fontSize: 14,
                ),
              ),
              if (activityProvider.lastSync != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Última sync: ${_formatTime(activityProvider.lastSync!)}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          if (activityProvider.hasUnreadActivities) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => activityProvider.markAllAsRead(),
              child: const Text(
                'Marcar todo como leído',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity, ActivityProvider activityProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: activity.isRead
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: activity.isRead
              ? BorderSide.none
              : const BorderSide(color: Colors.blue, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (!activity.isRead) {
              activityProvider.markAsRead(activity.id);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono de la actividad
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getActivityColor(activity.type).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      activity.icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            activity.timeAgo,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${activity.userName} • ${activity.description}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Indicador de no leído
                if (!activity.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.moodUpdate:
        return Colors.purple;
      case ActivityType.statusChange:
        return Colors.orange;
      case ActivityType.thoughtPulse:
        return Colors.pink;
      case ActivityType.message:
        return Colors.blue;
      case ActivityType.connection:
        return Colors.green;
      case ActivityType.partnerJoined:
        return Colors.teal;
      case ActivityType.other:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}
