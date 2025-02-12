import 'package:campus_updates/Screens/auth.dart';
import 'package:campus_updates/Screens/home_screen.dart';
import 'package:campus_updates/Screens/splash.dart';
import 'package:campus_updates/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  MyApp({super.key});

  final ThemeData lighttheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ).copyWith(
      secondary: Colors.tealAccent[700],
      tertiary: Colors.amber[700],
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.indigo.shade600;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.indigo.shade200;
        }
        return Colors.grey.shade200;
      }),
    ),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        color: Colors.indigo.shade900,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: Colors.indigo.shade800,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: Colors.black87,
        fontSize: 18,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        color: Colors.black87,
        fontSize: 16,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        color: Colors.black54,
        fontSize: 14,
        height: 1.3,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.indigo.shade600,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.tealAccent[700],
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );

  final ThemeData darktheme = ThemeData(
    primarySwatch: Colors.indigo,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.tealAccent[400],
      tertiary: Colors.amber[400],
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2D2D2D),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.tealAccent[400];
        }
        return Colors.grey.shade600;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.teal.withOpacity(0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.87),
        fontSize: 18,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.87),
        fontSize: 16,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        color: Colors.white.withOpacity(0.6),
        fontSize: 14,
        height: 1.3,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2D2D2D),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.tealAccent[400],
      foregroundColor: Colors.black87,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.tealAccent[400]!, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );


  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final themeMode = ref.watch(themeNotifierProvider);
    return MaterialApp(
      title: 'BPHC Updates',
      theme: lighttheme,
      darkTheme: darktheme,
      themeMode: themeMode,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            try {
              return const HomeScreen();
            } on FlutterError {
              return const AuthScreen();
            }
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
