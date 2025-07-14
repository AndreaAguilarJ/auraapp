import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../features/shared_space/presentation/screens/modern_aura_widget_screen.dart';
import 'mood_compass_screen.dart';
import 'partner_connection_screen.dart';
import 'profile_screen.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/mood_compass_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';

/// Pantalla principal de navegación de AURA
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _navController;
  late Animation<double> _navAnimation;

  @override
  void initState() {
    super.initState();

    _navController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _navAnimation = CurvedAnimation(
      parent: _navController,
      curve: Curves.easeInOut,
    );

    _navController.forward();
  }

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      // Animación sutil al cambiar tab
      _navController.reset();
      _navController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AuraTheme();
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).intimacyGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con información del usuario
              _buildHeader(theme, authProvider),

              // Contenido principal
              Expanded(
                child: FadeTransition(
                  opacity: _navAnimation,
                  child: _buildCurrentScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  Widget _buildHeader(AuraTheme theme, AuthProvider authProvider) {
    final user = authProvider.currentUser;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar del usuario
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: Theme.of(context).intimacyGradient,
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Información del usuario
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${user?.name ?? 'Usuario'}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
                Text(
                  _getConnectionStatusText(user),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withAlpha((0.7 * 255).toInt()),
                  ),
                ),
              ],
            ),
          ),

          // Estado de conexión
          _buildConnectionIndicator(theme, user),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(AuraTheme theme, user) {
    final hasPartner = user?.hasPartner ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: hasPartner
            ? Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt())
            : Colors.orange.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasPartner
              ? Theme.of(context).colorScheme.primary.withAlpha((0.3 * 255).toInt())
              : Colors.orange.withAlpha((0.3 * 255).toInt()),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPartner ? Icons.favorite : Icons.person_add,
            size: 16,
            color: hasPartner ? Theme.of(context).colorScheme.primary : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            hasPartner ? 'Conectado' : 'Sin pareja',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: hasPartner ? Theme.of(context).colorScheme.primary : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  String _getConnectionStatusText(user) {
    if (user?.hasPartner == true) {
      return 'Tu aura está conectada con tu pareja';
    } else {
      return 'Conecta con tu pareja para compartir tu aura';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const ModernAuraWidgetScreen();
      case 1:
        return const MoodCompassScreen();
      case 2:
        return const PartnerConnectionScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const ModernAuraWidgetScreen();
    }
  }

  Widget _buildBottomNavigation(AuraTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.1 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.radio_button_checked, 0),
              activeIcon: _buildNavIcon(Icons.radio_button_checked, 0, isActive: true),
              label: 'Aura',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.explore_outlined, 1),
              activeIcon: _buildNavIcon(Icons.explore, 1, isActive: true),
              label: 'Brújula',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.people_outline, 2),
              activeIcon: _buildNavIcon(Icons.people, 2, isActive: true),
              label: 'Conexión',
            ),
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.person_outline, 3),
              activeIcon: _buildNavIcon(Icons.person, 3, isActive: true),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index, {bool isActive = false}) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Theme.of(context).colorScheme.primary.withAlpha((0.1 * 255).toInt())
            : Colors.transparent,
      ),
      child: Icon(
        icon,
        size: 24,
      ),
    );
  }
}
