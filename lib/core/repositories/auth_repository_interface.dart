import 'package:appwrite/models.dart';
import 'package:dartz/dartz.dart';
import '../error/failure.dart';

/// Interfaz para el repositorio de autenticación
abstract class AuthRepositoryInterface {
  /// Registra un nuevo usuario y crea su documento en la base de datos
  Future<Either<Failure, User>> signUpUser({
    required String email,
    required String password,
    required String name,
  });

  /// Inicia sesión con email y contraseña
  Future<Either<Failure, Session>> signInUser({
    required String email,
    required String password,
  });

  /// Obtiene la cuenta del usuario actual
  Future<Either<Failure, User>> getCurrentUser();

  /// Cierra la sesión actual
  Future<Either<Failure, void>> signOut();

  /// Verifica si el usuario está autenticado
  Future<bool> isUserAuthenticated();

  /// Actualiza el perfil del usuario
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    String? name,
    Map<String, dynamic>? preferences,
  });
}
