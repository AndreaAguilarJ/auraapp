import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/modern_components.dart';
import '../../../../core/services/appwrite_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/guided_conversation/presentation/screens/conversation_invitation_screen.dart';
import 'package:appwrite/appwrite.dart';

/// Pantalla para gestionar la conexión con la pareja
class PartnerConnectionScreen extends StatefulWidget {
  const PartnerConnectionScreen({Key? key}) : super(key: key);

  @override
  State<PartnerConnectionScreen> createState() => _PartnerConnectionScreenState();
}

class _PartnerConnectionScreenState extends State<PartnerConnectionScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _codeInputController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _connectController;

  bool _isLoading = false;
  bool _isGeneratingCode = false;
  bool _isConnecting = false;
  String? _connectionCode;
  Timer? _refreshTimer; // Agregar timer para refrescar estado

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _connectController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController.forward();

    // Iniciar timer para refrescar estado cada 3 segundos cuando hay código generado
    _startRefreshTimer();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeInputController.dispose();
    _fadeController.dispose();
    _connectController.dispose();
    _refreshTimer?.cancel(); // Cancelar timer
    super.dispose();
  }

  /// Genera un código aleatorio de 6 caracteres
  String generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  /// Genera un código de conexión y lo guarda en Appwrite
  Future<void> _generateConnectionCode() async {
    setState(() => _isGeneratingCode = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _showMessage('Error: Usuario no autenticado', isError: true);
        return;
      }

      // Generar código único
      final code = generateRandomCode(6);
      final expiresAt = DateTime.now().add(const Duration(hours: 1));

      // Guardar en Appwrite usando constantes correctas
      final appwriteService = AppwriteService.instance;
      await appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId, // 'aura-main-db'
        collectionId: 'connection_codes',
        documentId: ID.unique(),
        data: {
          'userId': currentUser.id,
          'code': code,
          'expiresAt': expiresAt.toIso8601String(),
        },
      );

      setState(() {
        _connectionCode = code;
      });

      _showMessage('¡Código generado exitosamente! Válido por 1 hora');

    } catch (error) {
      print('Error generating connection code: $error');
      _showMessage('Error al generar código: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isGeneratingCode = false);
      }
    }
  }

  /// Vincula con la pareja usando el código introducido
  Future<void> _connectWithPartner() async {
    final code = _codeInputController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showMessage('Por favor ingresa un código', isError: true);
      return;
    }

    if (code.length != 6) {
      _showMessage('El código debe tener 6 caracteres', isError: true);
      return;
    }

    setState(() => _isConnecting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) {
        _showMessage('Error: Usuario no autenticado', isError: true);
        return;
      }

      final appwriteService = AppwriteService.instance;

      // Buscar el código en la base de datos usando constantes correctas
      final response = await appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId, // 'aura-main-db'
        collectionId: 'connection_codes',
        queries: [
          Query.equal('code', code),
        ],
      );

      if (response.documents.isEmpty) {
        _showMessage('Código no válido', isError: true);
        return;
      }

      final codeDocument = response.documents.first;
      final expiresAt = DateTime.parse(codeDocument.data['expiresAt']);

      // Verificar si el código ha expirado
      if (DateTime.now().isAfter(expiresAt)) {
        _showMessage('El código ha expirado', isError: true);
        // Limpiar código expirado
        await appwriteService.databases.deleteDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: 'connection_codes',
          documentId: codeDocument.$id,
        );
        return;
      }

      final partnerUserId = codeDocument.data['userId'];

      // Verificar que no se esté intentando conectar consigo mismo
      if (partnerUserId == currentUser.id) {
        _showMessage('No puedes conectarte contigo mismo', isError: true);
        return;
      }

      // Actualizar el partnerId del usuario actual (Usuario B)
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.id,
        data: {
          'partnerId': partnerUserId,
          'relationshipStatus': 'connected',
        },
      );

      // Actualizar el partnerId del usuario que generó el código (Usuario A)
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: partnerUserId,
        data: {
          'partnerId': currentUser.id,
          'relationshipStatus': 'connected',
        },
      );

      // Eliminar el código para que no se pueda reutilizar
      await appwriteService.databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: 'connection_codes',
        documentId: codeDocument.$id,
      );

      // Actualizar el estado local del usuario
      await authProvider.refreshUserData();

      _connectController.forward();
      _showMessage('¡Conexión exitosa! Ahora estás conectado con tu pareja 💕');

      // Limpiar el campo de código
      _codeInputController.clear();

    } catch (error) {
      print('Error connecting with partner: $error');
      _showMessage('Error al conectar: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  /// Copia el código al portapapeles
  Future<void> _copyCodeToClipboard() async {
    if (_connectionCode != null) {
      await Clipboard.setData(ClipboardData(text: _connectionCode!));
      _showMessage('Código copiado al portapapeles');
    }
  }

  /// Desconectar de la pareja
  Future<void> _disconnectPartner() async {
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null || currentUser.partnerId == null) {
        _showMessage('Error: No hay conexión para deshacer', isError: true);
        return;
      }

      final appwriteService = AppwriteService.instance;

      // Actualizar el usuario actual usando constantes correctas
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.id,
        data: {
          'partnerId': null,
          'relationshipStatus': 'single',
        },
      );

      // Actualizar la pareja usando constantes correctas
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.partnerId!,
        data: {
          'partnerId': null,
          'relationshipStatus': 'single',
        },
      );

      // Actualizar el estado local
      await authProvider.refreshUserData();

      _showMessage('Desconexión exitosa');

    } catch (error) {
      print('Error disconnecting partner: $error');
      _showMessage('Error al desconectar: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Muestra un diálogo de confirmación para desconectar
  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar desconexión'),
        content: const Text(
          '¿Estás seguro de que quieres desconectarte de tu pareja? '
              'Ambos dejarán de compartir información.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desconectar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _sendConnectionRequest() async {
    if (_emailController.text.isEmpty) {
      _showMessage('Por favor ingresa el email de tu pareja', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Simular envío de invitación
      await Future.delayed(const Duration(seconds: 2));

      _connectController.forward();
      _showMessage('¡Invitación enviada! Tu pareja recibirá una notificación');

    } catch (error) {
      _showMessage('Error al enviar invitación: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Inicia un timer para refrescar el estado del usuario periódicamente
  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        _checkConnectionStatus();
      }
    });
  }

  /// Detiene el timer de refresco
  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Verifica si el usuario se ha conectado con alguien
  Future<void> _checkConnectionStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null) return;

      // Refrescar datos del usuario desde la base de datos
      await authProvider.refreshUserData();

      // Si se detecta una conexión nueva, limpiar el código y detener el timer
      if (currentUser.partnerId == null && authProvider.currentUser?.partnerId != null) {
        setState(() {
          _connectionCode = null;
        });
        _stopRefreshTimer();
        _connectController.forward();
        _showMessage('¡Conexión exitosa! Tu pareja se ha conectado contigo 💕');
      }
    } catch (error) {
      print('Error checking connection status: $error');
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme),

            const SizedBox(height: 32),

            if (user?.partnerId != null) ...[
              // Ya conectado
              _buildConnectedSection(theme, user!),
            ] else ...[
              // No conectado - mostrar opciones de conexión
              _buildConnectionOptions(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conexión de Pareja',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Conecta con tu pareja para compartir vuestros momentos auténticos',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(179),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedSection(ThemeData theme, user) {
    return Column(
      children: [
        // Estado de conexión
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: theme.connectionGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withAlpha((0.2 * 255).toInt()),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.favorite,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                '💕 Conectado con ${user.partnerId}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vuestras auras están sincronizadas',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withAlpha(230),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Opciones de gestión
        _buildConnectionManagement(theme),

        const SizedBox(height: 32),

        // Sección de administración de pareja
        _buildPartnerManagementSection(theme),
      ],
    );
  }

  /// Nueva sección para gestionar la pareja
  Widget _buildPartnerManagementSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.manage_accounts,
                color: theme.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Administrar Conexión',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Si necesitas cambiar de pareja o resolver problemas de conexión, puedes eliminar la conexión actual.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),

          const SizedBox(height: 20),

          // Botón para pausar temporalmente
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _pauseConnection(),
              icon: const Icon(Icons.pause_circle_outline, size: 20),
              label: const Text(
                'Pausar conexión temporalmente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Botón para eliminar pareja permanentemente
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _removePartnerPermanently(),
              icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.person_remove, size: 20),
              label: Text(
                _isLoading ? 'Eliminando...' : 'Eliminar pareja',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pausa la conexión temporalmente
  Future<void> _pauseConnection() async {
    final confirmed = await _showPauseConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null || currentUser.partnerId == null) {
        _showMessage('Error: No hay conexión activa', isError: true);
        return;
      }

      final appwriteService = AppwriteService.instance;

      // Actualizar el estado a 'paused' en lugar de eliminar
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.id,
        data: {
          'relationshipStatus': 'paused',
        },
      );

      // Actualizar también a la pareja
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.partnerId!,
        data: {
          'relationshipStatus': 'paused',
        },
      );

      await authProvider.refreshUserData();
      _showMessage('Conexión pausada. Pueden reactivarla cuando quieran.');

    } catch (error) {
      print('Error pausing connection: $error');
      _showMessage('Error al pausar conexión: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Elimina la pareja permanentemente
  Future<void> _removePartnerPermanently() async {
    final confirmed = await _showRemovePartnerConfirmationDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser == null || currentUser.partnerId == null) {
        _showMessage('Error: No hay pareja para eliminar', isError: true);
        return;
      }

      final appwriteService = AppwriteService.instance;

      // Eliminar la conexión de ambos usuarios
      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.id,
        data: {
          'partnerId': null,
          'relationshipStatus': 'single',
        },
      );

      await appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: currentUser.partnerId!,
        data: {
          'partnerId': null,
          'relationshipStatus': 'single',
        },
      );

      await authProvider.refreshUserData();

      _showMessage('✅ Pareja eliminada exitosamente. Ahora puedes conectarte con alguien más.');

    } catch (error) {
      print('Error removing partner: $error');
      _showMessage('Error al eliminar pareja: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Diálogo de confirmación para pausar
  Future<bool> _showPauseConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pausar conexión'),
        content: const Text(
          '¿Quieres pausar temporalmente la conexión con tu pareja? '
          'Podrán reactivarla más tarde sin perder datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Pausar'),
          ),
        ],
      ),
    ) ?? false;
  }

  /// Diálogo de confirmación para eliminar pareja
  Future<bool> _showRemovePartnerConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Eliminar pareja'),
          ],
        ),
        content: const Text(
          '⚠️ ATENCIÓN: Esta acción eliminará permanentemente la conexión con tu pareja.\n\n'
          '• Se perderán todos los datos compartidos\n'
          '• Ambos quedarán como "single"\n'
          '• Podrás conectarte con alguien más después\n\n'
          '¿Estás completamente seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildConnectionOptions(ThemeData theme) {
    return Column(
      children: [
        // Opción 1: Generar código de invitación
        _buildGenerateCodeSection(theme),

        const SizedBox(height: 32),

        // Separador
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withAlpha(153),
                ),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: 32),

        // Opción 2: Introducir código de conexión
        _buildConnectWithCodeSection(theme),
      ],
    );
  }

  Widget _buildGenerateCodeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Generar código de invitación',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            'Genera un código único que tu pareja puede usar para conectarse contigo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isGeneratingCode ? null : _generateConnectionCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isGeneratingCode
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Generar mi código',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          if (_connectionCode != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tu código de conexión:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _connectionCode!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: theme.colorScheme.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Válido por 1 hora',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: _copyCodeToClipboard,
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copiar'),
                ),
                TextButton.icon(
                  onPressed: _generateConnectionCode,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Nuevo código'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectWithCodeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.link,
                color: theme.colorScheme.secondary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Conectar con código',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '¿Tu pareja ya tiene un código? Ingrésalo aquí para conectarte',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),

          const SizedBox(height: 20),

          ModernTextField(
            controller: _codeInputController,
            label: 'Código de conexión',
            prefixIcon: Icons.vpn_key,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isConnecting ? null : _connectWithPartner,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isConnecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Conectar con mi pareja',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionManagement(ThemeData theme) {
    return Column(
      children: [
        // NUEVO: Botón para Conversaciones Guiadas
        _buildManagementOption(
          theme,
          icon: Icons.psychology,
          title: '💫 Conversación Guiada',
          subtitle: 'Mejora vuestra comunicación con terapia de pareja',
          onTap: () => _startGuidedConversation(),
          isHighlight: true,
        ),
        const SizedBox(height: 12),
        _buildManagementOption(
          theme,
          icon: Icons.pause_circle_outline,
          title: 'Pausar compartir',
          subtitle: 'Toma un descanso temporal',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildManagementOption(
          theme,
          icon: Icons.settings_outlined,
          title: 'Configurar privacidad',
          subtitle: 'Ajusta qué información compartes',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildManagementOption(
          theme,
          icon: Icons.notifications_outlined,
          title: 'Notificaciones',
          subtitle: 'Personaliza cómo te avisamos',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildManagementOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isHighlight = false,
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
            color: isHighlight ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2),
            width: isHighlight ? 2 : 1,
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
                      color: theme.colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Inicia una conversación guiada
  void _startGuidedConversation() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user?.partnerId == null) {
      _showMessage('Error: Necesitas estar conectado con tu pareja para iniciar una conversación guiada', isError: true);
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConversationInvitationScreen(
          partnerUserId: user!.partnerId!,
          partnerName: user.partnerId!, // Aquí podrías obtener el nombre real de la pareja
        ),
      ),
    );
  }
}
