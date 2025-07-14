import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../features/shared_space/domain/models/mood_compass_data.dart';
import '../../../../features/shared_space/presentation/widgets/status_selector_widget.dart';
import '../../../../features/shared_space/presentation/widgets/mood_spectrum_widget.dart';
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
      await provider.updateMoodCompass(
        contextNote: _noteController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Tu aura ha sido actualizada'),
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
          'Toca y arrastra para expresar tu energía y positividad',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: MoodSpectrumWidget(
            currentMood: provider.selectedMood,
            onMoodChanged: provider.setMood,
          ),
        ),
      ],
    );
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
