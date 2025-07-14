# AURA - Aplicación para Parejas a Distancia

Aplicación móvil Flutter que facilita la conexión emocional entre parejas a distancia mediante transparencia voluntaria y presencia digital sin vigilancia.

## 🎯 Filosofía Central

AURA se fundamenta en el principio de **transparencia voluntaria** sobre vigilancia forzada. La aplicación empodera a los usuarios para compartir solo lo que desean compartir, creando valor mediante facilitación del intercambio emocional significativo.

## 📱 Funcionalidades MVP

### 1. Brújula de Estado y Ánimo
- Selección de estado: Disponible, Ocupado, Descansando, Viajando
- Selector bidimensional de ánimo (energía/positividad)
- Notas contextuales opcionales (140 caracteres)
- **NO utiliza GPS** ni seguimiento de ubicación

### 2. Widget "Aura"
- Visualización circular dinámica del estado de la pareja
- Colores e intensidades basados en estados emocionales
- Botón "Pienso en ti" para notificaciones no intrusivas
- Animaciones que indican "frescura" de actualizaciones

## 🏗️ Arquitectura

### Frontend
- **Flutter & Dart** - Desarrollo multiplataforma
- **Provider** - Gestión de estado reactivo
- **Material Design 3** - Sistema de diseño moderno

### Backend
- **Appwrite** - Autenticación y base de datos
- **Appwrite Realtime** - Sincronización en tiempo real
- **Appwrite Functions** - Lógica de servidor

### Privacidad y Seguridad
- ✅ Sin recopilación de GPS/ubicación
- ✅ Cifrado de extremo a extremo para datos sensibles
- ✅ Almacenamiento local prioritario
- ✅ Control granular de permisos

## 🚀 Configuración del Proyecto

### Prerrequisitos
- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0
- Appwrite Cloud o instancia local
- Android Studio / VS Code

### Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd aura_app
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar Appwrite**
   ```bash
   # Configurar variables de entorno
   # Actualizar app_constants.dart con tu Project ID
   ```

4. **Ejecutar la aplicación**
   ```bash
   # Desarrollo
   flutter run
   
   # Release
   flutter run --release
   ```

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/           # Constantes de la aplicación
│   ├── services/           # Servicios (Appwrite, Notificaciones)
│   └── utils/              # Utilidades y helpers
├── features/
│   └── shared_space/       # MVP: El Espacio Compartido
│       ├── data/           # Modelos y repositorios
│       ├── domain/         # Entidades y casos de uso
│       └── presentation/   # UI, widgets y providers
├── shared/
│   ├── providers/          # Providers globales
│   ├── theme/              # Tema y estilos
│   └── widgets/            # Widgets reutilizables
└── main.dart
```

## 🔧 Dependencias Principales

### Core
- `appwrite: ^11.0.1` - Backend completo con Appwrite
- `provider: ^6.1.1` - Gestión de estado
- `hive: ^2.2.3` - Storage local y cache

### Estado y UI
- `provider: ^6.1.1` - Gestión de estado
- `flutter_local_notifications: ^16.3.0` - Notificaciones locales
- `connectivity_plus: ^5.0.2` - Estado de conectividad

### Persistencia
- `shared_preferences: ^2.2.2` - Configuraciones
- `hive: ^2.2.3` - Cache estructurado

## 🎨 Sistema de Diseño

### Colores Principales
- **Primary Blue**: `#4A90E2` - Confianza y conexión
- **Primary Purple**: `#9B59B6` - Intimidad y creatividad
- **Primary Teal**: `#1ABC9C` - Serenidad y equilibrio

### Estados de Ánimo
- **Alta energía + Positivo**: Dorado (`#FFD700`)
- **Alta energía + Negativo**: Rojo (`#E74C3C`)
- **Baja energía + Positivo**: Verde (`#27AE60`)
- **Baja energía + Negativo**: Gris azulado (`#34495E`)

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Tests de integración
flutter test integration_test/

# Análisis de código
flutter analyze
```

## 📋 Tareas de Desarrollo

### Sprint 1: Base y Brújula de Estado
- [x] Configuración inicial del proyecto
- [x] Servicios de Appwrite y notificaciones
- [x] Provider para gestión de estado de ánimo
- [x] UI de la Brújula de Estado y Ánimo
- [ ] Validaciones y manejo de errores
- [ ] Tests unitarios

### Sprint 2: Widget Aura
- [x] Provider para estado de pareja
- [x] Widget circular dinámico
- [x] Sistema de "Pienso en ti"
- [ ] Animaciones de frescura
- [ ] Widget de pantalla de inicio
- [ ] Tests de integración

### Sprint 3: Pulido y Optimización
- [ ] Optimizaciones de rendimiento
- [ ] Mejoras de UX/UI
- [ ] Documentación completa
- [ ] Preparación para beta testing

## 🔒 Consideraciones de Privacidad

### Datos que SÍ recopilamos
- Estado de disponibilidad (voluntario)
- Ánimo bidimensional (voluntario)
- Notas contextuales (voluntarias, 140 chars max)
- Metadatos de tiempo para sincronización

### Datos que NO recopilamos
- ❌ Ubicación GPS
- ❌ Contactos del dispositivo
- ❌ Historial de navegación
- ❌ Datos de terceras aplicaciones
- ❌ Conversaciones privadas

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver `LICENSE` para más detalles.

## 🤝 Contribuir

1. Fork el proyecto
2. Crear rama de feature (`git checkout -b feature/AmazingFeature`)
3. Commit cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir Pull Request

## 📞 Soporte

Para soporte técnico o preguntas sobre el proyecto:
- 📧 Email: soporte@aura-app.com
- 📱 Twitter: @AuraAppOfficial
- 🌐 Website: https://aura-app.com

---

**AURA** - Conexión digital auténtica para parejas a distancia 💕
