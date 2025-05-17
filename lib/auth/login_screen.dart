// login_screen.dart
import 'package:flutter/material.dart';
import 'package:mathtools/auth/register_screen.dart';
import 'login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginService _loginService = LoginService();
  bool _isLoading = false;
  String? _errorMessage;
  
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  // Nueva paleta de colores Math Tools
  final Color _primaryColor = const Color(0xFF0924AA);     // Azul oscuro
  final Color _secondaryColor = const Color(0xFF0380FB);   // Azul brillante
  final Color _lightAccent = const Color(0xFFFFE980);      // Amarillo claro
  final Color _skyBlue = const Color(0xFFA8EFFA);         // Celeste
  final Color _errorColor = const Color(0xFFE53935);
  final Color _textColor = const Color(0xFF2D3748);
  final Color _lightGray = const Color(0xFFF7FAFC);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await _loginService.loginUser(
        userId: _userIdController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'ID o contraseña incorrectos';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo degradado con nueva paleta
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _primaryColor.withOpacity(0.95),
                  _secondaryColor.withOpacity(0.95),
                ],
              ),
            ),
          ),
          
          // Patrón matemático de fondo sutil
          Opacity(
            opacity: 0.2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/math_pattern.png'),
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  repeat: ImageRepeat.repeat,
                ),
              ),
            ),
          ),
          
          // Contenedor principal
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo de la app
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _skyBlue.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _secondaryColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Image.asset(
                                'assets/icon.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Título
                            Text(
                              'Math Tools',
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: _primaryColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Inicia sesión para continuar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Campo ID de usuario
                            TextFormField(
                              controller: _userIdController,
                              decoration: InputDecoration(
                                labelText: 'ID de usuario',
                                labelStyle: GoogleFonts.poppins(
                                  color: _textColor.withOpacity(0.8),
                                ),
                                prefixIcon: Icon(
                                  Iconsax.profile_circle,
                                  color: _primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _lightGray,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _lightGray,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: _lightGray.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              ),
                              style: GoogleFonts.poppins(
                                color: _textColor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu ID';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            // Campo contraseña
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: GoogleFonts.poppins(
                                  color: _textColor.withOpacity(0.8),
                                ),
                                prefixIcon: Icon(
                                  Iconsax.lock_1,
                                  color: _primaryColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _lightGray,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: _lightGray,
                                    width: 1.5,
                                  ),
                                ),
                                filled: true,
                                fillColor: _lightGray.withOpacity(0.5),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              ),
                              obscureText: true,
                              style: GoogleFonts.poppins(
                                color: _textColor,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingresa tu contraseña';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            
                            // Mensaje de error
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    color: _errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            
                            // Botón de login
                            SizedBox(
                              width: double.infinity,
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Color(0xFF0380FB),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: _iniciarSesion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryColor,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 2,
                                        shadowColor: _primaryColor.withOpacity(0.3),
                                      ),
                                      child: Text(
                                        'INICIAR SESIÓN',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'o',
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: Colors.grey.shade300,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Botón de registro
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const RegisterScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: _lightAccent.withOpacity(0.2),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  text: '¿No tienes una cuenta? ',
                                  style: GoogleFonts.poppins(
                                    color: _textColor,
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: GoogleFonts.poppins(
                                        color: _primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}