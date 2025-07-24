/// Detector de acusaciones para conversaciones guiadas
/// Identifica patrones de comunicación destructivos y sugiere reformulaciones
class AccusationDetector {

  /// Frases gatillo que indican comunicación acusatoria o destructiva
  static const List<String> _triggerPhrases = [
    'tú siempre',
    'nunca me escuchas',
    'es tu culpa',
    'tú nunca',
    'siempre haces',
    'nunca haces',
    'eres muy',
    'deberías',
    'tienes que',
    'por tu culpa',
    'me haces sentir',
    'tú me haces',
    'está mal que',
    'no entiendes',
    'no te importa'
  ];

  /// Sugerencias de reformulación usando "mensajes yo"
  static const Map<String, String> _reformulationSuggestions = {
    'tú siempre': 'Intenta: "Yo me siento... cuando esto sucede repetidamente"',
    'nunca me escuchas': 'Intenta: "Yo necesito sentirme escuchado/a cuando..."',
    'es tu culpa': 'Intenta: "Yo me siento afectado/a por esta situación"',
    'tú nunca': 'Intenta: "Yo me sentiría valorado/a si..."',
    'siempre haces': 'Intenta: "Yo noto un patrón que me hace sentir..."',
    'nunca haces': 'Intenta: "Yo apreciaría mucho si pudiéramos..."',
    'eres muy': 'Intenta: "Yo experimento... cuando veo este comportamiento"',
    'deberías': 'Intenta: "Yo me sentiría mejor si..."',
    'tienes que': 'Intenta: "Para mí es importante que..."',
    'por tu culpa': 'Intenta: "Yo me siento... en esta situación"',
    'me haces sentir': 'Intenta: "Yo me siento... cuando..."',
    'tú me haces': 'Intenta: "Yo experimento... en estos momentos"',
    'está mal que': 'Intenta: "Yo preferiría que..."',
    'no entiendes': 'Intenta: "Yo necesito que comprendas que..."',
    'no te importa': 'Intenta: "Para mí es valioso sentir que..."'
  };

  /// Detecta si un mensaje contiene frases acusatorias
  /// Retorna una sugerencia de reformulación o null si no encuentra nada
  static String? detectAccusation(String text) {
    if (text.isEmpty) return null;

    final String normalizedText = text.toLowerCase().trim();

    // Buscar frases gatillo en el texto
    for (String trigger in _triggerPhrases) {
      if (normalizedText.contains(trigger.toLowerCase())) {
        // Retornar sugerencia específica o genérica
        return _reformulationSuggestions[trigger] ??
               'Intenta reformularlo desde tus sentimientos: "Yo me siento..." en lugar de enfocar en lo que hace la otra persona.';
      }
    }

    // Verificar patrones adicionales con regex
    if (_containsDestructivePatterns(normalizedText)) {
      return 'Intenta usar "mensajes yo" para expresar cómo te sientes en lugar de lo que hace tu pareja.';
    }

    return null;
  }

  /// Verifica patrones destructivos usando expresiones regulares
  static bool _containsDestructivePatterns(String text) {
    final List<RegExp> destructivePatterns = [
      RegExp(r'\btú\s+(no|nunca|siempre)\b'), // "tú no", "tú nunca", "tú siempre"
      RegExp(r'\beres\s+(un|una|muy)\b'),     // "eres un", "eres una", "eres muy"
      RegExp(r'\bculpa\s+tuya\b'),            // "culpa tuya"
      RegExp(r'\btú\s+tienes\s+la\s+culpa\b'), // "tú tienes la culpa"
    ];

    return destructivePatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Analiza el tono general del mensaje y sugiere mejoras
  static Map<String, dynamic> analyzeMessageTone(String text) {
    final accusation = detectAccusation(text);
    final hasPositiveLanguage = _hasPositiveLanguage(text);
    final hasIStatements = _hasIStatements(text);

    return {
      'hasAccusation': accusation != null,
      'suggestion': accusation,
      'hasPositiveLanguage': hasPositiveLanguage,
      'hasIStatements': hasIStatements,
      'overallTone': _calculateOverallTone(accusation == null, hasPositiveLanguage, hasIStatements),
    };
  }

  /// Detecta lenguaje positivo en el mensaje
  static bool _hasPositiveLanguage(String text) {
    final List<String> positiveWords = [
      'aprecio', 'agradezco', 'amo', 'quiero', 'valoro',
      'me gusta', 'disfruto', 'me hace feliz', 'me encanta'
    ];

    final String normalizedText = text.toLowerCase();
    return positiveWords.any((word) => normalizedText.contains(word));
  }

  /// Detecta si el mensaje usa "mensajes yo"
  static bool _hasIStatements(String text) {
    final List<RegExp> iStatements = [
      RegExp(r'\byo\s+(me\s+)?siento\b'),
      RegExp(r'\byo\s+(me\s+)?necesito\b'),
      RegExp(r'\byo\s+(me\s+)?experimento\b'),
      RegExp(r'\byo\s+(me\s+)?(sentiría|apreciaría)\b'),
    ];

    final String normalizedText = text.toLowerCase();
    return iStatements.any((pattern) => pattern.hasMatch(normalizedText));
  }

  /// Calcula el tono general del mensaje
  static String _calculateOverallTone(bool noAccusations, bool hasPositive, bool hasIStatements) {
    if (noAccusations && hasPositive && hasIStatements) return 'excellent';
    if (noAccusations && (hasPositive || hasIStatements)) return 'good';
    if (noAccusations) return 'neutral';
    return 'needs_improvement';
  }
}
