import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/guided_conversation_provider.dart';
import '../../../../shared/theme/app_theme.dart';

class ConversationSummaryScreen extends StatefulWidget {
  const ConversationSummaryScreen({Key? key}) : super(key: key);

  @override
  State<ConversationSummaryScreen> createState() => _ConversationSummaryScreenState();
}

class _ConversationSummaryScreenState extends State<ConversationSummaryScreen> {
  final TextEditingController _keyPointsController = TextEditingController();
  final TextEditingController _commitmentsController = TextEditingController();
  final TextEditingController _nextStepsController = TextEditingController();

  @override
  void dispose() {
    _keyPointsController.dispose();
    _commitmentsController.dispose();
    _nextStepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Conversación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AuraTheme.connectionGradient,
          ),
        ),
        child: SafeArea(
          child: Consumer<GuidedConversationProvider>(
            builder: (context, provider, child) {
              final conversation = provider.currentConversation;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header celebratorio
                    _buildCelebrationHeader(),
                    const SizedBox(height: 32),

                    // Resumen de la conversación
                    if (conversation != null) ...[
                      _buildConversationOverview(conversation),
                      const SizedBox(height: 24),
                    ],

                    // Formulario de resumen final
                    _buildSummaryForm(),
                    const SizedBox(height: 32),

                    // Botones de acción
                    _buildActionButtons(provider),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.celebration,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            '¡Felicidades!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Habéis completado vuestra conversación guiada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '💫 Habéis dado un paso importante hacia mejor comunicación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationOverview(conversation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Resumen de la Sesión',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Estadísticas
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tema',
                  conversation.topic['title'] ?? 'Sin tema',
                  Icons.topic,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Turnos',
                  '${conversation.totalTurns}',
                  Icons.chat_bubble_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _buildStatCard(
            'Duración aproximada',
            '${conversation.totalTurns * 3} - ${conversation.totalTurns * 6} minutos',
            Icons.schedule,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Completad juntos este resumen:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),

        // Puntos clave
        _buildFormField(
          'Puntos clave de la conversación',
          'Ejemplo: Necesitamos más tiempo de calidad juntos...',
          _keyPointsController,
          Icons.key,
        ),
        const SizedBox(height: 16),

        // Compromisos
        _buildFormField(
          'Compromisos que hacemos',
          'Ejemplo: Planificar una cita semanal sin distracciones...',
          _commitmentsController,
          Icons.handshake,
        ),
        const SizedBox(height: 16),

        // Próximos pasos
        _buildFormField(
          'Próximos pasos',
          'Ejemplo: Revisar estos acuerdos en una semana...',
          _nextStepsController,
          Icons.arrow_forward,
        ),
      ],
    );
  }

  Widget _buildFormField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(GuidedConversationProvider provider) {
    return Column(
      children: [
        // Botón principal - Finalizar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: provider.isLoading ? null : _finishConversation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AuraTheme.connectionGradient.first,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: provider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Finalizar y Guardar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón secundario - Continuar conversación
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continuar Conversación',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Mensaje de motivación
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                'Cada conversación os acerca más.\nSeguid practicando la escucha activa en vuestro día a día.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _finishConversation() {
    final provider = Provider.of<GuidedConversationProvider>(context, listen: false);

    // Obtener los textos del formulario
    final keyPointsList = _keyPointsController.text.trim().split('\n')
        .where((point) => point.trim().isNotEmpty)
        .toList();

    final commitmentsList = _commitmentsController.text.trim().split('\n')
        .where((commitment) => commitment.trim().isNotEmpty)
        .toList();

    final nextSteps = _nextStepsController.text.trim();

    provider.endConversation(
      keyPoints: keyPointsList.isEmpty ? null : keyPointsList,
      commitments: commitmentsList.isEmpty ? null : commitmentsList,
      nextSteps: nextSteps.isEmpty ? null : nextSteps,
    ).then((_) {
      // Mostrar mensaje de éxito y navegar de vuelta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Conversación guardada exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar de vuelta al inicio
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }
}
