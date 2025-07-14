import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla de perfil y configuraciones del usuario
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  final _nameController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();

    // Cargar datos del usuario
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController.text = authProvider.currentUser?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      _showMessage('Por favor ingresa tu nombre', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(name: _nameController.text);

      setState(() => _isEditing = false);
      _showMessage('Perfil actualizado correctamente');

    } catch (error) {
      _showMessage('Error al actualizar perfil: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del perfil
                _buildProfileHeader(theme, user),

                const SizedBox(height: 32),

                // Información del perfil
                _buildProfileInfo(theme, user),

                const SizedBox(height: 32),

                // Configuraciones
                _buildSettingsSection(theme),

                const SizedBox(height: 32),

                // Botón de cerrar sesión
                _buildSignOutButton(theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: theme.intimacyGradient,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Información básica
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Usuario',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withAlpha((0.7 * 255).toInt()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: user?.hasPartner == true
                          ? Colors.green.withAlpha((0.1 * 255).toInt())
                          : Colors.orange.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: user?.hasPartner == true
                            ? Colors.green.withAlpha((0.3 * 255).toInt())
                            : Colors.orange.withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    child: Text(
                      user?.relationshipStatus.displayName ?? 'Estado desconocido',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: user?.hasPartner == true ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileInfo(ThemeData theme, user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withAlpha((0.2 * 255).toInt()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Información personal',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditing = !_isEditing;
                    if (!_isEditing) {
                      _nameController.text = user?.name ?? '';
                    }
                  });
                },
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          if (_isEditing) ...[
            ModernTextField(
              controller: _nameController,
              label: 'Nombre',
              prefixIcon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _nameController.text = user?.name ?? '';
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ] else ...[
            _buildInfoRow(theme, 'Nombre', user?.name ?? 'No especificado'),
            const SizedBox(height: 12),
            _buildInfoRow(theme, 'Email', user?.email ?? 'No especificado'),
            const SizedBox(height: 12),
            _buildInfoRow(
              theme,
              'Miembro desde',
              user?.createdAt != null
                  ? _formatDate(user!.createdAt)
                  : 'Fecha desconocida'
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuraciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 16),

        _buildSettingOption(
          theme,
          icon: Icons.privacy_tip_outlined,
          title: 'Privacidad y datos',
          subtitle: 'Controla qué información compartes',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _buildSettingOption(
          theme,
          icon: Icons.notifications_outlined,
          title: 'Notificaciones',
          subtitle: 'Personaliza cómo te avisamos',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _buildSettingOption(
          theme,
          icon: Icons.palette_outlined,
          title: 'Apariencia',
          subtitle: 'Tema y personalización',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _buildSettingOption(
          theme,
          icon: Icons.help_outline,
          title: 'Ayuda y soporte',
          subtitle: 'Obtén ayuda o envía feedback',
          onTap: () {},
        ),

        const SizedBox(height: 12),

        _buildSettingOption(
          theme,
          icon: Icons.info_outline,
          title: 'Acerca de AURA',
          subtitle: 'Versión 1.0.0',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha((0.2 * 255).toInt()),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withAlpha((0.4 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: _signOut,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withAlpha((0.5 * 255).toInt())),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];

    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}
