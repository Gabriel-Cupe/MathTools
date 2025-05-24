import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mathtools/admin/admin_panel.dart';
import 'package:mathtools/main.dart';
import 'package:mathtools/models/user_model.dart';
import 'package:mathtools/perfil/profile_logic.dart';
import 'package:mathtools/services/puntos.dart';
import 'package:provider/provider.dart';
import 'package:mathtools/providers/theme_provider.dart';
import 'package:mathtools/perfil/profile_screen.dart';
class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = Provider.of<UserModel?>(context);

    // Paleta de colores Math Tools
    final Color primaryColor = const Color(0xFF0924AA);
    final Color secondaryColor = const Color(0xFF0380FB);
    final Color accentColor = const Color(0xFFFFCB87);
    final Color errorColor = const Color(0xFFE53935);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajustes',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
        ),
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de Apariencia
              _buildSectionTitle('Apariencia', primaryColor),
              _buildSettingCard(
                context,
                icon: Iconsax.moon,
                title: 'Modo oscuro',
                iconColor: primaryColor,
                trailing: Switch(
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeColor: primaryColor,
                  activeTrackColor: primaryColor.withOpacity(0.2),
                  inactiveThumbColor: Colors.grey[300],
                  inactiveTrackColor: Colors.grey[200],
                ),
              ),

              // Sección de Cuenta
              _buildSectionTitle('Cuenta', primaryColor),
              _buildSettingCard(
                context,
                icon: Iconsax.search_normal,
                title: 'Buscar usuarios',
                iconColor: secondaryColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchUsersScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                icon: Iconsax.logout,
                title: 'Cerrar sesión',
                iconColor: errorColor,
                isDestructive: true,
                onTap: () => MyApp.logout(context),
              ),

              // Sección de Administrador (solo visible para admins)
              if (user?.isAdmin ?? false) ...[
                _buildSectionTitle('Administración', primaryColor),
                _buildSettingCard(
                  context,
                  icon: Iconsax.shield_tick,
                  title: 'Panel de administrador',
                  iconColor: accentColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPanelScreen(),
                      ),
                    );
                  },
                ),
              ],

              // Sección General
              _buildSectionTitle('General', primaryColor),
              _buildSettingCard(
                context,
                icon: Iconsax.language_circle,
                title: 'Idioma',
                iconColor: secondaryColor,
                onTap: () {},
              ),
              _buildSettingCard(
                context,
                icon: Iconsax.notification,
                title: 'Notificaciones',
                iconColor: secondaryColor,
                onTap: () {},
              ),
              _buildSettingCard(
                context,
                icon: Iconsax.info_circle,
                title: 'Acerca de',
                iconColor: secondaryColor,
                onTap: () {},
              ),

              // Versión de la app
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Center(
                  child: Text(
                    'MathTools v1.0.0',
                    style: GoogleFonts.poppins(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.5) 
                          : const Color(0xFF2D3748).withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
    Color? iconColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0924AA);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode 
              ? const Color(0xFF334155) 
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? const Color(0xFFE53935).withOpacity(0.1)
                      : (iconColor ?? primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? const Color(0xFFE53935)
                      : iconColor ?? primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? const Color(0xFFE53935)
                        : isDarkMode 
                            ? Colors.white 
                            : const Color(0xFF2D3748),
                    fontSize: 15,
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(
                  Iconsax.arrow_right_3,
                  size: 18,
                  color: isDarkMode 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  _SearchUsersScreenState createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProfileLogic _logic = ProfileLogic();
  final PuntosService _puntosService = PuntosService();
  bool _isLoading = false;
  UserModel? _searchedUser;

  Future<void> _searchUser() async {
    setState(() {
      _isLoading = true;
      _searchedUser = null;
    });

    try {
      final userId = _searchController.text.trim();
      if (userId.isNotEmpty) {
        await _puntosService.actualizarTodosLosRanks();
        final user = await _logic.loadUserData(userId);
        setState(() => _searchedUser = user);
      }
    } catch (e) {
      // Error handling
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0924AA);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buscar usuarios',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
        ),
        elevation: 0,
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'ID de usuario',
                labelStyle: GoogleFonts.poppins(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.7) 
                      : const Color(0xFF2D3748).withOpacity(0.7),
                ),
                hintText: 'Ingresa el ID del usuario',
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Iconsax.send_1,
                    color: primaryColor,
                  ),
                  onPressed: _searchUser,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode 
                    ? const Color(0xFF1E293B) 
                    : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.white : const Color(0xFF2D3748),
              ),
              onSubmitted: (_) => _searchUser(),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              CircularProgressIndicator(color: primaryColor)
            else if (_searchedUser != null)
              Expanded(
                child: PerfilScreen(userId: _searchedUser!.id),
              )
            else if (_searchController.text.isNotEmpty)
              Text(
                'Usuario no encontrado',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE53935),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}