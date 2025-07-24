import 'package:appwrite/appwrite.dart';
import '../../../../core/services/appwrite_service.dart';
import '../../../../core/constants/appwrite_constants.dart';
import '../../domain/models/conversation_invitation.dart';

class ConversationInvitationRepository {
  final AppwriteService _appwriteService = AppwriteService();
  static const String collectionId = AppwriteConstants.conversationInvitationsCollectionId;

  /// Crear una nueva invitación
  Future<ConversationInvitation> createInvitation(ConversationInvitation invitation) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: invitation.toMap(),
      );

      return ConversationInvitation.fromMap(response.data);
    } catch (e) {
      throw Exception('Error al crear invitación: $e');
    }
  }

  /// Obtener invitaciones pendientes para un usuario
  Future<List<ConversationInvitation>> getPendingInvitations(String userId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('toUserId', userId),
          Query.equal('status', 'pending'),
          Query.greaterThan('expiresAt', DateTime.now().toIso8601String()),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => ConversationInvitation.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener invitaciones: $e');
    }
  }

  /// Obtener invitaciones enviadas por un usuario
  Future<List<ConversationInvitation>> getSentInvitations(String userId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('fromUserId', userId),
          Query.orderDesc('\$createdAt'),
          Query.limit(20),
        ],
      );

      return response.documents
          .map((doc) => ConversationInvitation.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener invitaciones enviadas: $e');
    }
  }

  /// Actualizar el estado de una invitación
  Future<ConversationInvitation> updateInvitationStatus(
    String invitationId,
    String status, {
    String? responseMessage,
  }) async {
    try {
      final updateData = {
        'status': status,
        'respondedAt': DateTime.now().toIso8601String(),
      };

      if (responseMessage != null) {
        updateData['responseMessage'] = responseMessage;
      }

      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: invitationId,
        data: updateData,
      );

      return ConversationInvitation.fromMap(response.data);
    } catch (e) {
      throw Exception('Error al actualizar invitación: $e');
    }
  }

  /// Verificar si ya existe una invitación pendiente entre dos usuarios
  Future<ConversationInvitation?> getExistingInvitation(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('fromUserId', fromUserId),
          Query.equal('toUserId', toUserId),
          Query.equal('status', 'pending'),
          Query.greaterThan('expiresAt', DateTime.now().toIso8601String()),
        ],
      );

      if (response.documents.isNotEmpty) {
        return ConversationInvitation.fromMap(response.documents.first.data);
      }

      return null;
    } catch (e) {
      throw Exception('Error al verificar invitación existente: $e');
    }
  }

  /// Marcar invitaciones expiradas
  Future<void> markExpiredInvitations() async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.equal('status', 'pending'),
          Query.lessThan('expiresAt', DateTime.now().toIso8601String()),
        ],
      );

      for (final doc in response.documents) {
        await _appwriteService.databases.updateDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: collectionId,
          documentId: doc.$id,
          data: {
            'status': 'expired',
            'respondedAt': DateTime.now().toIso8601String(),
          },
        );
      }
    } catch (e) {
      throw Exception('Error al marcar invitaciones expiradas: $e');
    }
  }

  /// Eliminar una invitación
  Future<void> deleteInvitation(String invitationId) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: invitationId,
      );
    } catch (e) {
      throw Exception('Error al eliminar invitación: $e');
    }
  }

  /// Suscribirse a cambios en tiempo real de invitaciones
  Stream<RealtimeMessage> subscribeToInvitations(String userId) {
    return _appwriteService.realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.$collectionId.documents'
    ]).stream.where((message) {
      final data = message.payload;
      return data['toUserId'] == userId || data['fromUserId'] == userId;
    });
  }
}
