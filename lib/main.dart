import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen_container.dart';
import 'screens/history_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'providers/theme_provider.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await SupabaseService().initialize();

  // Set system UI overlay style globally
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.green.shade600,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ScanMySoilApp(),
    ),
  );
}

class ScanMySoilApp extends StatefulWidget {
  const ScanMySoilApp({super.key});

  @override
  State<ScanMySoilApp> createState() => _ScanMySoilAppState();
}

class _ScanMySoilAppState extends State<ScanMySoilApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ScanMySoil',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: Colors.brown,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: Colors.brown,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey.shade900,
        cardTheme: CardTheme(
          color: Colors.grey.shade800,
          surfaceTintColor: Colors.grey.shade800,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade700),
          ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/home_container': (context) => const HomeScreenContainer(),
        '/history': (context) => const HistoryScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/profile_edit': (context) => const ProfileEditScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    // Delay the auth check slightly to avoid build issues
    Future.delayed(const Duration(milliseconds: 100), () {
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = await authProvider.checkAuthState();

      // Only update state if still mounted
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuthenticated;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle any errors
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while loading
    if (_isLoading) {
      return const SplashScreen();
    }

    // After loading, show appropriate screen
    return _isAuthenticated ? const HomeScreenContainer() : const SignInScreen();
  }
}

