import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../../../shared/providers/conversation_invitation_provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';
import 'conversation_rules_screen.dart';

class ConversationInvitationScreen extends StatefulWidget {
  final String partnerUserId;
  final String partnerName;

  const ConversationInvitationScreen({
    Key? key,
    required this.partnerUserId,
    required this.partnerName,
  }) : super(key: key);

  @override
  State<ConversationInvitationScreen> createState() => _ConversationInvitationScreenState();
}

class _ConversationInvitationScreenState extends State<ConversationInvitationScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _messageController = TextEditingController();
  Map<String, dynamic>? _selectedTopic;

  final List<Map<String, dynamic>> _conversationTopics = [
    {
      'id': 'future_dreams',
      'title': 'Sueños y Metas Futuras',
      'description': 'Compartir aspiraciones y planes para el futuro juntos',
      'icon': Icons.rocket_launch_rounded,
      'color': Colors.purple,
    },
    {
      'id': 'relationship_growth',
      'title': 'Crecimiento en la Relación',
      'description': 'Hablar sobre cómo fortalecer y mejorar la conexión',
      'icon': Icons.favorite_rounded,
      'color': Colors.pink,
    },
    {
      'id': 'personal_challenges',
      'title': 'Desafíos Personales',
      'description': 'Apoyarse mutuamente en dificultades actuales',
      'icon': Icons.psychology_rounded,
      'color': Colors.indigo,
    },
    {
      'id': 'gratitude_appreciation',
      'title': 'Gratitud y Apreciación',
      'description': 'Expresar lo que más valoran el uno del otro',
      'icon': Icons.auto_awesome_rounded,
      'color': Colors.orange,
    },
    {
      'id': 'memories_experiences',
      'title': 'Recuerdos Especiales',
      'description': 'Compartir momentos favoritos y experiencias juntos',
      'icon': Icons.photo_library_rounded,
      'color': Colors.teal,
    },
    {
      'id': 'communication_styles',
      'title': 'Estilos de Comunicación',
      'description': 'Mejorar la forma en que se comunican',
      'icon': Icons.chat_bubble_rounded,
      'color': Colors.blue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Invitar a Conversación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: theme.connectionGradient,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Consumer<ConversationInvitationProvider>(
          builder: (context, provider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: 24),
                  _buildTopicSelection(theme),
                  const SizedBox(height: 24),
                  _buildMessageInput(theme),
                  const SizedBox(height: 32),
                  _buildActionButtons(theme, provider),
                  if (provider.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(theme, provider.errorMessage!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
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
                      gradient: theme.connectionGradient,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invitar a ${widget.partnerName}',
                          style: AuraTypography.headlineSmall.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Elige un tema para iniciar una conversación guiada',
                          style: AuraTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona un tema',
          style: AuraTypography.headlineSmall.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _conversationTopics.length,
          itemBuilder: (context, index) {
            final topic = _conversationTopics[index];
            final isSelected = _selectedTopic?['id'] == topic['id'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTopic = isSelected ? null : topic;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            (topic['color'] as Color).withOpacity(0.3),
                            (topic['color'] as Color).withOpacity(0.1),
                          ]
                        : [
                            theme.colorScheme.surface.withOpacity(0.8),
                            theme.colorScheme.surface.withOpacity(0.4),
                          ],
                  ),
                  border: Border.all(
                    color: isSelected
                        ? (topic['color'] as Color)
                        : theme.colorScheme.outline.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: (topic['color'] as Color).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      topic['icon'] as IconData,
                      size: 32,
                      color: isSelected
                          ? (topic['color'] as Color)
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      topic['title'] as String,
                      style: AuraTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? (topic['color'] as Color)
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic['description'] as String,
                      style: AuraTypography.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mensaje opcional',
          style: AuraTypography.bodyLarge.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escribe un mensaje personal para acompañar tu invitación...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surface.withOpacity(0.5),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ConversationInvitationProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: provider.isLoading ? 'Enviando...' : 'Enviar Invitación',
            icon: provider.isLoading ? null : Icons.send_rounded,
            onPressed: _selectedTopic != null && !provider.isLoading
                ? () => _sendInvitation(provider)
                : null,
            isLoading: provider.isLoading,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ModernButton(
            text: 'Compartir Link',
            icon: Icons.share_rounded,
            variant: ModernButtonVariant.outlined,
            onPressed: _selectedTopic != null ? _shareInvitationLink : null,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ThemeData theme, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AuraTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendInvitation(ConversationInvitationProvider provider) async {
    if (_selectedTopic == null) return;

    final success = await provider.sendInvitation(
      toUserId: widget.partnerUserId,
      toUserName: widget.partnerName,
      topic: _selectedTopic!,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
    );

    if (success && mounted) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Invitación enviada a ${widget.partnerName}!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Volver a la pantalla anterior
      Navigator.of(context).pop();
    }
  }

  void _shareInvitationLink() {
    // Por ahora solo mostrar el concepto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir Invitación'),
        content: const Text(
          'Esta funcionalidad te permitirá generar un link para compartir la invitación por WhatsApp, email u otras apps.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
