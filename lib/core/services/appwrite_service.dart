import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Servicio principal para manejar la conexión con Appwrite
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  static AppwriteService get instance => _instance;
  AppwriteService._internal();

  late Client _client;
  late Account _account;
  late Databases _databases;
  late Storage _storage;
  late Realtime _realtime;

  // Getters para acceder a los servicios
  Client get client => _client;
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Realtime get realtime => _realtime;

  /// Inicializa la conexión con Appwrite siguiendo las recomendaciones oficiales
  Future<void> initialize() async {
    try {
      _client = Client()
          .setEndpoint(AppwriteConstants.endpoint)
          .setProject(AppwriteConstants.projectId);
      
      // Solo permitir certificados self-signed en desarrollo
      if (kDebugMode) {
        _client.setSelfSigned(status: true);
      }

      _account = Account(_client);
      _databases = Databases(_client);
      _storage = Storage(_client);
      _realtime = Realtime(_client);

      print('✅ Appwrite inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Appwrite: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario está autenticado
  Future<bool> isUserAuthenticated() async {
    try {
      final user = await _account.get();
      return user.$id.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene la sesión actual del usuario
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } catch (e) {
      print('Error obteniendo usuario actual: $e');
      return null;
    }
  }

  /// Prueba la conectividad con Appwrite
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 Probando conexión con Appwrite...');
        print('🌐 Endpoint: ${AppwriteConstants.endpoint}');
        print('🎯 Project ID: ${AppwriteConstants.projectId}');
      }

      // Intentar obtener información del proyecto
      await _account.get();

      if (kDebugMode) {
        print('✅ Conexión exitosa con Appwrite');
      }
      return true;
    } on AppwriteException catch (e) {
      if (kDebugMode) {
        print('❌ Error de Appwrite: ${e.message} (Código: ${e.code})');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error de conexión: $e');
      }
      return false;
    }
  }

  /// Maneja errores de Appwrite y los convierte en mensajes amigables
  String handleAppwriteError(dynamic error) {
    if (error is AppwriteException) {
      switch (error.code) {
        case 401:
          return 'Sesión expirada. Por favor, inicia sesión nuevamente.';
        case 404:
          return 'Recurso no encontrado.';
        case 429:
          return 'Demasiadas solicitudes. Intenta más tarde.';
        case 500:
          return 'Error del servidor. Intenta más tarde.';
        default:
          return error.message ?? 'Error desconocido.';
      }
    }
    return error.toString();
  }
}
