import 'package:flutter/material.dart';
import 'package:mathtools/challenge/reto_screen.dart';
import 'package:mathtools/exercises/exercise_config_screen.dart';
import 'package:mathtools/models/user_model.dart';
import 'package:mathtools/convertidor/convertidor_ui.dart';
import 'package:mathtools/explorador/explorador.dart';
import 'package:mathtools/firebase_options.dart';
import 'package:mathtools/graficadora/graph_screen.dart';
import 'package:mathtools/perfil/profile_screen.dart';
import 'package:mathtools/screens/calculator.dart';
import 'package:mathtools/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mathtools/providers/theme_provider.dart';
import 'package:mathtools/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mathtools/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  try {
    // Verifica si ya fue inicializado
    final apps = Firebase.apps;
    if (apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final userId = prefs.getString('userId');

  UserModel? user;
  if (isLoggedIn && userId != null) {
    final userService = UserService();
    user = await userService.obtenerUsuario(userId);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<UserModel>(
          create: (_) => user ?? UserModel(
            id: userId ?? 'temp',
            username: 'Invitado',
            password: '',
            seUnio: DateTime.now().year,
          ),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn, userId: userId),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userId;

  const MyApp({
    super.key,
    required this.isLoggedIn,
    this.userId,
  });

  static Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('userId');
    
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      routes: {
        '/explorador': (context) => const Explorador(),
        '/graficadora': (context) => const GraphScreen(), 
        '/conversor': (context) => const ConvertidorScreen(), 
        '/calculadora': (context) => const ScientificCalculator(), 
        '/ejercicios': (context) => const ExerciseConfigScreen(),
        '/problema': (context) => const RetoScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/perfil': (context) {
          final userId = ModalRoute.of(context)!.settings.arguments as String;
          return PerfilScreen(userId: userId);
        },
      },
      debugShowCheckedModeBanner: false,
      title: 'MathTools',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white, // Fondo blanco puro
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0924AA), // Azul oscuro
          secondary: Color(0xFF0380FB), // Fondo blanco
          surface: Colors.white, // Superficies como tarjetas
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212), // Fondo oscuro
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900],
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0380FB), // Azul brillante
          secondary: Color(0xFFA8EFFA), // Fondo oscuro
          surface: Color(0xFF1E1E1E), // Superficies como tarjetas
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: isLoggedIn ? const HomePage() : const LoginScreen(),
    );
  }
}