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

  // 🔧 ENDPOINT CORREGIDO - Probando región de Europa Central
  static const String endpoint = 'https://nyc.cloud.appwrite.io/v1';

  // 🚨 NOTA: Si el problema persiste, debes verificar en tu consola de Appwrite
  // cuál es el endpoint correcto para tu región específica.
  // Posibles endpoints alternativos:
  // - https://cloud.appwrite.io/v1 (Región por defecto)
  // - https://us-east-1.appwrite.global/v1 (Estados Unidos Este)
  // - https://ap-southeast-1.appwrite.global/v1 (Asia Pacífico)

  // IDs de base de datos y colecciones
  static const String databaseId = 'aura-main-db';
  static const String usersCollectionId = 'users';
  static const String partnershipsCollectionId = 'partnerships';
  static const String moodEntriesCollectionId = 'mood_entries';
  static const String messagesCollectionId = 'messages';
  static const String thoughtPulsesCollectionId = 'thought_pulses';

  // IDs de buckets de storage
  static const String profilePhotosBucketId = 'profile-photos';
  static const String sharedMemoriesBucketId = 'shared-memories';
}
