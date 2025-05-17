// register_screen.dart
import 'package:flutter/material.dart';
import 'package:mathtools/auth/login_screen.dart';
import 'register.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final RegisterService _registerService = RegisterService();
  bool _isLoading = false;
  String? _errorMessage;
  String? _registeredId;
  
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _translateAnimation;

  // Nueva paleta de colores Math Tools
  final Color _primaryColor = const Color(0xFF0924AA);     // Azul oscuro
  final Color _secondaryColor = const Color(0xFF0380FB);   // Azul brillante    // Amarillo claro
  final Color _skyBlue = const Color(0xFFA8EFFA);         // Celeste
  final Color _errorColor = const Color(0xFFE53935);
  final Color _successColor = const Color(0xFF4CAF50);
  final Color _textColor = const Color(0xFF2D3748);
  final Color _lightGray = const Color(0xFFF7FAFC);

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _translateAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _registerService.registerUser(
        username: _usernameController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (result?['error'] != null) {
        setState(() {
          _errorMessage = result?['error'];
        });
      } else {
        setState(() {
          _registeredId = result?['userId'];
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
                  return Transform.translate(
                    offset: Offset(0, _translateAnimation.value),
                    child: Opacity(
                      opacity: _opacityAnimation.value,
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
                              'Crea tu cuenta para comenzar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            if (_registeredId == null) ...[
                              // Campo nombre de usuario
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre de usuario',
                                  labelStyle: GoogleFonts.poppins(
                                    color: _textColor.withOpacity(0.8),
                                  ),
                                  prefixIcon: Icon(
                                    Iconsax.user,
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
                                    return 'Por favor ingresa un nombre de usuario';
                                  }
                                  if (value.length < 4) {
                                    return 'El nombre debe tener al menos 4 caracteres';
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
                                    return 'Por favor ingresa una contraseña';
                                  }
                                  if (value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 8),
                              
                              // Requisitos de contraseña
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.info_circle,
                                      size: 16,
                                      color: _secondaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Mínimo 6 caracteres',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: _textColor.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
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
                              
                              // Botón de registro
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
                                        onPressed: _registrar,
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
                                          'REGISTRARSE',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                              ),
                            ] else ...[
                              // Mensaje de éxito después del registro
                              Icon(
                                Iconsax.tick_circle,
                                size: 60,
                                color: _successColor,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '¡Registro Exitoso!',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: _successColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tu ID de acceso es:',
                                style: GoogleFonts.poppins(
                                  color: _textColor.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _skyBlue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _secondaryColor.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  '$_registeredId',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Guarda este ID en un lugar seguro. Lo necesitarás para iniciar sesión en Math Tools.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: _textColor.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
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
                                    'IR A INICIAR SESIÓN',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (_registeredId == null) ...[
                              const SizedBox(height: 24),
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) =>
                                          const LoginScreen(),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: '¿Ya tienes una cuenta? ',
                                    style: GoogleFonts.poppins(
                                      color: _textColor,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Inicia sesión',
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