import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../shared/providers/conversation_invitation_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';
import '../../domain/models/conversation_invitation.dart';
import 'active_conversation_screen.dart';

class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends State<InvitationsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Cargar invitaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ConversationInvitationProvider>(context, listen: false)
          .loadInvitations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<ConversationInvitationProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildTabBar(theme, provider),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReceivedInvitations(theme, provider),
                      _buildSentInvitations(theme, provider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      title: const Text('Invitaciones'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: theme.connectionGradient,
        ),
      ),
      actions: [
        Consumer<ConversationInvitationProvider>(
          builder: (context, provider, child) {
            if (provider.pendingCount > 0) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => _tabController.animateTo(0),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${provider.pendingCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme, ConversationInvitationProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: theme.colorScheme.surface.withOpacity(0.8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: theme.connectionGradient,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_rounded, size: 18),
                const SizedBox(width: 8),
                Text('Recibidas'),
                if (provider.pendingCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${provider.pendingCount}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_rounded, size: 18),
                SizedBox(width: 8),
                Text('Enviadas'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceivedInvitations(ThemeData theme, ConversationInvitationProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState(theme);
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(theme, provider);
    }

    if (provider.pendingInvitations.isEmpty) {
      return _buildEmptyState(
        theme,
        icon: Icons.inbox_rounded,
        title: 'No tienes invitaciones',
        subtitle: 'Cuando alguien te invite a una conversación guiada, aparecerá aquí.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = provider.pendingInvitations[index];
        return _buildInvitationCard(theme, invitation, provider, true);
      },
    );
  }

  Widget _buildSentInvitations(ThemeData theme, ConversationInvitationProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState(theme);
    }

    if (provider.sentInvitations.isEmpty) {
      return _buildEmptyState(
        theme,
        icon: Icons.send_rounded,
        title: 'No has enviado invitaciones',
        subtitle: 'Invita a tu pareja a conversaciones guiadas para fortalecer su conexión.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.sentInvitations.length,
      itemBuilder: (context, index) {
        final invitation = provider.sentInvitations[index];
        return _buildInvitationCard(theme, invitation, provider, false);
      },
    );
  }

  Widget _buildInvitationCard(
    ThemeData theme,
    ConversationInvitation invitation,
    ConversationInvitationProvider provider,
    bool isReceived,
  ) {
    final statusColor = _getStatusColor(theme, invitation.status);
    final statusIcon = _getStatusIcon(invitation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            statusColor.withOpacity(0.1),
            statusColor.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInvitationHeader(theme, invitation, statusIcon, statusColor, isReceived),
                const SizedBox(height: 16),
                _buildInvitationContent(theme, invitation),
                if (invitation.message != null && invitation.message!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInvitationMessage(theme, invitation.message!),
                ],
                const SizedBox(height: 16),
                _buildInvitationFooter(theme, invitation, provider, isReceived),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvitationHeader(
    ThemeData theme,
    ConversationInvitation invitation,
    IconData statusIcon,
    Color statusColor,
    bool isReceived,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isReceived
                    ? 'De: ${invitation.fromUserName}'
                    : 'Para: ${invitation.toUserName}',
                style: AuraTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                _getStatusText(invitation.status),
                style: AuraTypography.bodySmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          _getTimeAgo(invitation.createdAt),
          style: AuraTypography.labelSmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInvitationContent(ThemeData theme, ConversationInvitation invitation) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  invitation.topicTitle,
                  style: AuraTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (invitation.topicDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              invitation.topicDescription,
              style: AuraTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvitationMessage(ThemeData theme, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: theme.colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AuraTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationFooter(
    ThemeData theme,
    ConversationInvitation invitation,
    ConversationInvitationProvider provider,
    bool isReceived,
  ) {
    if (isReceived && invitation.canRespond) {
      return Row(
        children: [
          Expanded(
            child: ModernButton(
              text: 'Rechazar',
              icon: Icons.close_rounded,
              variant: ModernButtonVariant.outlined,
              onPressed: () => _showRejectDialog(invitation, provider),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ModernButton(
              text: 'Aceptar',
              icon: Icons.check_rounded,
              onPressed: () => _acceptInvitation(invitation, provider),
            ),
          ),
        ],
      );
    }

    // Mostrar información adicional según el estado
    String infoText = '';
    IconData infoIcon = Icons.info_outline;

    switch (invitation.status) {
      case 'accepted':
        infoText = 'Invitación aceptada';
        infoIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        infoText = 'Invitación rechazada';
        infoIcon = Icons.cancel_outlined;
        break;
      case 'expired':
        infoText = 'Invitación expirada';
        infoIcon = Icons.access_time_rounded;
        break;
      default:
        if (!isReceived) {
          infoText = 'Esperando respuesta...';
          infoIcon = Icons.schedule_rounded;
        }
    }

    if (infoText.isNotEmpty) {
      return Row(
        children: [
          Icon(infoIcon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            infoText,
            style: AuraTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState(ThemeData theme) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(ThemeData theme, ConversationInvitationProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar invitaciones',
            style: AuraTypography.headlineSmall.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Error desconocido',
            style: AuraTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ModernButton(
            text: 'Reintentar',
            icon: Icons.refresh_rounded,
            onPressed: () => provider.loadInvitations(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
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
            child: Icon(
              icon,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: AuraTypography.headlineSmall.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              style: AuraTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _acceptInvitation(ConversationInvitation invitation, ConversationInvitationProvider provider) async {
    final success = await provider.acceptInvitation(invitation);
    if (success && mounted) {
      // Navegar a la conversación
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ActiveConversationScreen(
            conversationId: invitation.id!,
          ),
        ),
      );
    }
  }

  void _showRejectDialog(ConversationInvitation invitation, ConversationInvitationProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar invitación'),
        content: const Text('¿Estás seguro de que quieres rechazar esta invitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await provider.rejectInvitation(invitation);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      case 'expired':
        return Icons.access_time_rounded;
      default:
        return Icons.chat_bubble_rounded;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'accepted':
        return 'Aceptada';
      case 'rejected':
        return 'Rechazada';
      case 'expired':
        return 'Expirada';
      default:
        return 'Desconocido';
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
