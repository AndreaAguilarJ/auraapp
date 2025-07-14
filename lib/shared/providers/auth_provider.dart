import 'package:flutter/foundation.dart';
import 'package:appwrite/appwrite.dart';
import 'package:aura_app/core/repositories/auth_repository.dart';
import 'package:aura_app/core/services/appwrite_service.dart';
import 'package:aura_app/core/constants/app_constants.dart';
import 'package:aura_app/features/shared_space/domain/models/user_model.dart';

/// Proveedor de estado para la autenticación de usuarios
class AuthProvider extends ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService.instance;
  late final AuthRepository _authRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // Implementación de Singleton para acceso global
  static AuthProvider? _instance;
  static AuthProvider? get instance => _instance;

  // Constructor que puede establecer la instancia singleton
  AuthProvider() {
    _instance = this;
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  /// Inicializa el proveedor y configura el repositorio
  Future<void> initialize() async {
    _setLoading(true);

    try {
      // Inicializar el repositorio con las dependencias de Appwrite
      _authRepository = AuthRepository(
        account: _appwriteService.account,
        databases: _appwriteService.databases,
      );

      print('🔄 Verificando sesión existente...');

      final isAuthenticated = await _authRepository.isUserAuthenticated();
      if (isAuthenticated) {
        print('✅ Sesión activa encontrada');
        await _loadCurrentUser();
        _isAuthenticated = true; // Asegurar que el estado se establezca correctamente
        print('✅ Usuario cargado desde sesión existente');
      } else {
        print('❌ No hay sesión activa');
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      print('❌ Error al verificar sesión: $e');
      _setError('Error al verificar sesión: $e');
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Inicia sesión con email y contraseña usando el repositorio
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('➡️ Intentando iniciar sesión para: $email');

      final result = await _authRepository.signInUser(
        email: email,
        password: password,
      );

      result.fold(
        (failure) {
          print('❌ Error en signIn: ${failure.message}');
          _setError('Error al iniciar sesión: ${_parseError(failure.message)}');
          throw Exception(failure.message);
        },
        (session) async {
          print('✅ ¡Éxito! Sesión creada para: $email');
          await _loadCurrentUser();
          _isAuthenticated = true;
          notifyListeners();
        },
      );
    } catch (e) {
      print('--- 🚨 ERROR INESPERADO (SIGN IN) 🚨 ---');
      print(e.toString());
      print('---------------------------------------');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Registra un nuevo usuario usando el repositorio
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('➡️ Intentando crear cuenta para: $email');

      final result = await _authRepository.signUpUser(
        email: email,
        password: password,
        name: name,
      );

      result.fold(
        (failure) {
          print('❌ Error en signUp: ${failure.message}');
          _setError('Error al crear cuenta: ${_parseError(failure.message)}');
          throw Exception(failure.message);
        },
        (account) async {
          print('✅ Cuenta creada exitosamente para: $email');
          print('📝 User ID: ${account.$id}');

          // Crear sesión automáticamente
          await _appwriteService.account.createEmailPasswordSession(
            email: email,
            password: password,
          );

          print('✅ Sesión iniciada automáticamente');

          await _loadCurrentUser();
          _isAuthenticated = true;
          notifyListeners();
        },
      );
    } catch (e) {
      print('--- 🚨 ERROR INESPERADO (SIGN UP) 🚨 ---');
      print(e.toString());
      print('--------------------------------------');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra la sesión del usuario usando el repositorio
  Future<void> signOut() async {
    _setLoading(true);

    try {
      final result = await _authRepository.signOut();

      result.fold(
        (failure) {
          _setError('Error al cerrar sesión: ${failure.message}');
        },
        (_) {
          _currentUser = null;
          _isAuthenticated = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carga la información del usuario actual
  Future<void> _loadCurrentUser() async {
    try {
      final account = await _appwriteService.account.get();

      // Verificar que el account no sea nulo antes de acceder a sus propiedades
      if (account != null) {
        print('Documento se cargará con el ID: ${account.$id}');
        // Obtener información adicional del usuario desde la base de datos
        final userDoc = await _appwriteService.databases.getDocument(
          databaseId: AppwriteConstants.databaseId, // Usar constante correcta
          collectionId: AppwriteConstants.usersCollectionId, // Usar constante correcta
          documentId: account.$id, // ID dinámico del usuario autenticado
        );
        _currentUser = UserModel.fromAppwriteDocument(userDoc);
        _isAuthenticated = true;
        print('✅ Usuario cargado correctamente: ${_currentUser!.name}');
      } else {
        print('Error: El usuario es nulo, no se puede cargar el documento.');
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      print('❌ Error cargando usuario: $e');
      _currentUser = null;
      _isAuthenticated = false;
    }
  }

  /// Actualiza el perfil del usuario usando el repositorio
  Future<void> updateProfile({
    String? name,
    Map<String, dynamic>? preferences,
  }) async {
    if (_currentUser == null) return;

    _setLoading(true);

    try {
      final result = await _authRepository.updateUserProfile(
        userId: _currentUser!.id,
        name: name,
        preferences: preferences,
      );

      result.fold(
        (failure) {
          _setError('Error actualizando perfil: ${failure.message}');
        },
        (_) async {
          await _loadCurrentUser();
        },
      );
    } catch (e) {
      _setError('Error actualizando perfil: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresca los datos del usuario actual desde la base de datos
  Future<void> refreshUserData() async {
    try {
      await _loadCurrentUser();
      print('✅ Datos del usuario actualizados correctamente');
    } catch (e) {
      print('❌ Error refrescando datos del usuario: $e');
    }
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia el mensaje de error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Parsea errores para mostrar mensajes más amigables
  String _parseError(String errorMessage) {
    final errorString = errorMessage.toLowerCase();

    if (errorString.contains('invalid credentials')) {
      return 'Email o contraseña incorrectos';
    } else if (errorString.contains('user already exists')) {
      return 'Ya existe una cuenta con este email';
    } else if (errorString.contains('password')) {
      return 'La contraseña debe tener al menos 8 caracteres';
    } else if (errorString.contains('email')) {
      return 'Por favor ingresa un email válido';
    } else {
      return 'Error de conexión. Intenta nuevamente';
    }
  }
}
