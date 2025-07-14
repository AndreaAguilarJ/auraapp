/// Enumeración de estados posibles del usuario
enum UserStatus {
  available('available'),
  busy('busy'),
  resting('resting'),
  traveling('traveling'),
  offline('offline');

  const UserStatus(this.value);
  final String value;

  static UserStatus fromString(String value) {
    switch (value) {
      case 'available':
        return UserStatus.available;
      case 'busy':
        return UserStatus.busy;
      case 'resting':
        return UserStatus.resting;
      case 'traveling':
        return UserStatus.traveling;
      case 'offline':
        return UserStatus.offline;
      default:
        return UserStatus.available;
    }
  }

  String get displayName {
    switch (this) {
      case UserStatus.available:
        return 'Disponible';
      case UserStatus.busy:
        return 'Ocupado';
      case UserStatus.resting:
        return 'Descansando';
      case UserStatus.traveling:
        return 'Viajando';
      case UserStatus.offline:
        return 'Desconectado';
    }
  }

  /// Returns the string value used for storage
  String toStorageString() => value;

  String get description {
    switch (this) {
      case UserStatus.available:
        return 'Libre para conversar';
      case UserStatus.busy:
        return 'En algo importante';
      case UserStatus.resting:
        return 'Tomando un descanso';
      case UserStatus.traveling:
        return 'En movimiento';
      case UserStatus.offline:
        return 'No disponible';
    }
  }
}
