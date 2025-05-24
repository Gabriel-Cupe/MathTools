import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/options/exercises/exercise_design_desktop.dart';
import 'package:mathtools/options/exercises/exercise_design_mobile.dart';
import 'package:mathtools/options/exercises/resultados.dart';
import 'package:mathtools/models/exercise_model.dart';
import 'package:mathtools/models/user_model.dart';
import 'package:mathtools/services/puntos.dart';
import 'package:provider/provider.dart';

class ExerciseScreen extends StatefulWidget {
  final ExerciseSession session;

  const ExerciseScreen({super.key, required this.session});

  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  int _currentIndex = 0;
  final List<String?> _selectedOptions = [];
  final _puntosService = PuntosService(); // Initialize the service
  final List<bool> _results = [];
  bool _showResults = false;
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _selectedOptions.addAll(List.filled(widget.session.exercises.length, null));
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultsScreen();
    }

    final exercise = widget.session.exercises[_currentIndex];
    final isLastExercise = _currentIndex == widget.session.exercises.length - 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return ExerciseDesignDesktop(
            exercise: exercise,
            selectedOption: _selectedOptions[_currentIndex],
            currentIndex: _currentIndex,
            totalExercises: widget.session.exercises.length,
            onOptionSelected: (value) => setState(() => _selectedOptions[_currentIndex] = value),
            onContinuePressed: () => _handleContinue(isLastExercise),
            onPreviousPressed: () => setState(() => _currentIndex--),
          );
        } else {
          return ExerciseDesignMobile(
            exercise: exercise,
            selectedOption: _selectedOptions[_currentIndex],
            currentIndex: _currentIndex,
            totalExercises: widget.session.exercises.length,
            onOptionSelected: (value) => setState(() => _selectedOptions[_currentIndex] = value),
            onContinuePressed: () => _handleContinue(isLastExercise),
            onPreviousPressed: () => setState(() => _currentIndex--),
          );
        }
      },
    );
  }

  void _handleContinue(bool isLastExercise) {
    if (isLastExercise) {
      _finishExercises();
    } else {
      setState(() => _currentIndex++);
    }
  }

  void _finishExercises() async {
    // Calcular resultados
    for (int i = 0; i < widget.session.exercises.length; i++) {
      _results.add(
        _selectedOptions[i] == widget.session.exercises[i].opcionCorrecta,
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          session: widget.session,
          results: _results,
          totalPoints: _totalPoints,
        ),
      ),
    );
// Calcular puntos totales
_totalPoints = widget.session.calculatePoints(_results);

// Actualizar puntos en Firebase
final user = Provider.of<UserModel>(context, listen: false);
await _puntosService.addPuntos(user.id, _totalPoints);

// Verifica si el widget sigue montado antes de llamar setState
if (!mounted) return;
setState(() {
  _showResults = true;
});
  }

Widget _buildResultsScreen() {
  final correctCount = _results.where((r) => r).length;
  final incorrectCount = _results.length - correctCount;

  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF0924AA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Barra superior personalizada
            Container(
              height: 80,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'RESULTADOS',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: 3,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contenedor central
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¡Ejercicios completados!',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: const Color(0xFF0924AA),
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatCircle(
                            label: 'Correctas',
                            value: correctCount.toString(),
                            color: const Color(0xFF0380FB),
                          ),
                          const SizedBox(width: 30),
                          _buildStatCircle(
                            label: 'Incorrectas',
                            value: incorrectCount.toString(),
                            color: const Color(0xFFE53935),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'Puntos obtenidos',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0924AA),
                          letterSpacing: 1.1,
                        ),
                      ),

                      Text(
                        '$_totalPoints',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: _totalPoints >= 0
                              ? const Color(0xFF0380FB)
                              : const Color(0xFFE53935),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Expanded(
                        child: ListView.separated(
                          itemCount: widget.session.exercises.length,
                          separatorBuilder: (_, __) => const Divider(
                            thickness: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          itemBuilder: (context, index) {
                            final exercise = widget.session.exercises[index];
                            final isCorrect = _results[index];
                            final difficulty = exercise.dificultad;
                            final points = isCorrect
                                ? '+${widget.session.puntosPorDificultad[difficulty]}'
                                : '${widget.session.penalizacionPorDificultad[difficulty]}';

                            return GestureDetector(
                              onTap: () => _showExerciseSolution(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 20),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCorrect
                                        ? const Color(0xFF0380FB)
                                        : const Color(0xFFE53935),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isCorrect
                                          ? const Color(0xFF0380FB).withOpacity(0.15)
                                          : const Color(0xFFE53935).withOpacity(0.15),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  color: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 600),
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isCorrect
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(0xFF0380FB),
                                                  Color(0xFF0924AA),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : const LinearGradient(
                                                colors: [
                                                  Color(0xFFE53935),
                                                  Color(0xFFB71C1C),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                      ),
                                      child: Icon(
                                        isCorrect ? Icons.check : Icons.close,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: Text(
                                        'Ejercicio ${index + 1} - ${difficulty[0].toUpperCase()}${difficulty.substring(1)}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 17,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      points,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: isCorrect
                                            ? const Color(0xFF0380FB)
                                            : const Color(0xFFE53935),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Color(0xFF0924AA),
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFCB87),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            shadowColor: const Color(0xFFFFCB87).withOpacity(0.6),
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              letterSpacing: 1.6,
                            ),
                            foregroundColor: const Color(0xFF0924AA),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('VOLVER'),
                        ),
                      ),
                    ],
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

Widget _buildStatCircle({
  required String label,
  required String value,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
          letterSpacing: 0.7,
        ),
      ),
    ],
  );
}
  void _showExerciseSolution(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Solución Ejercicio ${index + 1}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.session.exercises[index].premisa),
              const SizedBox(height: 10),
              const Text('Solución:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.session.exercises[index].solucion),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

}