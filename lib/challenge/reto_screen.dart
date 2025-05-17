import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/challenge/reto_desing_desktop.dart';
import 'package:mathtools/challenge/reto_desing_mobile.dart';
import 'package:mathtools/models/reto_model.dart';
import 'package:mathtools/models/user_model.dart';
import 'package:mathtools/services/reto_service.dart';
import 'package:provider/provider.dart';

class RetoScreen extends StatefulWidget {
  const RetoScreen({super.key});

  @override
  State<RetoScreen> createState() => _RetoScreenState();
}

class _RetoScreenState extends State<RetoScreen> {
  final RetoService _retoService = RetoService();
  
  RetoModel? _reto;
  bool _isLoading = true;
  String? _opcionSeleccionada;
  bool _mostrarSolucion = false;
  String? _error;
  bool _respuestaCorrecta = false;
  bool _puntosOtorgados = false;

  @override
  void initState() {
    super.initState();
    _cargarReto();
  }

  Future<void> _cargarReto() async {
    setState(() => _isLoading = true);
    
    try {
      final data = await _retoService.obtenerProblemaDelDia();
      if (data != null) {
        setState(() {
          _reto = RetoModel.fromMap(data);
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'No hay problema del día disponible';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el reto';
        _isLoading = false;
      });
      debugPrint('Error loading reto: $e');
    }
  }

  Future<void> _procesarRespuesta() async {
    if (_reto == null || _opcionSeleccionada == null) return;

    final user = Provider.of<UserModel>(context, listen: false);
    final hoy = DateTime.now();
    final mismoDia = user.ultimoIntentoDiario != null &&
        user.ultimoIntentoDiario!.year == hoy.year &&
        user.ultimoIntentoDiario!.month == hoy.month &&
        user.ultimoIntentoDiario!.day == hoy.day;

    _respuestaCorrecta = _opcionSeleccionada == _reto!.opcionCorrecta;
    _puntosOtorgados = _respuestaCorrecta && !mismoDia;

    setState(() {
      _mostrarSolucion = true;
    });
  }


@override
Widget build(BuildContext context) {

  final user = Provider.of<UserModel>(context); 
  final hoy = DateTime.now();
  final mismoDia = user.ultimoIntentoDiario != null &&
      user.ultimoIntentoDiario!.year == hoy.year &&
      user.ultimoIntentoDiario!.month == hoy.month &&
      user.ultimoIntentoDiario!.day == hoy.day;

  if (_isLoading) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
    ? Colors.white // Fondo blanco puro en modo claro
    : Colors.black, // Fondo negro puro en modo oscuro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Text(
                'Espera un segundo...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (_error != null) {
    return Scaffold(
      body: Center(
        child: Text(
          _error!,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  if (_reto == null) {
    return Scaffold(
      body: Center(
        child: Text(
          'No hay problema disponible',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 600),
    switchInCurve: Curves.easeOutExpo,
    switchOutCurve: Curves.easeInExpo,
    transitionBuilder: (Widget child, Animation<double> animation) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
    child: Scaffold(
      key: ValueKey(_reto?.id ?? 'main_content'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return RetoDesignDesktop(
              reto: _reto!,
              opcionSeleccionada: _opcionSeleccionada,
              mostrarSolucion: _mostrarSolucion,
              respuestaCorrecta: _respuestaCorrecta,
              puntosOtorgados: _puntosOtorgados,
              mismoDia: mismoDia,
              puntosUsuario: user.points,
              onOpcionSeleccionada: (value) => setState(() => _opcionSeleccionada = value),
              onVerSolucion: _procesarRespuesta,
            );
          } else {
            return RetoDesignMobile(
              reto: _reto!,
              opcionSeleccionada: _opcionSeleccionada,
              mostrarSolucion: _mostrarSolucion,
              respuestaCorrecta: _respuestaCorrecta,
              puntosOtorgados: _puntosOtorgados,
              mismoDia: mismoDia,
              puntosUsuario: user.points,
              onOpcionSeleccionada: (value) => setState(() => _opcionSeleccionada = value),
              onVerSolucion: _procesarRespuesta,
            );
          }
        },
      ),
    ),
  );
}


}

