import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider principal de la aplicación para configuraciones globales
class AppProvider extends ChangeNotifier {
  // Configuraciones de la app
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _hapticsEnabled = true;
  String _selectedLanguage = 'es';
  
  // Estado de autenticación
  bool _isAuthenticated = false;
  String? _userId;
  String? _userEmail;
  
  // Estado de conexión
  bool _isOnline = true;
  bool _isAppwriteConnected = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get hapticsEnabled => _hapticsEnabled;
  String get selectedLanguage => _selectedLanguage;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  bool get isOnline => _isOnline;
  bool get isAppwriteConnected => _isAppwriteConnected;

  /// Inicializa el provider cargando configuraciones guardadas
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _hapticsEnabled = prefs.getBool('hapticsEnabled') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'es';
      
      notifyListeners();
    } catch (e) {
      print('Error inicializando AppProvider: $e');
    }
  }

  /// Cambia el tema de la aplicación
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    
    _isDarkMode = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  /// Habilita/deshabilita notificaciones
  Future<void> setNotificationsEnabled(bool value) async {
    if (_notificationsEnabled == value) return;
    
    _notificationsEnabled = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  /// Habilita/deshabilita feedback háptico
  Future<void> setHapticsEnabled(bool value) async {
    if (_hapticsEnabled == value) return;
    
    _hapticsEnabled = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticsEnabled', value);
  }

  /// Cambia el idioma de la aplicación
  Future<void> setLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;
    
    _selectedLanguage = languageCode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', languageCode);
  }

  /// Establece el estado de autenticación
  void setAuthenticationState({
    required bool isAuthenticated,
    String? userId,
    String? userEmail,
  }) {
    _isAuthenticated = isAuthenticated;
    _userId = userId;
    _userEmail = userEmail;
    notifyListeners();
  }

  /// Actualiza el estado de conexión a internet
  void setOnlineStatus(bool isOnline) {
    if (_isOnline == isOnline) return;
    
    _isOnline = isOnline;
    notifyListeners();
  }

  /// Actualiza el estado de conexión a Appwrite
  void setAppwriteConnectionStatus(bool isConnected) {
    if (_isAppwriteConnected == isConnected) return;
    
    _isAppwriteConnected = isConnected;
    notifyListeners();
  }

  /// Cierra sesión del usuario
  Future<void> logout() async {
    _isAuthenticated = false;
    _userId = null;
    _userEmail = null;
    notifyListeners();
    
    // Aquí puedes agregar lógica adicional de logout
    // como limpiar datos locales específicos del usuario
  }
}
