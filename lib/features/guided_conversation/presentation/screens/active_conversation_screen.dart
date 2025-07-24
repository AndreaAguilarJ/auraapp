import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/guided_conversation_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../features/guided_conversation/domain/services/accusation_detector.dart';

class ActiveConversationScreen extends StatefulWidget {
  const ActiveConversationScreen({Key? key}) : super(key: key);

  @override
  State<ActiveConversationScreen> createState() => _ActiveConversationScreenState();
}

class _ActiveConversationScreenState extends State<ActiveConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Agregar listener para actualizar el botón cuando cambie el texto
    _messageController.addListener(() {
      setState(() {}); // Forzar rebuild cuando cambie el texto
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _summaryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversación Guiada'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showEndConversationDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AuraTheme.serenityGradient,
          ),
        ),
        child: SafeArea(
          child: Consumer<GuidedConversationProvider>(
            builder: (context, provider, child) {
              final conversation = provider.currentConversation;

              if (conversation == null) {
                return const Center(
                  child: Text(
                    'No hay conversación activa',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }

              return Column(
                children: [
                  // Header con información de la conversación
                  _buildConversationHeader(conversation),

                  // Lista de mensajes/turnos
                  Expanded(
                    child: _buildConversationBody(conversation, provider),
                  ),

                  // Input area
                  _buildInputArea(provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConversationHeader(conversation) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  conversation.topic['title'] ?? 'Tema de conversación',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            conversation.topic['description'] ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${conversation.totalTurns} turnos completados',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConversationBody(conversation, GuidedConversationProvider provider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: conversation.turns.length + (provider.isMyTurn ? 0 : _needsSummary(conversation) ? 1 : 0),
      itemBuilder: (context, index) {
        // Si necesita resumen y es el último item
        if (index == conversation.turns.length && _needsSummary(conversation)) {
          return _buildSummaryRequired(conversation.turns.last, provider);
        }

        final turn = conversation.turns[index];
        final isMyMessage = provider.isMyMessage(turn.speakerId);

        return _buildTurnWidget(turn, isMyMessage);
      },
    );
  }

  Widget _buildTurnWidget(turn, bool isMyMessage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mensaje principal
          Align(
            alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMyMessage
                    ? Colors.white.withOpacity(0.9)
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Turno ${turn.turnNumber}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    turn.speakerMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Resumen del oyente si existe
          if (turn.listenerSummary != null) ...[
            const SizedBox(height: 8),
            Container(
              margin: EdgeInsets.only(
                left: isMyMessage ? 0 : 40,
                right: isMyMessage ? 40 : 0,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Resumen de escucha',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    turn.listenerSummary!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRequired(lastTurn, GuidedConversationProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.hearing,
                color: Colors.amber[700],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🎧 Turno de Escucha Activa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Antes de responder, demuestra que has comprendido el mensaje. Resume lo que entendiste con tus propias palabras:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.amber[800],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _summaryController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Lo que te escuché decir es...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : () => _submitSummary(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Validar Escucha',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(GuidedConversationProvider provider) {
    if (!provider.isMyTurn || _needsSummary(provider.currentConversation)) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            provider.isMyTurn
                ? 'Esperando que valides la escucha del último mensaje...'
                : 'Es el turno de tu pareja...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mostrar error si hay acusaciones detectadas
          if (provider.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Sugerencia de Comunicación',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.red[800]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Input de mensaje
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _messageController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                hintText: 'Comparte tus sentimientos usando "mensajes yo"...',
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
              onChanged: (text) {
                // Limpiar error cuando el usuario empiece a escribir
                if (provider.errorMessage != null) {
                  provider.clearError();
                }
                // Forzar rebuild para habilitar/deshabilitar el botón
                setState(() {});
              },
            ),
          ),
          const SizedBox(height: 12),

          // Botón de enviar - MEJORADO
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (provider.isLoading || _messageController.text.trim().isEmpty)
                  ? null
                  : () => _sendMessage(provider),
              style: ElevatedButton.styleFrom(
                backgroundColor: (_messageController.text.trim().isEmpty)
                    ? Colors.grey[400]
                    : Colors.white,
                foregroundColor: (_messageController.text.trim().isEmpty)
                    ? Colors.grey[600]
                    : AuraTheme.serenityGradient.first,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send,
                          size: 18,
                          color: (_messageController.text.trim().isEmpty)
                              ? Colors.grey[600]
                              : AuraTheme.serenityGradient.first,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _messageController.text.trim().isEmpty
                              ? 'Escribe tu mensaje...'
                              : 'Enviar Mensaje',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: (_messageController.text.trim().isEmpty)
                                ? Colors.grey[600]
                                : AuraTheme.serenityGradient.first,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          // Mostrar indicador de conectividad si hay problemas
          if (provider.errorMessage != null && provider.errorMessage!.contains('Error al enviar')) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Problema de conexión - Reintentando...',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _needsSummary(conversation) {
    if (conversation == null || conversation.turns.isEmpty) return false;
    final lastTurn = conversation.turns.last;
    return !lastTurn.isValidated;
  }

  void _sendMessage(GuidedConversationProvider provider) {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    provider.sendMessage(message).then((success) {
      if (success) {
        _messageController.clear();
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _submitSummary(GuidedConversationProvider provider) {
    final summary = _summaryController.text.trim();
    if (summary.isEmpty) return;

    provider.submitListenerSummary(summary).then((success) {
      if (success) {
        _summaryController.clear();
      }
    });
  }

  void _showEndConversationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Conversación'),
        content: const Text('¿Estás seguro de que quieres terminar esta conversación guiada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar a pantalla de resumen
              // TODO: Implementar navegación a resumen
            },
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }
}
