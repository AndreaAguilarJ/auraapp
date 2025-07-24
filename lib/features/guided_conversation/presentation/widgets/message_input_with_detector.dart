import 'package:flutter/material.dart';
import '../../../../features/guided_conversation/domain/services/accusation_detector.dart';

class MessageInputWithDetector extends StatefulWidget {
  final Function(String) onMessageSent;
  final bool isEnabled;
  final String hintText;

  const MessageInputWithDetector({
    Key? key,
    required this.onMessageSent,
    this.isEnabled = true,
    this.hintText = 'Comparte tus sentimientos usando "mensajes yo"...',
  }) : super(key: key);

  @override
  State<MessageInputWithDetector> createState() => _MessageInputWithDetectorState();
}

class _MessageInputWithDetectorState extends State<MessageInputWithDetector> {
  final TextEditingController _controller = TextEditingController();
  String? _suggestion;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mostrar sugerencia si existe
        if (_suggestion != null) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Sugerencia de Comunicación',
                      style: TextStyle(
                        color: Colors.amber[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _suggestion!,
                  style: TextStyle(
                    color: Colors.amber[800],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _suggestion = null),
                      child: Text(
                        'Entendido',
                        style: TextStyle(color: Colors.amber[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        // Campo de texto
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            enabled: widget.isEnabled,
            maxLines: null,
            minLines: 3,
            decoration: InputDecoration(
              hintText: widget.hintText,
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            onChanged: _onTextChanged,
          ),
        ),
        const SizedBox(height: 12),

        // Botón de enviar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || !widget.isEnabled || _controller.text.trim().isEmpty)
                ? null
                : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 18),
                      const SizedBox(width: 8),
                      const Text(
                        'Enviar Mensaje',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _onTextChanged(String text) {
    // Limpiar sugerencia anterior
    if (_suggestion != null) {
      setState(() => _suggestion = null);
    }

    // Detectar acusaciones en tiempo real (con debounce)
    if (text.length > 10) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_controller.text == text) {
          final accusation = AccusationDetector.detectAccusation(text);
          if (accusation != null && _suggestion != accusation) {
            setState(() => _suggestion = accusation);
          }
        }
      });
    }
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isEmpty || !widget.isEnabled) return;

    // Verificación final antes de enviar
    final accusation = AccusationDetector.detectAccusation(message);
    if (accusation != null) {
      setState(() => _suggestion = accusation);
      return;
    }

    setState(() => _isLoading = true);

    // Simular un pequeño delay para UX
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onMessageSent(message);
      _controller.clear();
      setState(() => _isLoading = false);
    });
  }
}
