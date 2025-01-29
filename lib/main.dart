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
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    ).copyWith(
      secondary: Colors.blueGrey,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade800;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade200;
        }
        return Colors.grey.shade300;
      }),
    ),
    cardColor: Colors.white,
    textTheme: TextTheme(
      headlineMedium: const TextStyle(color: Colors.black, fontSize: 28),
      bodyMedium: const TextStyle(color: Colors.black87, fontSize: 16),
      bodySmall: const TextStyle(color: Colors.black54, fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade700,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
    ),
  );

    final ThemeData darktheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: Colors.blueAccent,
    ),
      switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade300;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade700;
        }
        return Colors.grey.shade600;
      }),
    ),
    textTheme: TextTheme(
      headlineMedium: const TextStyle(color: Colors.white, fontSize: 28),
      bodyMedium: const TextStyle(color: Colors.white70, fontSize: 16),
      bodySmall: const TextStyle(fontSize: 14, color: Colors.white70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade200,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.blue,
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
