import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert'; // Agregar para JSON
import '../constants/app_constants.dart';
import '../error/failure.dart';
import 'auth_repository_interface.dart';

/// Implementación del repositorio de autenticación
class AuthRepository implements AuthRepositoryInterface {
  final Account _account;
  final Databases _databases;

  AuthRepository({
    required Account account,
    required Databases databases,
  })  : _account = account,
        _databases = databases;

  @override
  Future<Either<Failure, User>> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('➡️ Iniciando registro para: $email');

      // 1. CREAR EL USUARIO EN EL SERVICIO DE AUTH
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      print('✅ Usuario creado en Auth con ID: ${user.$id}');

      // 2. CREAR EL DOCUMENTO DE PERFIL EN LA BASE DE DATOS
      await _databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollectionId,
        documentId: user.$id, // Usar el ID del usuario de Auth como ID del documento
        data: {
          'name': name,
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
          'lastActiveAt': DateTime.now().toIso8601String(),
          'partnerId': null,
          'relationshipStatus': 'single',
          // Convertir preferences a JSON string porque el atributo es de tipo String
          'preferences': jsonEncode({
            'shareStatus': true,
            'shareMood': true,
            'shareContextNotes': false,
            'allowNotifications': true,
          }),
        },
      );

      print('✅ Documento de usuario creado exitosamente en la base de datos');

      return right(user);
    } on AppwriteException catch (e, stackTrace) {
      print('❌ Error de Appwrite en signUp: ${e.message}');
      return left(Failure(e.message ?? 'Error de autenticación', stackTrace));
    } catch (e, stackTrace) {
      print('❌ Error inesperado en signUp: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, Session>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      print('➡️ Iniciando sesión para: $email');

      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      print('✅ Sesión creada exitosamente');
      return right(session);
    } on AppwriteException catch (e, stackTrace) {
      print('❌ Error de Appwrite en signIn: ${e.message}');
      return left(Failure(e.message ?? 'Error de autenticación', stackTrace));
    } catch (e, stackTrace) {
      print('❌ Error inesperado en signIn: $e');
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await _account.get();
      return right(user);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.message ?? 'Error obteniendo usuario', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.message ?? 'Error cerrando sesión', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      await _account.get();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String userId,
    String? name,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) {
        updateData['name'] = name;
        // También actualizar en Appwrite Account
        await _account.updateName(name: name);
      }

      if (preferences != null) {
        updateData['preferences'] = preferences;
      }

      if (updateData.isNotEmpty) {
        updateData['lastActiveAt'] = DateTime.now().toIso8601String();

        await _databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollectionId,
          documentId: userId,
          data: updateData,
        );
      }

      return right(null);
    } on AppwriteException catch (e, stackTrace) {
      return left(Failure(e.message ?? 'Error actualizando perfil', stackTrace));
    } catch (e, stackTrace) {
      return left(Failure(e.toString(), stackTrace));
    }
  }
}
