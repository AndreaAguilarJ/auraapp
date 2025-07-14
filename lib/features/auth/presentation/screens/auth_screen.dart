import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';
import '../../../../core/constants/app_constants.dart';

/// Pantalla de autenticación con diseño empático y moderno
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;

  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });

    _slideController.forward().then((_) {
      _slideController.reset();
    });
  }

  Future<void> _submitAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('Por favor completa todos los campos', isError: true);
      return;
    }

    if (!_isLogin && _nameController.text.isEmpty) {
      _showMessage('Por favor ingresa tu nombre', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (_isLogin) {
        await authProvider.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await authProvider.signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
        );
      }

      // ¡SOLUCIÓN! Verificar si el widget sigue montado antes de usar context
      if (!mounted) return;

      // Ahora es seguro mostrar mensaje de éxito
      _showMessage(_isLogin ? '¡Bienvenido de vuelta!' : '¡Cuenta creada exitosamente!');
    } catch (error) {
      // También verificar mounted antes de mostrar errores
      if (!mounted) return;
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    // Añadir verificación mounted por seguridad adicional
    if (!mounted) return;

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).intimacyGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: SingleChildScrollView(  // 🎯 SOLUCIÓN: Añadir SingleChildScrollView
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom - 48, // Ajustar por padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo y título
                      _buildHeader(theme),

                      const SizedBox(height: 48),

                      // Formulario de autenticación
                      _buildAuthForm(theme),

                      const SizedBox(height: 24),

                      // Botón de acción
                      _buildActionButton(theme),

                      const SizedBox(height: 16),

                      // Toggle entre login/registro
                      _buildToggleButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Logo animado
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: theme.intimacyGradient,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha((0.3 * 255).toInt()),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          AppConstants.appName,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onBackground,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          AppConstants.appTagline,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onBackground.withAlpha((0.7 * 255).toInt()),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthForm(ThemeData theme) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideController.value * 10),
          child: Column(
            children: [
              if (!_isLogin) ...[
                ModernTextField(
                  controller: _nameController,
                  label: 'Tu nombre',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
              ],

              ModernTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: _passwordController,
                label: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitAuth,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isLogin ? 'Conectar' : 'Crear cuenta',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleAuthMode,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: _isLogin
                  ? '¿No tienes cuenta? '
                  : '¿Ya tienes cuenta? ',
            ),
            TextSpan(
              text: _isLogin ? 'Crear una' : 'Iniciar sesión',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
