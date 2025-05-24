import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/options/graficadora/graph_screen.dart';
import 'package:mathtools/perfil/profile_screen.dart';
import 'package:mathtools/screens/calculator.dart';
import 'package:mathtools/screens/home.dart';
import 'package:mathtools/screens/ajustes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString('userId');
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = const Color(0xFF0924AA);
    final Color accentColor = const Color(0xFFFFCB87);
    final Color darkModeSelectedColor = accentColor; // Color para seleccionado en modo oscuro

    final List<Widget> pages = [
      const HomeScreen(), // 0
      const ScientificCalculator(),
      const GraphScreen(),
      const Page4(),
      _loading
          ? const Center(child: CircularProgressIndicator())
          : _userId != null
              ? PerfilScreen(userId: _userId!)
              : const Center(child: Text('Debes iniciar sesión')),
    ];

    return Scaffold(
      body: _loading
          ? Container(
              color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0380FB)),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Cargando...',
                      style: GoogleFonts.poppins(
                        color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            selectedItemColor: isDarkMode ? darkModeSelectedColor : primaryColor,
            unselectedItemColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            selectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 0 
                        ? (isDarkMode ? darkModeSelectedColor.withOpacity(0.2) : primaryColor.withOpacity(0.2))
                        : Colors.transparent,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.house,
                    size: 20,
                    color: _currentIndex == 0 
                        ? (isDarkMode ? darkModeSelectedColor : primaryColor)
                        : (isDarkMode ? Colors.white : null),
                  ),
                ),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 1 
                        ? (isDarkMode ? darkModeSelectedColor.withOpacity(0.2) : primaryColor.withOpacity(0.2))
                        : Colors.transparent,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.calculator,
                    size: 20,
                    color: _currentIndex == 1 
                        ? (isDarkMode ? darkModeSelectedColor : primaryColor)
                        : (isDarkMode ? Colors.white : null),
                  ),
                ),
                label: 'Calculadora',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 2 
                        ? (isDarkMode ? darkModeSelectedColor.withOpacity(0.2) : primaryColor.withOpacity(0.2))
                        : Colors.transparent,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.chartLine,
                    size: 20,
                    color: _currentIndex == 2 
                        ? (isDarkMode ? darkModeSelectedColor : primaryColor)
                        : (isDarkMode ? Colors.white : null),
                  ),
                ),
                label: 'Gráficas',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 3 
                        ? (isDarkMode ? darkModeSelectedColor.withOpacity(0.2) : primaryColor.withOpacity(0.2))
                        : Colors.transparent,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.gear,
                    size: 20,
                    color: _currentIndex == 3 
                        ? (isDarkMode ? darkModeSelectedColor : primaryColor)
                        : (isDarkMode ? Colors.white : null),
                  ),
                ),
                label: 'Ajustes',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 4 
                        ? (isDarkMode ? darkModeSelectedColor.withOpacity(0.2) : primaryColor.withOpacity(0.2))
                        : Colors.transparent,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.user,
                    size: 20,
                    color: _currentIndex == 4 
                        ? (isDarkMode ? darkModeSelectedColor : primaryColor)
                        : (isDarkMode ? Colors.white : null),
                  ),
                ),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}