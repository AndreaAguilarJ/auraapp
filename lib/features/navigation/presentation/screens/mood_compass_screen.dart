import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../features/shared_space/domain/models/mood_compass_data.dart';
import '../../../../features/shared_space/presentation/widgets/status_selector_widget.dart';
import '../../../../features/shared_space/presentation/widgets/context_note_widget.dart';

/// Pantalla principal de la Brújula de Estado y Ánimo
class MoodCompassScreen extends StatefulWidget {
  const MoodCompassScreen({Key? key}) : super(key: key);

  @override
  State<MoodCompassScreen> createState() => _MoodCompassScreenState();
}

class _MoodCompassScreenState extends State<MoodCompassScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _updateController;

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _updateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _updateController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateMoodCompass() async {
    final provider = Provider.of<MoodCompassProvider>(context, listen: false);

    _updateController.forward().then((_) {
      _updateController.reset();
    });

    try {
      // Determinar qué estado de ánimo está seleccionado actualmente
      String? selectedMoodName;
      for (final entry in MoodCompassProvider.moodMap.entries) {
        if (provider.selectedMood.positivity == entry.value.positivity &&
            provider.selectedMood.energy == entry.value.energy) {
          selectedMoodName = entry.key;
          break;
        }
      }

      if (selectedMoodName == null) {
        throw Exception("Por favor, selecciona un estado de ánimo");
      }

      // Usar el nuevo método que acepta un nombre de estado de ánimo
      await provider.updateMoodCompassByName(
        moodName: selectedMoodName,
        contextNote: _noteController.text,
      );

      // Mostrar feedback al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Tu estado "$selectedMoodName" ha sido compartido'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Use ThemeData only

    return Consumer<MoodCompassProvider>(
      builder: (context, provider, child) {
        return FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la sección
                _buildSectionHeader(theme),
                const SizedBox(height: 24),
                // Estado actual si existe
                if (provider.currentData != null)
                  _buildCurrentStatus(theme, provider.currentData!),
                const SizedBox(height: 32),
                // Selector de estado
                _buildStatusSection(theme, provider),
                const SizedBox(height: 32),
                // Espectro de ánimo
                _buildMoodSection(theme, provider),
                const SizedBox(height: 32),
                // Nota contextual
                _buildContextNoteSection(theme),
                const SizedBox(height: 32),
                // Botón de actualización
                _buildUpdateButton(theme, provider),
                const SizedBox(height: 20), // Espacio adicional al final
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu Brújula Emocional',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Comparte tu estado y ánimo de forma voluntaria y auténtica',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.7 * 255).toInt()),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus(ThemeData theme, MoodCompassData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Última actualización: ${_formatTime(data.lastUpdated)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (data.contextNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${data.contextNote}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withAlpha((0.8 * 255).toInt()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusSection(ThemeData theme, MoodCompassProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te gustaría aparecer?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        StatusSelectorWidget(
          currentStatus: provider.selectedStatus,
          onStatusChanged: provider.setStatus,
        ),
      ],
    );
  }

  Widget _buildMoodSection(ThemeData theme, MoodCompassProvider provider) {
    // Lista de estados de ánimo disponibles (obtenidos del mapa definido en el provider)
    final moodNames = MoodCompassProvider.moodMap.keys.toList();

    // Estado para rastrear el estado de ánimo seleccionado actualmente
    String? _selectedMoodName;

    // Para cada estado de ánimo en el mapa, verificar si las coordenadas coinciden con el seleccionado actualmente
    for (final entry in MoodCompassProvider.moodMap.entries) {
      if (provider.selectedMood.positivity == entry.value.positivity &&
          provider.selectedMood.energy == entry.value.energy) {
        _selectedMoodName = entry.key;
        break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo te sientes en este momento?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el estado de ánimo que mejor represente cómo te sientes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
        const SizedBox(height: 16),

        // Wrap de botones de estados de ánimo
        Wrap(
          spacing: 8.0,
          runSpacing: 12.0,
          children: moodNames.map((moodName) {
            // Determinar si este estado de ánimo está seleccionado
            final isSelected = _selectedMoodName == moodName;

            // Obtener las coordenadas para este estado de ánimo para darle colores acordes
            final coordinates = MoodCompassProvider.moodMap[moodName]!
;
            // Determinar color basado en positividad (rojo para negativo, verde para positivo)
            final baseColor = coordinates.positivity > 0
                ? Color.lerp(Colors.yellow, Colors.green, (coordinates.positivity.abs() / 1.0))!
                : Color.lerp(Colors.orange, Colors.red, (coordinates.positivity.abs() / 1.0))!;

            // Determinar brillo basado en energía
            final brightness = coordinates.energy > 0 ? 1.0 : 0.7;

            return ElevatedButton(
              onPressed: () {
                // Cuando se presiona un botón, llamar a setMood con las coordenadas correspondientes
                provider.setMood(MoodCompassProvider.moodMap[moodName]!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? baseColor.withOpacity(0.7 * brightness)
                    : theme.colorScheme.surface.withAlpha((0.1 * 255).toInt()),
                foregroundColor: isSelected
                    ? Colors.white
                    : theme.colorScheme.onSurface,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? baseColor
                        : theme.colorScheme.onSurface.withAlpha((0.2 * 255).toInt()),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Agregar un ícono que represente el estado de ánimo
                  Icon(
                    _getMoodIcon(moodName),
                    size: 20,
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(moodName),
                  if (isSelected)
                    const SizedBox(width: 8),
                  if (isSelected)
                    const Icon(Icons.check, size: 18),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Helper para obtener un ícono apropiado para cada estado de ánimo
  IconData _getMoodIcon(String moodName) {
    switch (moodName) {
      case 'Feliz': return Icons.sentiment_very_satisfied;
      case 'Enérgico': return Icons.bolt;
      case 'Tranquilo': return Icons.spa;
      case 'Cansado': return Icons.bedtime;
      case 'Estresado': return Icons.psychology;
      case 'Triste': return Icons.sentiment_very_dissatisfied;
      case 'Enfadado': return Icons.whatshot;
      default: return Icons.mood;
    }
  }

  Widget _buildContextNoteSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Algo más que quieras compartir?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Opcional - Máximo 140 caracteres',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
        const SizedBox(height: 16),
        ContextNoteWidget(
          controller: _noteController,
          maxLength: 140,
        ),
      ],
    );
  }

  Widget _buildUpdateButton(ThemeData theme, MoodCompassProvider provider) {
    return AnimatedBuilder(
      animation: _updateController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_updateController.value * 0.05),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _updateMoodCompass,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Actualizar mi Aura',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
