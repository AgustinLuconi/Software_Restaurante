import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'router.dart';
import 'service_locator.dart';

void main() async {
  // Asegurar que los widgets estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase (verificar si ya está inicializado para evitar error en hot restart)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase ya está inicializado (ocurre en hot restart)
    if (e.toString().contains('already exists')) {
      // Ignorar - ya está inicializado
    } else {
      rethrow;
    }
  }
  
  // Inicializar el service locator (GetIt)
  setupServiceLocator();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sistema de Reservas',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
      locale: const Locale('es', 'ES'),
      theme: ThemeData(
        useMaterial3: true,
        // ============================================
        // COLOR SCHEME - Paleta centralizada
        // ============================================
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF2196F3),        // Azul corporativo (marca)
          onPrimary: Colors.white,
          secondary: Color(0xFF27AE60),      // Verde para FAB y acciones
          onSecondary: Colors.white,
          tertiary: Color(0xFFE67E22),       // Naranja para acentos
          onTertiary: Colors.white,
          error: Color(0xFFE74C3C),          // Rojo estándar
          onError: Colors.white,
          surface: Colors.white,             // Blanco para tarjetas
          onSurface: Color(0xFF2C3E50),      // Texto oscuro principal
          surfaceContainerHighest: Color(0xFFF4F6F8), // Fondo neutro
          outline: Color(0xFFBDC3C7),        // Bordes
        ),
        // ============================================
        // FONDO GLOBAL - Neutro suave (Clean UI)
        // ============================================
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        
        // ============================================
        // APPBAR - Blanco con separación sutil
        // ============================================
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2C3E50),  // Iconos/texto oscuros
          elevation: 1,                         // Separación sutil
          shadowColor: Color(0x1A000000),       // Sombra muy suave
          surfaceTintColor: Colors.transparent, // Sin tinte en M3
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          iconTheme: IconThemeData(
            color: Color(0xFF2C3E50),
          ),
        ),
        // ============================================
        // TARJETAS - Blanco con elevación suave
        // ============================================
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 1,
          shadowColor: const Color(0x1A000000),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        // Elevated Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Outlined Button Theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2196F3),
            side: const BorderSide(color: Color(0xFF2196F3)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Text Theme centralizado
        textTheme: const TextTheme(
          // Títulos grandes (pantallas principales)
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          // Encabezados (secciones)
          headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
          ),
          headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          // Títulos (tarjetas, listas)
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          // Cuerpo de texto
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Color(0xFF34495E),
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF34495E),
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF7F8C8D),
            height: 1.4,
          ),
          // Labels (botones, chips)
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7F8C8D),
          ),
          labelSmall: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7F8C8D),
          ),
        ),
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFBDC3C7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE74C3C)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF7F8C8D)),
          hintStyle: const TextStyle(color: Color(0xFFBDC3C7)),
        ),
        // Divider Theme
        dividerTheme: const DividerThemeData(
          color: Color(0xFFECF0F1),
          thickness: 1,
          space: 24,
        ),
        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFECF0F1),
          selectedColor: const Color(0xFF2196F3),
          labelStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2C3E50),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF2C3E50),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
