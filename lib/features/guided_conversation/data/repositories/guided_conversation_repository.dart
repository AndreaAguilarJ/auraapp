import 'dart:async';
import 'package:appwrite/appwrite.dart';
import '../../../../core/services/appwrite_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/guided_conversation.dart';

class GuidedConversationRepository {
  final AppwriteService _appwriteService = AppwriteService.instance;

  static const String collectionId = AppwriteConstants.guidedConversationsCollectionId;

  /// Crear una nueva conversación guiada
  Future<GuidedConversation> createConversation(GuidedConversation conversation) async {
    try {
      final response = await _appwriteService.databases.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: conversation.toMap(),
      );

      return GuidedConversation.fromMap(response.data);
    } catch (e) {
      throw Exception('Error al crear conversación: $e');
    }
  }

  /// Obtener una conversación por ID
  Future<GuidedConversation> getConversation(String conversationId) async {
    try {
      final response = await _appwriteService.databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: conversationId,
      );

      return GuidedConversation.fromMap(response.data);
    } catch (e) {
      throw Exception('Error al obtener conversación: $e');
    }
  }

  /// Actualizar una conversación
  Future<GuidedConversation> updateConversation(
    String conversationId,
    Map<String, dynamic> data
  ) async {
    try {
      final response = await _appwriteService.databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: conversationId,
        data: data,
      );

      return GuidedConversation.fromMap(response.data);
    } catch (e) {
      throw Exception('Error al actualizar conversación: $e');
    }
  }

  /// Obtener conversaciones activas de un usuario
  Future<List<GuidedConversation>> getActiveConversations(String userId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.and([
            Query.or([
              Query.equal('initiatorUserId', userId),
              Query.equal('partnerUserId', userId),
            ]),
            Query.equal('status', 'active'),
          ]),
        ],
      );

      return response.documents
          .map((doc) => GuidedConversation.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener conversaciones activas: $e');
    }
  }

  /// Obtener historial de conversaciones de un usuario
  Future<List<GuidedConversation>> getConversationHistory(String userId) async {
    try {
      final response = await _appwriteService.databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        queries: [
          Query.and([
            Query.or([
              Query.equal('initiatorUserId', userId),
              Query.equal('partnerUserId', userId),
            ]),
            Query.equal('status', 'completed'),
          ]),
          Query.orderDesc('\$createdAt'),
        ],
      );

      return response.documents
          .map((doc) => GuidedConversation.fromMap(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener historial: $e');
    }
  }

  /// Suscribirse a cambios en tiempo real de una conversación
  StreamSubscription<RealtimeMessage> subscribeToConversation(
    String conversationId,
    Function(GuidedConversation) onUpdate,
  ) {
    return _appwriteService.realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.$collectionId.documents.$conversationId'
    ]).stream.listen((response) {
      if (response.events.contains('databases.*.collections.*.documents.*.update')) {
        final conversation = GuidedConversation.fromMap(response.payload);
        onUpdate(conversation);
      }
    });
  }

  /// Eliminar una conversación (solo para casos especiales)
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _appwriteService.databases.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: collectionId,
        documentId: conversationId,
      );
    } catch (e) {
      throw Exception('Error al eliminar conversación: $e');
    }
  }
}
