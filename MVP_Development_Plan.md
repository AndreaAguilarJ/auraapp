# AURA MVP - Plan de Desarrollo Detallado

## Resumen del MVP: "El Espacio Compartido"

Basado en las especificaciones de AURA, el MVP se enfoca en crear la funcionalidad central de transparencia voluntaria entre parejas a distancia, implementando dos componentes principales:

1. **La Brújula de Estado y Ánimo** ✅ COMPLETADO
2. **El Widget "Aura"** ✅ COMPLETADO

## Estado Actual del Desarrollo

### ✅ COMPLETADO: La Brújula de Estado y Ánimo
- Implementación completa de todos los componentes UI/UX
- Arquitectura de datos con Appwrite integrada
- Gestión de estado con Provider pattern
- Sistema de privacidad granular
- Documentación técnica completa

### ✅ COMPLETADO: El Widget Aura
- Indicador circular dinámico con mapeo de color/intensidad
- Botón "Pienso en ti" con animaciones avanzadas
- Sistema de frescura visual para actualizaciones
- Integración completa con datos en tiempo real
- Manejo de estados de carga, error y sin pareja

### 📝 PENDIENTE: Integración Final y Testing
- Navegación entre las dos funcionalidades principales
- Setup completo de Appwrite backend
- Testing unitario e integración
- Optimizaciones de performance

---

## Funcionalidad 1: La Brújula de Estado y Ánimo

### Tareas de Desarrollo (Frontend Flutter)

#### UI/UX Tasks

