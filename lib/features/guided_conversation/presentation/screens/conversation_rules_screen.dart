import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import 'active_conversation_screen.dart';

class ConversationRulesScreen extends StatelessWidget {
  final Map<String, dynamic> selectedTopic;
  final String partnerName;

  const ConversationRulesScreen({
    Key? key,
    required this.selectedTopic,
    required this.partnerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reglas de Conversación'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 32),

                // Reglas
                Expanded(
                  child: _buildRules(),
                ),

                // Botones de acción
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '🌱 Reglas de la Conversación Guiada',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.topic, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tema: ${selectedTopic['title']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRules() {
    final rules = [
      {
        'icon': Icons.schedule,
        'title': 'Turnos de 3 minutos máximo',
        'description': 'Cada persona tiene máximo 3 minutos para expresar sus sentimientos sin interrupciones.',
        'color': Colors.blue,
      },
      {
        'icon': Icons.hearing,
        'title': 'Escucha activa obligatoria',
        'description': 'Quien escucha DEBE resumir lo que entendió antes de poder responder.',
        'color': Colors.green,
      },
      {
        'icon': Icons.favorite,
        'title': 'Usa "mensajes yo"',
        'description': 'Expresa tus sentimientos diciendo "Yo me siento..." en lugar de acusaciones.',
        'color': Colors.pink,
      },
      {
        'icon': Icons.block,
        'title': 'No interrumpir',
        'description': 'Respeta el turno de la otra persona. La app te avisará cuando sea tu momento.',
        'color': Colors.orange,
      },
      {
        'icon': Icons.handshake,
        'title': 'Buscar entendimiento',
        'description': 'El objetivo es conectar y comprenderse, no ganar la discusión.',
        'color': Colors.purple,
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Para crear un espacio seguro y constructivo:',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ...rules.map((rule) => _buildRuleCard(rule)).toList(),
        ],
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (rule['color'] as Color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (rule['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              rule['icon'],
              color: rule['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rule['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Recordatorio importante
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber[300], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recordad: El objetivo es conectar y comprenderos mejor.',
                  style: TextStyle(
                    color: Colors.amber[100],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botones
        Row(
          children: [
            Expanded(
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
                  'Volver',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _startConversation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AuraTheme.serenityGradient.first,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '¡Comenzar Conversación!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _startConversation(BuildContext context) {
    // Navegar a la pantalla de conversación activa
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ActiveConversationScreen(),
      ),
    );
  }
}
