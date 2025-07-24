/// Constantes principales de la aplicación AURA
class AppConstants {
  // Información de la aplicación
  static const String appName = 'AURA';
  static const String appTagline = 'Conexión Digital Auténtica';
  static const String appVersion = '1.0.0';

  // URLs y recursos
  static const String privacyPolicyUrl = 'https://aura-app.com/privacy';
  static const String termsOfServiceUrl = 'https://aura-app.com/terms';
  static const String supportEmail = 'support@aura-app.com';
}

/// Constantes específicas de Appwrite
class AppwriteConstants {
  // 🎯 Tu Project ID específico
  static const String projectId = '686d2d9000167c367a6d';

  // 🔧 ENDPOINT PRINCIPAL - Usando el endpoint principal de Appwrite Cloud
  static const String endpoint = 'https://nyc.cloud.appwrite.io/v1';

  // 🚨 NOTA: Si sigues teniendo problemas, verifica en tu consola de Appwrite
  // cuál es el endpoint correcto para tu región específica.
  // Otros endpoints posibles:
  // - https://nyc.cloud.appwrite.io/v1 (Nueva York)
  // - https://us-east-1.appwrite.global/v1 (Estados Unidos Este)
  // - https://eu-central-1.appwrite.global/v1 (Europa Central)

  // IDs de base de datos y colecciones
  static const String databaseId = 'aura-main-db';
  static const String usersCollectionId = 'users';
  static const String partnershipsCollectionId = 'partnerships';
  static const String messagesCollectionId = 'messages';
  static const String thoughtPulsesCollectionId = 'thought_pulses';
  static const String moodCollectionId = 'Mood_Snapshots';
  static const String activitiesCollectionId = 'activities'; // Nueva colección agregada
  static const String guidedConversationsCollectionId = 'guided_conversations'; // Conversaciones Guiadas

  // IDs de buckets de storage
  static const String profilePhotosBucketId = 'profile-photos';
  static const String sharedMemoriesBucketId = 'shared-memories';
}