- [ ] **Tarea 1.1: Diseño del Sistema de Selección de Estado (`StatusSelector`)**
  
  **Objetivo:** Crear una interfaz intuitiva que empodere al usuario para compartir su disponibilidad de forma voluntaria, sin sentirse vigilado o presionado.
  
  **Componentes Principales:**
  - **Selector Circular de Estados:** Implementar un diseño circular que evoque la metáfora de "brújula", con los 4 estados dispuestos radialmente
  - **Sistema de Retroalimentación Visual:** Transiciones fluidas y micro-animaciones que refuerzan la sensación de control del usuario
  - **Indicadores de Contexto:** Elementos visuales que muestren la "frescura" y voluntariedad de la selección
  
  **Especificaciones de Implementación Flutter:**
  ```dart
  class StatusSelectorWidget extends StatefulWidget {
    final UserStatus currentStatus;
    final Function(UserStatus) onStatusChanged;
    final bool isLoading;
    
    @override
    _StatusSelectorWidgetState createState() => _StatusSelectorWidgetState();
  }
  
  class _StatusSelectorWidgetState extends State<StatusSelectorWidget> 
      with TickerProviderStateMixin {
    late AnimationController _pulseController;
    late AnimationController _selectionController;
    // Implementación de animaciones y gestos
  }
  ```
  
  **Iconografía y Sistema de Colores:**
  - `Disponible`: 🟢 Verde (#2ECC71) + Ícono check_circle_outline
  - `Ocupado`: 🟠 Naranja (#E67E22) + Ícono work_outline  
  - `Descansando`: 🔵 Azul suave (#3498DB) + Ícono bedtime_outlined
  - `Viajando`: 🟣 Púrpura (#9B59B6) + Ícono flight_outlined
  
  **Principios de Accesibilidad:**
  - Área táctil mínima: 48x48dp según Material Design Guidelines
  - Ratio de contraste ≥ 4.5:1 para texto, ≥ 3:1 para elementos gráficos
  - Soporte para lectores de pantalla con etiquetas semánticas descriptivas
  - Navegación por teclado para usuarios con discapacidades motoras

- [ ] **Tarea 1.2: Implementación del Selector Bidimensional de Ánimo (`MoodSpectrumWidget`)**
  
  **Objetivo:** Traducir la complejidad emocional en una interfaz intuitiva que permita expresar matices sin abrumar al usuario.
  
  **Diseño Conceptual:**
  - **Cuadrante Interactivo:** Implementar un plano cartesiano donde X = Energía (-1 a +1), Y = Positividad (-1 a +1)
  - **Retroalimentación Visual en Tiempo Real:** El color del indicador cambia dinámicamente según la posición
  - **Gestos Intuitivos:** Tap para selección rápida, drag para ajuste fino
  
  **Implementación Técnica:**
  ```dart
  class MoodSpectrumWidget extends StatefulWidget {
    final double energy;     // -1.0 a 1.0
    final double positivity; // -1.0 a 1.0
    final Function(double energy, double positivity) onMoodChanged;
    
    @override
    _MoodSpectrumWidgetState createState() => _MoodSpectrumWidgetState();
  }
  
  class MoodSpectrumPainter extends CustomPainter {
    final double energy;
    final double positivity;
    final Color moodColor;
    
    @override
    void paint(Canvas canvas, Size size) {
      // Implementar gradiente radial basado en cuadrantes emocionales
      // Dibujar indicador de posición actual
      // Añadir líneas guía sutiles para orientación
    }
  }
  ```
  
  **Sistema de Color Emocional:**
  - **Cuadrante I** (Alta energía + Positivo): Gradiente dorado (#FFD700 → #FFA500)
  - **Cuadrante II** (Baja energía + Positivo): Gradiente verde (#27AE60 → #58D68D)
  - **Cuadrante III** (Baja energía + Negativo): Gradiente azul gris (#34495E → #5D6D7E)
  - **Cuadrante IV** (Alta energía + Negativo): Gradiente rojo (#E74C3C → #EC7063)
  
  **Justificación Psicológica:** Permite expresar estados emocionales complejos (ej: "cansado pero feliz") que reducen la incertidumbre del partner y fomentan una comprensión más profunda.

- [ ] **Tarea 1.3: Campo de Nota Contextual (`ContextNoteInputWidget`)**
  
  **Objetivo:** Proporcionar un espacio opcional para añadir contexto sin presión, reforzando la voluntariedad.
  
  **Especificaciones de UX:**
  - **Diseño Expansivo:** Inicia como un hint sutil, se expande al tocar
  - **Contador Visual Inteligente:** Solo aparece cuando se acerca al límite (120+ caracteres)
  - **Sugerencias Contextuales:** Prompts opcionales basados en el estado seleccionado
  
  **Implementación:**
  ```dart
  class ContextNoteInputWidget extends StatefulWidget {
    final String initialText;
    final Function(String) onTextChanged;
    final UserStatus currentStatus;
    
    @override
    _ContextNoteInputWidgetState createState() => _ContextNoteInputWidgetState();
  }
  
  class _ContextNoteInputWidgetState extends State<ContextNoteInputWidget> 
      with SingleTickerProviderStateMixin {
    late TextEditingController _controller;
    late AnimationController _expandController;
    late FocusNode _focusNode;
    
    // Implementar lógica de expansión y validación
  }
  ```
  
  **Características Clave:**
  - **Placeholder Dinámico:** Cambia según el estado (ej: "¿Qué estás haciendo?" para Ocupado)
  - **Validación No Intrusiva:** Border color sutil para indicar límite sin bloquear
  - **Auto-save Local:** Guarda borradores para evitar pérdida de información

- [ ] **Tarea 1.4: Sistema de Animaciones y Micro-interacciones (`MoodCompassAnimations`)**
  
  **Objetivo:** Crear una experiencia fluida que haga sentir al usuario en control y conectado, sin ser distractiva.
  
  **Animaciones Principales:**
  - **Transición de Estado:** Morphing suave entre iconos (300ms, Curves.easeInOutCubic)
  - **Feedback de Ánimo:** Ondas concéntricas al cambiar posición en el espectro
  - **Confirmación de Envío:** Pulso suave que emana del centro hacia afuera
  - **Indicador de Frescura:** Glow sutil que se desvanece gradualmente con el tiempo
  
  **Implementación Técnica:**
  ```dart
  class MoodCompassAnimations {
    static const Duration shortDuration = Duration(milliseconds: 200);
    static const Duration mediumDuration = Duration(milliseconds: 400);
    static const Duration longDuration = Duration(milliseconds: 600);
    
    static Animation<double> createPulseAnimation(AnimationController controller) {
      return Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut)
      );
    }
    
    static Animation<Color?> createColorTransition(
      AnimationController controller, 
      Color fromColor, 
      Color toColor
    ) {
      return ColorTween(begin: fromColor, end: toColor).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut)
      );
    }
  }
  ```
  
  **Principios de Animación:**
  - **Sutileza:** Nunca deben distraer del contenido principal
  - **Propósito:** Cada animación comunica estado o refuerza acción del usuario
  - **Rendimiento:** Optimizadas para 60fps, usando transforms en lugar de repaints

- [ ] **Tarea 1.5: Componente de Actualización y Estado (`StatusUpdateController`)**
  
  **Objetivo:** Manejar el flujo de actualización de forma transparente, mostrando progreso sin ansiedad.
  
  **Estados de Interfaz:**
  - **Idle:** Estado normal, sin actualizaciones pendientes
  - **Composing:** Usuario está modificando su estado/ánimo
  - **Validating:** Verificación local de datos antes del envío
  - **Syncing:** Enviando datos a Appwrite
  - **Success:** Confirmación visual de actualización exitosa
  - **Error:** Comunicación clara de problemas con opciones de reintentar
  
  **Implementación del Flujo:**
  ```dart
  class StatusUpdateController extends StatefulWidget {
    final Widget child;
    final Function(UserStatus, double, double, String) onUpdateRequest;
    
    @override
    _StatusUpdateControllerState createState() => _StatusUpdateControllerState();
  }
  
  enum UpdateState { idle, composing, validating, syncing, success, error }
  
  class _StatusUpdateControllerState extends State<StatusUpdateController> {
    UpdateState _currentState = UpdateState.idle;
    String? _errorMessage;
    Timer? _successTimer;
    
    Future<void> _handleUpdate() async {
      setState(() => _currentState = UpdateState.validating);
      
      try {
        // Validación local
        if (_validateInputs()) {
          setState(() => _currentState = UpdateState.syncing);
          await widget.onUpdateRequest(/* parámetros */);
          setState(() => _currentState = UpdateState.success);
          _scheduleReturnToIdle();
        }
      } catch (error) {
        setState(() {
          _currentState = UpdateState.error;
          _errorMessage = _parseError(error);
        });
      }
    }
  }
  ```

- [ ] **Tarea 1.6: Integración con Appwrite desde Perspectiva UI/UX**
  
  **Objetivo:** Diseñar interfaces que reflejen la arquitectura de datos de Appwrite de forma intuitiva.
  
  **Estructura de Datos UI:**
  ```dart
  class MoodCompassData {
    final String userId;
    final UserStatus status;
    final MoodCoordinates mood;
    final String contextNote;
    final DateTime lastUpdated;
    final bool isActive;
    
    // Métodos para serialización a Appwrite Document
    Map<String, dynamic> toAppwriteDocument() {
      return {
        'status': status.name,
        'mood': {
          'energy': mood.energy,
          'positivity': mood.positivity,
        },
        'contextNote': contextNote,
        'lastUpdated': lastUpdated.toIso8601String(),
        'isActive': isActive,
      };
    }
  }
  ```
  
  **Manejo de Permisos en UI:**
  - **Indicadores Visuales:** Icons que muestren si el usuario puede/no puede actualizar
  - **Estados Deshabilitados:** Componentes en modo read-only con explicación clara
  - **Requests de Permisos:** Flujos educativos para solicitar permisos necesarios
  
  **Realtime Updates Visualization:**
  ```dart
  class PartnerStatusDisplay extends StatelessWidget {
    final Stream<MoodCompassData> partnerDataStream;
    
    @override
    Widget build(BuildContext context) {
      return StreamBuilder<MoodCompassData>(
        stream: partnerDataStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildPartnerStatus(snapshot.data!);
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error!);
          } else {
            return _buildLoadingState();
          }
        },
      );
    }
  }
  ```

- [ ] **Tarea 1.7: Arquitectura Modular de Componentes**
  
  **Objetivo:** Crear una estructura mantenible y testeable que facilite la iteración rápida.
  
  **Jerarquía de Widgets:**
  ```
  MoodCompassScreen
  ├── MoodCompassHeader
  ├── StatusSelectorWidget
  ├── MoodSpectrumWidget
  ├── ContextNoteInputWidget
  ├── StatusUpdateController
  └── QuickActionBar
  ```
  
  **Patrón de Composición:**
  ```dart
  class MoodCompassScreen extends StatefulWidget {
    @override
    _MoodCompassScreenState createState() => _MoodCompassScreenState();
  }
  
  class _MoodCompassScreenState extends State<MoodCompassScreen> {
    final MoodCompassController _controller = MoodCompassController();
    
    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Scaffold(
            body: Column(
              children: [
                MoodCompassHeader(timestamp: _controller.lastUpdate),
                Expanded(
                  child: _buildMainContent(),
                ),
                StatusUpdateController(
                  state: _controller.updateState,
                  onUpdate: _controller.updateStatus,
                  child: QuickActionBar(),
                ),
              ],
            ),
          );
        },
      );
    }
  }
  ```

- [ ] **Tarea 1.8: Manejo de Estados de Error y Carga**
  
  **Objetivo:** Comunicar problemas de forma empática y proporcionar caminos claros de resolución.
  
  **Tipos de Error UI:**
  - **Validación Local:** Feedback inmediato sin bloquear la experiencia
  - **Errores de Red:** Indicadores de conectividad con opciones de retry
  - **Errores de Permisos:** Explicaciones claras con pasos para resolver
  - **Errores del Servidor:** Mensajes humanizados con alternativas
  
  **Implementación de Error States:**
  ```dart
  class ErrorStateWidget extends StatelessWidget {
    final ErrorType errorType;
    final String message;
    final VoidCallback? onRetry;
    final VoidCallback? onDismiss;
    
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getErrorColor(errorType).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getErrorColor(errorType).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getErrorIcon(errorType),
              color: _getErrorColor(errorType),
              size: 24,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Reintentar'),
              ),
            ],
          ],
        ),
      );
    }
  }
  ```

- [ ] **Tarea 1.9: Optimización de Rendimiento y Batería**
  
  **Objetivo:** Crear una experiencia fluida que respete los recursos del dispositivo.
  
  **Estrategias de Optimización:**
  - **Lazy Loading:** Widgets complejos se construyen solo cuando son visibles
  - **Debouncing:** Evitar actualizaciones excesivas durante interacciones rápidas
  - **Memoization:** Cache de valores calculados costosos (gradientes, paths)
  - **Widget Recycling:** Reutilización de widgets para animaciones frecuentes
  
  **Implementación de Debouncing:**
  ```dart
  class DebouncedInput extends StatefulWidget {
    final Function(String) onChanged;
    final Duration delay;
    
    @override
    _DebouncedInputState createState() => _DebouncedInputState();
  }
  
  class _DebouncedInputState extends State<DebouncedInput> {
    Timer? _debounceTimer;
    late TextEditingController _controller;
    
    void _onTextChanged(String text) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.delay, () {
        widget.onChanged(text);
      });
    }
    
    @override
    void dispose() {
      _debounceTimer?.cancel();
      _controller.dispose();
      super.dispose();
    }
  }
  ```
  
  **Métricas de Rendimiento:**
  - **Frame Rate:** Mantener 60fps durante animaciones
  - **Memory Usage:** <50MB adicionales durante uso intensivo
  - **Battery Impact:** <2% por hora de uso activo
  - **Load Time:** <500ms para renderizar interfaz completa

- [ ] **Tarea 1.10: Indicadores de Confianza y Transparencia Visual**
  
  **Objetivo:** Crear elementos visuales que refuercen la filosofía de transparencia voluntaria y no-vigilancia de Aura.
  
  **Indicadores de Voluntariedad:**
  ```dart
  class VoluntaryIndicatorWidget extends StatelessWidget {
    final DateTime lastUserInitiatedUpdate;
    final bool isManualUpdate;
    final int confidenceScore; // 0-100 basado en frecuencia y consistencia
    
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getConfidenceColor(confidenceScore).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getConfidenceColor(confidenceScore).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isManualUpdate ? Icons.touch_app : Icons.autorenew,
              size: 12,
              color: _getConfidenceColor(confidenceScore),
            ),
            SizedBox(width: 4),
            Text(
              _getConfidenceText(confidenceScore),
              style: TextStyle(
                fontSize: 10,
                color: _getConfidenceColor(confidenceScore),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    Color _getConfidenceColor(int score) {
      if (score >= 80) return Colors.green;
      if (score >= 60) return Colors.amber;
      return Colors.orange;
    }
    
    String _getConfidenceText(int score) {
      if (score >= 80) return "Muy confiable";
      if (score >= 60) return "Confiable";
      return "Actualización reciente";
    }
  }
  ```
  
  **Micro-estados de Conexión Emocional:**
  - **Heartbeat Indicator:** Pulso sutil que sincroniza cuando ambos usuarios están activos
  - **Emotional Resonance:** Cambios sutiles de color cuando los ánimos están alineados
  - **Distance Visualization:** Gradiente que refleja la "cercanía emocional" percibida
  
  **Justificación Psicológica:** Los indicadores de confianza validan la autenticidad de la conexión sin crear presión, fomentando honestidad y reduciendo ansiedad sobre la veracidad de la información compartida.

- [ ] **Tarea 1.11: Controles de Privacidad Granular**
  
  **Objetivo:** Empoderar al usuario con control total sobre qué, cuándo y cómo comparte información emocional.
  
  **Panel de Control de Privacidad:**
  ```dart
  class PrivacyControlPanel extends StatefulWidget {
    final PrivacySettings currentSettings;
    final Function(PrivacySettings) onSettingsChanged;
    
    @override
    _PrivacyControlPanelState createState() => _PrivacyControlPanelState();
  }
  
  class PrivacySettings {
    bool shareStatus;
    bool shareMoodSpectrum;
    bool shareContextNotes;
    bool shareTimestamps;
    bool allowNotifications;
    Duration dataRetentionPeriod;
    List<String> hiddenEmotions;
    
    PrivacySettings({
      this.shareStatus = true,
      this.shareMoodSpectrum = true,
      this.shareContextNotes = false,
      this.shareTimestamps = true,
      this.allowNotifications = true,
      this.dataRetentionPeriod = const Duration(days: 30),
      this.hiddenEmotions = const [],
    });
  }
  ```
  
  **Funcionalidades de Privacidad Avanzadas:**
  - **Pause Mode:** Botón de pausa temporal para momentos de privacidad absoluta
  - **Selective Sharing:** Toggles granulares para cada tipo de información
  - **Expiration Timer:** Opción de auto-eliminación de actualizaciones sensibles
  - **Mood Masking:** Opción de compartir estado general sin detalles específicos
  
  **Preview de Información Compartida:**
  ```dart
  class SharingPreviewWidget extends StatelessWidget {
    final MoodCompassData userData;
    final PrivacySettings settings;
    
    @override
    Widget build(BuildContext context) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue.withOpacity(0.05),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.visibility, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  "Tu pareja verá:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildPreviewItem("Estado", settings.shareStatus ? userData.status.name : "Oculto"),
            _buildPreviewItem("Ánimo", settings.shareMoodSpectrum ? "Visible" : "Oculto"),
            _buildPreviewItem("Nota", settings.shareContextNotes ? userData.contextNote : "Oculta"),
            _buildPreviewItem("Última actualización", settings.shareTimestamps ? _formatTime(userData.lastUpdated) : "Oculta"),
          ],
        ),
      );
    }
  }
  ```
  
  **Justificación Psicológica:** El control granular sobre la privacidad reduce la ansiedad de sobrecompartir y fortalece la sensación de autonomía, elementos cruciales para mantener una relación saludable a distancia.

- [ ] **Tarea 1.12: Sistema de Retroalimentación Háptica Emocional**
  
  **Objetivo:** Usar feedback táctil para crear conexiones emocionales más profundas y comunicar estados sutiles.
  
  **Patrones Hápticos Diferenciados:**
  ```dart
  class EmotionalHapticFeedback {
    static const Map<UserStatus, List<int>> statusPatterns = {
      UserStatus.available: [50], // Un pulso suave
      UserStatus.busy: [100, 50, 100], // Pulso-pausa-pulso (ocupado pero accesible)
      UserStatus.resting: [200], // Pulso largo y suave
      UserStatus.traveling: [50, 50, 50, 50], // Patrones rítmicos como movimiento
    };
    
    static const Map<MoodIntensity, int> intensityLevels = {
      MoodIntensity.subtle: 30,
      MoodIntensity.moderate: 60,
      MoodIntensity.strong: 100,
    };
    
    static Future<void> playStatusUpdate(UserStatus status) async {
      if (Platform.isIOS) {
        await HapticFeedback.lightImpact();
      } else {
        // Android custom pattern
        final pattern = statusPatterns[status] ?? [50];
        await Vibration.vibrate(pattern: pattern);
      }
    }
    
    static Future<void> playMoodResonance() async {
      // Feedback especial cuando los ánimos están sincronizados
      await HapticFeedback.mediumImpact();
      await Future.delayed(Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    }
    
    static Future<void> playConnectionPulse() async {
      // Pulse sutil cuando la pareja actualiza su estado
      await HapticFeedback.selectionClick();
    }
  }
  ```
  
  **Implementación en Widgets:**
  ```dart
  class HapticEnabledMoodSpectrum extends StatefulWidget {
    final Function(MoodCoordinates) onMoodChanged;
    final MoodCoordinates currentMood;
    
    @override
    _HapticEnabledMoodSpectrumState createState() => _HapticEnabledMoodSpectrumState();
  }
  
  class _HapticEnabledMoodSpectrumState extends State<HapticEnabledMoodSpectrum> {
    @override
    Widget build(BuildContext context) {
      return GestureDetector(
        onPanUpdate: (details) {
          // Calcular nueva posición de ánimo
          final newMood = _calculateMoodFromPosition(details.localPosition);
          
          // Feedback háptico basado en la intensidad del cambio
          final intensityChange = _calculateIntensityChange(widget.currentMood, newMood);
          if (intensityChange > 0.3) {
            EmotionalHapticFeedback.playMoodChange(newMood);
          }
          
          widget.onMoodChanged(newMood);
        },
        child: CustomPaint(
          painter: MoodSpectrumPainter(mood: widget.currentMood),
          size: Size.square(200),
        ),
      );
    }
  }
  ```
  
  **Configuración de Accesibilidad:**
  - **Settings Toggle:** Opción para desactivar feedback háptico
  - **Intensity Control:** Niveles adjustables para diferentes sensibilidades
  - **Pattern Customization:** Permitir a usuarios crear sus propios patrones
  
  **Justificación Psicológica:** El feedback háptico crea una dimensión adicional de conexión física simulada, especialmente importante en relaciones a distancia donde el tacto físico está ausente.

- [ ] **Tarea 1.13: Lógica de Actualización Inteligente y Recordatorios Conscientes**
  
  **Objetivo:** Implementar un sistema que fomente la actualización regular sin crear presión o vigilancia.
  
  **Sistema de Recordatorios Empáticos:**
  ```dart
  class ConsciousReminderSystem {
    static const List<String> gentleReminders = [
      "Tu pareja podría estar preguntándose cómo estás ✨",
      "Un pequeño update puede alegrar el día de alguien 💝",
      "¿Cómo te sientes en este momento? 🌱",
      "Compartir tu estado es un regalo de transparencia 🎁",
    ];
    
    static const List<String> contextualReminders = [
      "¿Cambió algo desde tu última actualización? 🔄",
      "Tu ánimo de hace 3 horas podría haber evolucionado 🌅",
      "Incluso un pequeño cambio puede ser significativo 💫",
    ];
    
    static Future<void> scheduleConsciousReminder({
      required Duration timeSinceLastUpdate,
      required UserBehaviorPattern behaviorPattern,
      required TimeOfDay currentTime,
    }) async {
      // Solo enviar recordatorios en momentos apropiados
      if (_shouldSendReminder(timeSinceLastUpdate, behaviorPattern, currentTime)) {
        final message = _selectAppropriateMessage(behaviorPattern);
        await NotificationService.showGentleReminder(message);
      }
    }
    
    static bool _shouldSendReminder(
      Duration timeSinceLastUpdate,
      UserBehaviorPattern pattern,
      TimeOfDay currentTime,
    ) {
      // Lógica inteligente basada en patrones de usuario
      final hoursSinceUpdate = timeSinceLastUpdate.inHours;
      
      // Usuarios frecuentes: recordar después de 4+ horas
      if (pattern.averageUpdatesPerDay > 6 && hoursSinceUpdate > 4) return true;
      
      // Usuarios moderados: recordar después de 8+ horas
      if (pattern.averageUpdatesPerDay > 3 && hoursSinceUpdate > 8) return true;
      
      // Usuarios ocasionales: recordar después de 24+ horas
      if (hoursSinceUpdate > 24) return true;
      
      // Nunca recordar entre 10pm y 8am
      if (currentTime.hour < 8 || currentTime.hour > 22) return false;
      
      return false;
    }
  }
  ```
  
  **Algoritmo de Frecuencia Adaptativa:**
  ```dart
  class AdaptiveUpdateFrequency {
    final UserBehaviorPattern userPattern;
    final PartnerBehaviorPattern partnerPattern;
    
    AdaptiveUpdateFrequency({
      required this.userPattern,
      required this.partnerPattern,
    });
    
    Duration calculateOptimalReminderInterval() {
      // Basar frecuencia en patrones mutuos
      final userAvg = userPattern.averageTimeBetweenUpdates;
      final partnerAvg = partnerPattern.averageTimeBetweenUpdates;
      
      // Promedio ponderado favoreciendo consistencia
      final optimalInterval = Duration(
        milliseconds: ((userAvg.inMilliseconds * 0.7) + 
                      (partnerAvg.inMilliseconds * 0.3)).round(),
      );
      
      // Límites razonables: min 2 horas, max 24 horas
      return Duration(
        hours: math.max(2, math.min(24, optimalInterval.inHours)),
      );
    }
    
    String generatePersonalizedPrompt() {
      final daysSinceLastUpdate = userPattern.daysSinceLastUpdate;
      
      if (daysSinceLastUpdate == 0) {
        return "¿Cómo evoluciona tu día? 🌱";
      } else if (daysSinceLastUpdate == 1) {
        return "Tu pareja podría estar curiosa sobre tu ayer 🌙";
      } else {
        return "Han pasado $daysSinceLastUpdate días. ¿Qué ha cambiado? ✨";
      }
    }
  }
  ```
  
  **Justificación Psicológica:** Los recordatorios adaptativos respetan los ritmos naturales del usuario mientras mantienen la conexión, evitando tanto el abandono como la sobreestimulación.

- [ ] **Tarea 1.14: Gestión Offline-First y Resolución de Conflictos**
  
  **Objetivo:** Crear una experiencia fluida que funcione independientemente de la conectividad, con sincronización inteligente.
  
  **Arquitectura Offline-First:**
  ```dart
  class OfflineMoodCompassManager {
    final LocalStorageService _localStorage;
    final AppwriteSyncService _syncService;
    final StreamController<SyncStatus> _syncStatusController;
    
    Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
    
    Future<void> saveOffline(MoodCompassData data) async {
      // Guardar localmente con timestamp y flag de sincronización
      final offlineEntry = OfflineEntry(
        data: data,
        timestamp: DateTime.now(),
        syncStatus: SyncStatus.pending,
        conflictResolutionNeeded: false,
      );
      
      await _localStorage.save('mood_compass_${data.id}', offlineEntry);
      _syncStatusController.add(SyncStatus.hasPendingChanges);
      
      // Intentar sincronización inmediata si hay conectividad
      if (await ConnectivityService.hasConnection()) {
        _attemptSync();
      }
    }
    
    Future<void> _attemptSync() async {
      final pendingEntries = await _localStorage.getPendingEntries();
      
      for (final entry in pendingEntries) {
        try {
          final serverData = await _syncService.getServerData(entry.data.id);
          
          if (serverData != null && _hasConflict(entry.data, serverData)) {
            // Manejar conflicto con UI amigable
            await _handleConflict(entry, serverData);
          } else {
            // Sync directo
            await _syncService.updateServer(entry.data);
            await _localStorage.markAsSynced(entry.id);
          }
        } catch (e) {
          // Mantener en cola para retry posterior
          print('Sync failed for ${entry.id}: $e');
        }
      }
      
      _syncStatusController.add(SyncStatus.synced);
    }
  }
  ```
  
  **Resolución de Conflictos Empática:**
  ```dart
  class ConflictResolutionWidget extends StatelessWidget {
    final MoodCompassData localData;
    final MoodCompassData serverData;
    final Function(MoodCompassData) onResolved;
    
    @override
    Widget build(BuildContext context) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.merge, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    "Encontramos dos versiones de tu estado",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text("¿Cuál representa mejor cómo te sientes ahora?"),
              SizedBox(height: 12),
              
              // Opción local
              _buildVersionOption(
                title: "Tu versión más reciente",
                subtitle: "Guardada en tu dispositivo hace ${_formatTime(localData.timestamp)}",
                data: localData,
                onTap: () => onResolved(localData),
              ),
              
              SizedBox(height: 8),
              
              // Opción servidor
              _buildVersionOption(
                title: "Versión sincronizada",
                subtitle: "Sincronizada hace ${_formatTime(serverData.timestamp)}",
                data: serverData,
                onTap: () => onResolved(serverData),
              ),
              
              SizedBox(height: 12),
              
              // Opción manual
              TextButton.icon(
                onPressed: () => _showManualMergeDialog(context),
                icon: Icon(Icons.edit),
                label: Text("Crear nueva actualización"),
              ),
            ],
          ),
        ),
      );
    }
  }
  ```
  
  **Justificación Psicológica:** La gestión offline-first reduce la ansiedad sobre conectividad intermitente, mientras que la resolución de conflictos empática mantiene al usuario en control de su narrativa emocional.

- [ ] **Tarea 1.15: Animaciones Orgánicas y Conscientes de la Energía**
  
  **Objetivo:** Crear un sistema de animaciones que refleje estados emocionales naturales y conserve batería.
  
  **Sistema de Animaciones Adaptativas:**
  ```dart
  class OrganicAnimationController {
    final TickerProvider tickerProvider;
    final BatteryLevel batteryLevel;
    final AccessibilitySettings accessibilitySettings;
    
    late final Map<AnimationType, AnimationController> _controllers;
    
    OrganicAnimationController({
      required this.tickerProvider,
      required this.batteryLevel,
      required this.accessibilitySettings,
    }) {
      _initializeControllers();
    }
    
    void _initializeControllers() {
      _controllers = {
        AnimationType.breathing: AnimationController(
          duration: _getAdaptiveDuration(AnimationType.breathing),
          vsync: tickerProvider,
        ),
        AnimationType.heartbeat: AnimationController(
          duration: _getAdaptiveDuration(AnimationType.heartbeat),
          vsync: tickerProvider,
        ),
        AnimationType.connection: AnimationController(
          duration: _getAdaptiveDuration(AnimationType.connection),
          vsync: tickerProvider,
        ),
      };
    }
    
    Duration _getAdaptiveDuration(AnimationType type) {
      // Ajustar velocidad basada en batería y preferencias
      var baseDuration = type.defaultDuration;
      
      // Reducir velocidad si batería baja
      if (batteryLevel.percentage < 20) {
        baseDuration = Duration(milliseconds: (baseDuration.inMilliseconds * 1.5).round());
      }
      
      // Respetar preferencias de movimiento reducido
      if (accessibilitySettings.reduceMotion) {
        baseDuration = Duration(milliseconds: (baseDuration.inMilliseconds * 2).round());
      }
      
      return baseDuration;
    }
    
    Animation<double> createBreathingAnimation(MoodCoordinates mood) {
      final controller = _controllers[AnimationType.breathing]!;
      
      // Ajustar ritmo de respiración basado en energía emocional
      final breathingRate = _calculateBreathingRate(mood.energy);
      controller.duration = Duration(milliseconds: (2000 / breathingRate).round());
      
      return Tween<double>(
        begin: 1.0,
        end: 1.0 + (mood.positivity.abs() * 0.1), // Amplitud basada en positividad
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }
    
    double _calculateBreathingRate(double energy) {
      // Energy -1.0 to 1.0 -> breathing rate 0.5 to 1.5
      return 1.0 + (energy * 0.5);
    }
  }
  ```
  
  **Animaciones Específicas por Estado Emocional:**
  ```dart
  class EmotionalAnimationPresets {
    static Animation<Color?> createMoodGradient(
      AnimationController controller,
      MoodCoordinates mood,
    ) {
      final baseColor = MoodColorMapping.getColorForMood(mood);
      final accentColor = MoodColorMapping.getAccentColorForMood(mood);
      
      return ColorTween(
        begin: baseColor.withOpacity(0.3),
        end: accentColor.withOpacity(0.7),
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutSine,
      ));
    }
    
    static Animation<Offset> createConnectionPulse(
      AnimationController controller,
      bool isConnectedToPartner,
    ) {
      if (!isConnectedToPartner) {
        return Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(controller);
      }
      
      return Tween<Offset>(
        begin: Offset.zero,
        end: Offset(0.02, 0.02), // Sutil movimiento de conexión
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }
    
    static Animation<double> createIntensityPulse(
      AnimationController controller,
      double emotionalIntensity,
    ) {
      final maxScale = 1.0 + (emotionalIntensity * 0.05); // Max 5% de crecimiento
      
      return Tween<double>(
        begin: 1.0,
        end: maxScale,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOutCirc,
      ));
    }
  }
  ```
  
  **Optimización Consciente de Batería:**
  ```dart
  class BatteryConsciousAnimationManager {
    final BatteryInfoPlugin batteryInfo;
    
    BatteryConsciousAnimationManager(this.batteryInfo);
    
    Future<AnimationProfile> getOptimalAnimationProfile() async {
      final batteryLevel = await batteryInfo.batteryLevel;
      final isCharging = await batteryInfo.chargingStatus;
      
      if (isCharging == ChargingStatus.charging) {
        return AnimationProfile.full;
      } else if (batteryLevel > 50) {
        return AnimationProfile.standard;
      } else if (batteryLevel > 20) {
        return AnimationProfile.reduced;
      } else {
        return AnimationProfile.minimal;
      }
    }
    
    void applyProfile(AnimationProfile profile, Map<AnimationType, AnimationController> controllers) {
      switch (profile) {
        case AnimationProfile.full:
          // Todas las animaciones habilitadas
          break;
        case AnimationProfile.standard:
          // Reducir FPS de 60 a 30 para animaciones decorativas
          break;
        case AnimationProfile.reduced:
          // Solo animaciones funcionales
          controllers[AnimationType.breathing]?.stop();
          break;
        case AnimationProfile.minimal:
          // Solo feedback de interacción
          controllers.values.forEach((controller) => controller.stop());
          break;
      }
    }
  }
  ```
  
  **Justificación Psicológica:** Las animaciones orgánicas crean una experiencia más humana y viva, mientras que la consciencia de batería demuestra respeto por los recursos del usuario, construyendo confianza en la aplicación.

- [ ] **Tarea 1.16: Validación Empática y Feedback Positivo**
  
  **Objetivo:** Implementar un sistema de validación que celebre la vulnerabilidad emocional y fomente la expresión auténtica.
  
  **Sistema de Validación Progresiva:**
  ```dart
  class EmpatheticValidationSystem {
    static const Map<ValidationLevel, ValidationMessage> validationMessages = {
      ValidationLevel.acknowledgment: ValidationMessage(
        icon: Icons.favorite,
        message: "Gracias por compartir cómo te sientes ✨",
        color: Colors.pink,
        duration: Duration(seconds: 2),
      ),
      ValidationLevel.appreciation: ValidationMessage(
        icon: Icons.psychology,
        message: "Tu honestidad emocional fortalece la conexión 💝",
        color: Colors.purple,
        duration: Duration(seconds: 3),
      ),
      ValidationLevel.celebration: ValidationMessage(
        icon: Icons.celebration,
        message: "¡Qué hermoso ver tu crecimiento emocional! 🌱",
        color: Colors.green,
        duration: Duration(seconds: 4),
      ),
    };
    
    static ValidationLevel determineValidationLevel(
      MoodCompassData currentUpdate,
      List<MoodCompassData> recentHistory,
    ) {
      // Detectar patrones de crecimiento emocional
      if (_showsEmotionalGrowth(currentUpdate, recentHistory)) {
        return ValidationLevel.celebration;
      }
      
      // Detectar vulnerabilidad (compartir estados difíciles)
      if (_showsVulnerability(currentUpdate)) {
        return ValidationLevel.appreciation;
      }
      
      // Default: reconocimiento simple
      return ValidationLevel.acknowledgment;
    }
    
    static bool _showsEmotionalGrowth(
      MoodCompassData current,
      List<MoodCompassData> history,
    ) {
      if (history.length < 3) return false;
      
      // Detectar tendencia positiva en el tiempo
      final recentMoods = history.take(3).map((d) => d.mood.positivity).toList();
      return recentMoods.every((mood) => mood < current.mood.positivity);
    }
    
    static bool _showsVulnerability(MoodCompassData data) {
      // Compartir estados difíciles es un acto de confianza
      return data.mood.positivity < -0.5 && data.contextNote.isNotEmpty;
    }
  }
  ```
  
  **Widget de Celebración Emocional:**
  ```dart
  class EmotionalCelebrationWidget extends StatefulWidget {
    final ValidationMessage validationMessage;
    final VoidCallback onComplete;
    
    @override
    _EmotionalCelebrationWidgetState createState() => _EmotionalCelebrationWidgetState();
  }
  
  class _EmotionalCelebrationWidgetState extends State<EmotionalCelebrationWidget> 
      with TickerProviderStateMixin {
    late AnimationController _appearController;
    late AnimationController _sparkleController;
    late Animation<double> _scaleAnimation;
    late Animation<double> _opacityAnimation;
    
    @override
    void initState() {
      super.initState();
      
      _appearController = AnimationController(
        duration: Duration(milliseconds: 600),
        vsync: this,
      );
      
      _sparkleController = AnimationController(
        duration: Duration(milliseconds: 1500),
        vsync: this,
      );
      
      _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _appearController, curve: Curves.elasticOut),
      );
      
      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _appearController, curve: Curves.easeIn),
      );
      
      _startAnimation();
    }
    
    void _startAnimation() async {
      await _appearController.forward();
      _sparkleController.repeat();
      
      // Auto-dismiss después de la duración especificada
      Timer(widget.validationMessage.duration, () {
        _dismissAnimation();
      });
    }
    
    void _dismissAnimation() async {
      await _appearController.reverse();
      _sparkleController.stop();
      widget.onComplete();
    }
    
    @override
    Widget build(BuildContext context) {
      return AnimatedBuilder(
        animation: Listenable.merge([_appearController, _sparkleController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: widget.validationMessage.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.validationMessage.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Icon(
                          widget.validationMessage.icon,
                          color: widget.validationMessage.color,
                          size: 24,
                        ),
                        if (_sparkleController.isAnimating)
                          Positioned.fill(
                            child: _buildSparkleEffect(),
                          ),
                      ],
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.validationMessage.message,
                        style: TextStyle(
                          color: widget.validationMessage.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
    }
    
    Widget _buildSparkleEffect() {
      return CustomPaint(
        painter: SparklePainter(
          animationValue: _sparkleController.value,
          color: widget.validationMessage.color,
        ),
      );
    }
  }
  ```
  
  **Justificación Psicológica:** La validación empática refuerza comportamientos positivos de autenticidad emocional, creando un ciclo de retroalimentación que fortalece tanto la auto-conciencia como la intimidad en la relación.

- [ ] **Tarea 1.17: Consideraciones Especiales para Diseño Anti-Vigilancia**
  
  **Objetivo:** Asegurar que cada elemento de UI comunique empoderamiento personal en lugar de monitoreo o control.
  
  **Elementos de Diseño Anti-Vigilancia:**
  ```dart
  class AntiSurveillanceDesignPrinciples {
    // Principio 1: El usuario siempre tiene control visual sobre su información
    static Widget buildUserControlIndicator({
      required bool isUserInitiated,
      required DateTime lastUpdate,
    }) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isUserInitiated ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUserInitiated ? Icons.person : Icons.autorenew,
              size: 12,
              color: isUserInitiated ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 4),
            Text(
              isUserInitiated ? "Compartido por ti" : "Actualización automática",
              style: TextStyle(
                fontSize: 10,
                color: isUserInitiated ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
    
    // Principio 2: Transparencia total sobre qué datos se comparten
    static Widget buildDataTransparencyPanel(PrivacySettings settings) {
      return ExpansionTile(
        leading: Icon(Icons.visibility_outlined),
        title: Text("¿Qué información compartes?"),
        children: [
          _buildDataRow("Estado actual", settings.shareStatus),
          _buildDataRow("Espectro de ánimo", settings.shareMoodSpectrum),
          _buildDataRow("Notas contextuales", settings.shareContextNotes),
          _buildDataRow("Tiempo de actualización", settings.shareTimestamps),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Solo TÚ decides qué compartir y cuándo. Tu pareja nunca sabrá qué información has elegido mantener privada.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      );
    }
    
    // Principio 3: Claridad sobre la bidireccionalidad
    static Widget buildMutualityIndicator({
      required bool partnerIsSharing,
      required String partnerName,
    }) {
      return Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: partnerIsSharing ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: partnerIsSharing ? Colors.blue.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              partnerIsSharing ? Icons.swap_horiz : Icons.visibility_off,
              color: partnerIsSharing ? Colors.blue : Colors.grey,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerIsSharing 
                      ? "$partnerName también está compartiendo contigo"
                      : "$partnerName ha pausado el compartir",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    partnerIsSharing
                      ? "Ambos están eligiendo ser transparentes"
                      : "Respeta su decisión de privacidad",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
  ```
  
  **Lenguaje Visual Empoderador:**
  ```dart
  class EmpoweringUILanguage {
    static const Map<UIContext, String> empoweringLabels = {
      UIContext.statusSelection: "¿Cómo te gustaría aparecer?",
      UIContext.moodInput: "¿Cómo te sientes en este momento?",
      UIContext.contextNote: "¿Algo más que quieras compartir?",
      UIContext.privacySettings: "Tu control de privacidad",
      UIContext.updateConfirmation: "¿Confirmas que quieres compartir esto?",
      UIContext.pauseSharing: "Tomar un descanso de compartir",
    };
    
    static const Map<UIContext, String> nonSurveillanceTerms = {
      // En lugar de "tracking" -> "acompañando"
      UIContext.tracking: "Acompañando tu bienestar emocional",
      
      // En lugar de "monitoring" -> "conectando"
      UIContext.monitoring: "Manteniendo la conexión emocional",
      
      // En lugar de "data collection" -> "compartir voluntario"
      UIContext.dataCollection: "Tu decisión de compartir",
      
      // En lugar de "last seen" -> "última conexión"
      UIContext.lastSeen: "Última vez que eligió conectar",
    };
    
    static String getEmpoweringLabel(UIContext context) {
      return empoweringLabels[context] ?? "Título no encontrado";
    }
    
    static Widget buildEmpoweringButton({
      required String label,
      required VoidCallback onPressed,
      required bool isPrimary,
    }) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.blue : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      );
    }
  }
  ```
  
  **Justificación Psicológica:** El diseño anti-vigilancia es fundamental para mantener la sensación de autonomía y control personal, elementos esenciales para el bienestar psicológico en relaciones a distancia. La terminología y visual deben reforzar constantemente que el usuario está en control de su propia narrativa emocional.

---

## Estructura de Datos Recomendada para Appwrite

**Collection: `mood_compass_data`**
```json
{
  "$id": "unique_document_id",
  "$createdAt": "2024-01-15T10:30:00.000Z",
  "$updatedAt": "2024-01-15T10:30:00.000Z",
  "userId": "user_unique_id",
  "partnerId": "partner_unique_id", 
  "status": {
    "type": "available", // available | busy | resting | traveling
    "isManuallySet": true,
    "lastChanged": "2024-01-15T10:30:00.000Z"
  },
  "mood": {
    "energy": 0.7, // -1.0 to 1.0
    "positivity": 0.3, // -1.0 to 1.0
    "intensity": 0.8, // 0.0 to 1.0
    "confidence": 0.9 // 0.0 to 1.0 (how sure user is about their mood)
  },
  "contextNote": {
    "text": "Trabajando en un proyecto emocionante",
    "isShared": true,
    "sentiment": "positive" // AI-analyzed sentiment for additional context
  },
  "metadata": {
    "deviceId": "device_identifier",
    "appVersion": "1.0.0",
    "timezone": "America/Mexico_City",
    "isOfflineUpdate": false,
    "confidenceScore": 85 // 0-100 based on update patterns
  },
  "privacy": {
    "shareStatus": true,
    "shareMood": true,
    "shareContextNote": false,
    "shareTimestamp": true,
    "expiresAt": "2024-01-16T10:30:00.000Z" // optional expiration
  }
}
```

**Permisos Recomendados en Appwrite:**
```yaml
Collection Permissions:
  Read: 
    - "user:{userId}" # Solo el usuario puede leer sus propios datos
    - "user:{partnerId}" # La pareja puede leer según configuración de privacidad
  Write:
    - "user:{userId}" # Solo el usuario puede escribir sus propios datos
  Update:
    - "user:{userId}" # Solo el usuario puede actualizar sus datos
  Delete:
    - "user:{userId}" # Solo el usuario puede eliminar sus datos

Document Level Permissions:
  # Se aplicarán filtros adicionales basados en privacy settings
  # mediante Cloud Functions para determinar qué campos son visibles
```

**Collection: `relationship_settings`**
```json
{
  "$id": "relationship_unique_id",
  "userIds": ["user1_id", "user2_id"],
  "connectionStatus": "active", // active | paused | pending
  "mutualConsent": {
    "user1_id": {
      "agreedToShare": true,
      "agreedAt": "2024-01-15T10:30:00.000Z",
      "shareLevel": "full" // minimal | partial | full
    },
    "user2_id": {
      "agreedToShare": true, 
      "agreedAt": "2024-01-15T10:30:00.000Z",
      "shareLevel": "full"
    }
  },
  "preferences": {
    "notificationFrequency": "moderate", // minimal | moderate | frequent
    "reminderStyle": "gentle", // none | gentle | regular
    "hapticFeedback": true,
    "animationLevel": "full" // minimal | reduced | full
  }
}
````
