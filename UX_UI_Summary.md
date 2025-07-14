# Resumen de Pantallas y Widgets en Aura App

Este documento ofrece un análisis detallado de cada pantalla, objetos y widgets de la aplicación Aura (MVP), extraído de los archivos de especificaciones, implementación y diseño UX/UI.

---

## 1. Flujo de Navegación

### 1.1 Splash Screen
- **Objetivo**: Introducción de marca y carga inicial.
- **Componentes/UI**:
  - Logo central animado (fade-in).
  - Indicador de progreso (opcional).
- **Interacción**: Transición automática a la pantalla de navegación principal.

### 1.2 Main Navigation Screen (`MainNavigationScreen`)
- **Objetivo**: Punto de entrada al espacio compartido y al widget Aura.
- **Componentes/UI**:
  - Bottom Navigation Bar con íconos:
    - Brújula de Estado y Ánimo
    - Widget Aura
    - Configuración
  - Indicadores de notificación en pestañas.
  - Animaciones suaves de transición entre pestañas.
- **Interacción**: Tap para cambiar de sección.

---

## 2. El Espacio Compartido: Brújula de Estado y Ánimo

### 2.1 Pantalla `MoodCompassScreen`
- **Descripción**: Flujo completo para que el usuario seleccione y comparta su estado y ánimo.
- **Elementos/Widgets principales**:
  1. **StatusSelectorWidget**
     - Selector circular de disponibilidad (Disponible, Ocupado, Descansando, Viajando).
     - Animaciones de pulso y háptico.
  2. **MoodSpectrumWidget**
     - Selector bidimensional (Valencia × Energía) basado en el modelo circumplex.
     - Gradientes de color dinámicos en cuadrantes.
     - Animaciones de respiración al mantener la selección.
  3. **ContextNoteInputWidget**
     - Campo de texto expandible (máx. 140 caracteres).
     - Contador de caracteres y sugerencias contextuales según estado.
  4. **PrivacyControlPanel**
     - Control de visibilidad granular (Privado, Solo Pareja, Compartido).
     - Indicadores visuales de nivel de privacidad.
  5. **VoluntaryIndicatorWidget**
     - Refuerzo de acción voluntaria de compartir.
     - Animación sutil para mostrar que el usuario elige participar.
- **Estilos y animaciones**:
  - Fondo con gradiente dinámico que refleja el estado/humor.
  - Feedback háptico diferenciado por acción.
  - Transiciones y debounce para auto-guardado.

---

## 3. Widget Aura

### 3.1 Pantalla `AuraWidgetScreen`
- **Descripción**: Interfaz para visualizar en tiempo real el estado de la pareja y enviar expresiones de afecto.
- **Elementos/Widgets principales**:
  1. **DynamicCircularIndicator**
     - Representación circular del estado y ánimo del partner.
     - Sistema de colores basado en valencia energética.
     - Animaciones de transición suave entre cambios.
  2. **ThoughtButton**
     - Botón central "Pienso en ti" con animación de ondas y corazones.
     - Feedback háptico y cooldown de 5 minutos.
     - Estados de loading y confirmación visual.
  3. **FreshnessGlow**
     - Indicador de frescura temporal (half-life 15 minutos).
     - Gradientes de color y pulsos adicionales según inmediatez.
- **Estilos y animaciones**:
  - Transiciones fluidas al recibir nuevos datos.
  - Configuración de privacidad y notificaciones accesible.

---

## 4. Objetos y Componentes Compartidos

- **BottomNavigationBar**: Navegación principal.
- **Modelos de datos**:
  - `UserStatus`, `MoodSnapshot`, `ThoughtPulse`: definiciones de estado y pulsos.
- **Providers**:
  - `MoodCompassProvider`: gestión de estado y sincronización offline-first.
  - `AuraWidgetProvider` (extensión de `MoodCompassProvider`): carga de datos del partner.
- **Servicios Appwrite**:
  - `MoodSyncService`: métodos de stream y envío de datos.
  - Persistencia de documentos y reglas de seguridad.

---

## 5. Observaciones de UX/UI y Sugerencias de Mejora

1. **Onboarding Interactivo**
   - Agregar tutorial rápido al primer uso para explicar controles de privacidad.
2. **Retroalimentación Visual**
   - Incluir micro-animaciones al cambiar privacidad.
3. **Accesibilidad**
   - Contrastes y tamaños ajustables.
   - Etiquetas y descripciones para lectores de pantalla.
4. **Personalización**
   - Temas de color personalizables.
   - Opciones de frecuencia de refresco y animación.
5. **Historial y Analytics**
   - Pantalla de historial de estados y pulsos con gráficos ligeros.

---

*Documento generado para análisis de UX/UI y posibles mejoras en la aplicación Aura.*

