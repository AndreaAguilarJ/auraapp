import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/services/appwrite_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/realtime_sync_service.dart';
import 'shared/providers/app_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/mood_compass_provider.dart';
import 'shared/providers/activity_provider.dart';
import 'shared/providers/guided_conversation_provider.dart';
import 'shared/providers/conversation_invitation_provider.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/navigation/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive para storage local
  await Hive.initFlutter();
  
  // Inicializar servicios
  await AppwriteService.instance.initialize();
  await NotificationService().initialize(); // Usar nueva implementación
  await RealtimeSyncService.instance.initialize();

  runApp(const AuraApp());
}

class AuraApp extends StatelessWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(create: (context) => ActivityProvider()),
        ChangeNotifierProvider(
          create: (context) => MoodCompassProvider()..initialize(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GuidedConversationProvider>(
          create: (context) => GuidedConversationProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) =>
            previous ?? GuidedConversationProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ConversationInvitationProvider>(
          create: (context) => ConversationInvitationProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) =>
            previous ?? ConversationInvitationProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'AURA - Conexión Digital Auténtica',
        debugShowCheckedModeBanner: false,
        theme: AuraTheme.lightTheme,
        darkTheme: AuraTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: _CustomScrollBehavior(),
            child: child!,
          );
        },
      ),
    );
  }
}

/// Widget que determina qué pantalla mostrar basado en el estado de autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Mostrar loading mientras se verifica la autenticación
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si está autenticado, mostrar navegación principal
        if (authProvider.isAuthenticated) {
          return const MainNavigationScreen();
        }

        // Si no está autenticado, mostrar pantalla de login
        return const AuthScreen();
      },
    );
  }
}

/// Comportamiento de scroll personalizado para mejor UX
class _CustomScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return Scrollbar(
          controller: details.controller,
          child: child,
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return child;
    }
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics();
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}
