import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class TurnIndicatorWidget extends StatelessWidget {
  final bool isMyTurn;
  final String currentPlayerName;
  final bool needsSummary;

  const TurnIndicatorWidget({
    Key? key,
    required this.isMyTurn,
    required this.currentPlayerName,
    this.needsSummary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMyTurn
              ? AuraTheme.energyGradient
              : AuraTheme.serenityGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isMyTurn ? Colors.orange : Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            needsSummary
                ? Icons.hearing
                : (isMyTurn ? Icons.mic : Icons.hourglass_empty),
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  needsSummary
                      ? 'Tiempo de Escucha Activa'
                      : (isMyTurn ? 'Tu turno' : 'Turno de $currentPlayerName'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  needsSummary
                      ? 'Resume lo que escuchaste antes de responder'
                      : (isMyTurn
                          ? 'Comparte tus sentimientos usando "mensajes yo"'
                          : 'Escucha activamente sin juzgar'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (isMyTurn && !needsSummary)
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
        ],
      ),
    );
  }
}
