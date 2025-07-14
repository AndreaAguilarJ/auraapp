import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/theme/aura_constants.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import 'modern_aura_widget_screen.dart';

/// Pantalla de navegación principal con diseño moderno
class ModernNavigationScreen extends StatefulWidget {
  const ModernNavigationScreen({Key? key}) : super(key: key);

  @override
  State<ModernNavigationScreen> createState() => _ModernNavigationScreenState();
}

class _ModernNavigationScreenState extends State<ModernNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.favorite_rounded,
      activeIcon: Icons.favorite,
      label: 'Conexión',
      screen: const ModernAuraWidgetScreen(),
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      label: 'Estados',
      screen: const MoodCompassScreen(),
    ),
    NavigationItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
      label: 'Momentos',
      screen: const SharedMomentsScreen(),
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Ajustes',
      screen: const SettingsScreen(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: AuraAnimations.normal,
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: AuraAnimations.elastic,
    ));
    _fabController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: _buildModernBottomNav(theme),
      floatingActionButton: _buildContextualFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildModernBottomNav(ThemeData theme) {
    return Container(
      height: 80,
      margin: EdgeInsets.all(AuraSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;

            return _buildNavItem(theme, item, index, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    ThemeData theme,
    NavigationItem item,
    int index,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: AuraAnimations.normal,
          curve: AuraAnimations.easeInOut,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AuraSpacing.m,
          vertical: AuraSpacing.s,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Background indicator
                AnimatedContainer(
                  duration: AuraAnimations.normal,
                  width: isSelected ? 40 : 0,
                  height: isSelected ? 40 : 0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isSelected ? AppColors.primaryGradient : null,
                  ),
                ),
                // Icon
                AnimatedSwitcher(
                  duration: AuraAnimations.fast,
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    key: ValueKey(isSelected),
                    color: isSelected
                        ? Colors.white
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
            SizedBox(height: AuraSpacing.xs),
            AnimatedDefaultTextStyle(
              duration: AuraAnimations.fast,
              style: AuraTypography.labelSmall.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualFAB(ThemeData theme) {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: _getFABForCurrentPage(theme),
        );
      },
    );
  }

  Widget _getFABForCurrentPage(ThemeData theme) {
    switch (_currentIndex) {
      case 0: // Conexión
        return FloatingActionButton(
          onPressed: () => _showQuickActions(theme),
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add_rounded),
        );
      case 1: // Estados
        return FloatingActionButton(
          onPressed: () => _showMoodSelector(theme),
          backgroundColor: theme.colorScheme.secondary,
          child: const Icon(Icons.edit_rounded),
        );
      case 2: // Momentos
        return FloatingActionButton(
          onPressed: () => _createNewMoment(theme),
          backgroundColor: theme.colorScheme.tertiary,
          child: const Icon(Icons.camera_alt_rounded),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showQuickActions(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildQuickActionsSheet(theme),
    );
  }

  Widget _buildQuickActionsSheet(ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(AuraSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.only(top: AuraSpacing.m),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AuraSpacing.l),

          // Title
          Text(
            'Acciones rápidas',
            style: AuraTypography.headlineSmall,
          ),
          SizedBox(height: AuraSpacing.l),

          // Actions
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AuraSpacing.l),
            child: Column(
              children: [
                _buildQuickAction(
                  theme,
                  icon: Icons.psychology_rounded,
                  title: 'Enviar pensamiento',
                  subtitle: 'Deja saber que piensas en tu pareja',
                  gradient: AppColors.passionateGradient,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: AuraSpacing.m),
                _buildQuickAction(
                  theme,
                  icon: Icons.videocam_rounded,
                  title: 'Videollamada',
                  subtitle: 'Conecta cara a cara',
                  gradient: AppColors.joyfulGradient,
                  onTap: () => Navigator.pop(context),
                ),
                SizedBox(height: AuraSpacing.m),
                _buildQuickAction(
                  theme,
                  icon: Icons.message_rounded,
                  title: 'Mensaje especial',
                  subtitle: 'Envía algo único y personal',
                  gradient: AppColors.calmGradient,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: AuraSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AuraSpacing.m),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradient.colors.first.withValues(alpha: 0.1),
              gradient.colors.last.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: gradient.colors.first.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: AuraSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuraTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AuraTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodSelector(ThemeData theme) {
    print('🎭 Mostrando selector de estado de ánimo');
  }

  void _createNewMoment(ThemeData theme) {
    print('📸 Creando nuevo momento compartido');
  }
}

/// Modelo para los elementos de navegación
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}

/// Pantallas placeholder para las otras secciones
class MoodCompassScreen extends StatelessWidget {
  const MoodCompassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brújula Emocional'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(AuraSpacing.l),
          child: Padding(
            padding: EdgeInsets.all(AuraSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.psychology_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(height: AuraSpacing.m),
                Text(
                  'Pantalla de Estados',
                  style: AuraTypography.headlineSmall,
                ),
                Text(
                  'Aquí irá la Brújula de Estado y Ánimo',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SharedMomentsScreen extends StatelessWidget {
  const SharedMomentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentos Compartidos'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(AuraSpacing.l),
          child: Padding(
            padding: EdgeInsets.all(AuraSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 64,
                  color: theme.colorScheme.tertiary,
                ),
                SizedBox(height: AuraSpacing.m),
                Text(
                  'Momentos Especiales',
                  style: AuraTypography.headlineSmall,
                ),
                Text(
                  'Galería de recuerdos y experiencias compartidas',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Card(
          margin: EdgeInsets.all(AuraSpacing.l),
          child: Padding(
            padding: EdgeInsets.all(AuraSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.settings_rounded,
                  size: 64,
                  color: theme.colorScheme.secondary,
                ),
                SizedBox(height: AuraSpacing.m),
                Text(
                  'Configuración',
                  style: AuraTypography.headlineSmall,
                ),
                Text(
                  'Privacidad, notificaciones y personalización',
                  style: AuraTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
