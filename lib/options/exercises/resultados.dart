import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mathtools/models/exercise_model.dart';
import 'package:mathtools/options/exercises/image_viewer.dart';
import 'package:mathtools/widgets/texto_matematico.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ResultScreen extends StatefulWidget {
  final ExerciseSession session;
  final List<bool> results;
  final int totalPoints;

  const ResultScreen({
    super.key,
    required this.session,
    required this.results,
    required this.totalPoints,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    SchedulerBinding.instance.addPostFrameCallback((_) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {
    final correctCount = widget.results.where((r) => r).length;
    final totalExercises = widget.results.length;
    final successRate = (correctCount / totalExercises * 100).round();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
                leading: IconButton(
    icon: Transform.scale(
      scale: 1.2,  // Aumenta ligeramente el tamaño
      child: Icon(
        Iconsax.arrow_left_2,  // Flecha moderna de Iconsax
        color:  Colors.white,  // Color blanco para contraste
        size: 24,  // Tamaño óptimo
      ),
    ),
    tooltip: 'Regresar',  // Tooltip personalizado
    splashRadius: 20,  // Reduce el área de splash para que sea más elegante
    onPressed: () => Navigator.pop(context),
  ),
            expandedHeight: 200,
              iconTheme: const IconThemeData(
    color: Colors.white,
    size: 28,
  ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, size: 50, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        '¡Resultados Obtenidos!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ).animate().fadeIn().slideY(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: 
// Reemplaza el Column dentro del SliverToBoxAdapter por este widget:
LayoutBuilder(
  builder: (context, constraints) {
    final isLargeScreen = constraints.maxWidth > 800; // Define tu breakpoint
    
    if (isLargeScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de resumen (ocupará 40% del ancho)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _buildSummaryCard(context, successRate, correctCount)
                  .animate(controller: _controller)
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.5),
            ),
          ),
          // Lista de ejercicios (ocupará 60% del ancho)
          Expanded(
            flex: 6,
            child: Column(
              children: [
                ...List.generate(
                  widget.session.exercises.length,
                  (index) => _buildExerciseItem(context, index)
                      .animate(controller: _controller)
                      .fade(delay: (400 + index * 100).ms)
                      .slideX(begin: 0.5),
                ),
                const SizedBox(height: 24),
                _buildActionButton(context)
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shimmer(delay: 1500.ms, duration: 1000.ms),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildSummaryCard(context, successRate, correctCount)
              .animate(controller: _controller)
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.5),
          const SizedBox(height: 24),
          ...List.generate(
            widget.session.exercises.length,
            (index) => _buildExerciseItem(context, index)
                .animate(controller: _controller)
                .fade(delay: (400 + index * 100).ms)
                .slideX(begin: 0.5),
          ),
          const SizedBox(height: 24),
          _buildActionButton(context)
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(delay: 1500.ms, duration: 1000.ms),
        ],
      );
    }
  },
),  
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int successRate, int correctCount) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Barra de progreso circular
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: successRate / 100,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    color: _getSuccessColor(successRate),
                  ),
                ),
                Text(
                  '$successRate%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getSuccessColor(successRate),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Estadísticas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Correctas',
                  '$correctCount',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Incorrectas',
                  '${widget.results.length - correctCount}',
                  Icons.cancel,
                  Colors.red,
                ),
                _buildStatItem(
                  context,
                  'Puntos',
                  '${widget.totalPoints}',
                  Icons.star,
                  _getPointsColor(widget.totalPoints),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Mensaje motivacional
            Text(
              _getMotivationalMessage(successRate),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseItem(BuildContext context, int index) {
    final exercise = widget.session.exercises[index];
    final isCorrect = widget.results[index];
    final points = isCorrect
        ? widget.session.puntosPorDificultad[exercise.dificultad] ?? 0
        : widget.session.penalizacionPorDificultad[exercise.dificultad] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: isCorrect ? Colors.green[50] : Colors.red[50],
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showSolutionDialog(context, index),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícono animado
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green[100] : Colors.red[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check : Icons.close,
                    color: isCorrect ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                // Detalles
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ejercicio ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(exercise.dificultad),
                            backgroundColor: _getDifficultyColor(exercise.dificultad),
                          ),
                          const Spacer(),
                          Text(
                            '${points >= 0 ? '+' : ''}$points pts',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green : Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
      icon: const Icon(Icons.home),
      label: const Text('VOLVER AL INICIO'),
    );
  }


void _showSolutionDialog(BuildContext context, int index) {
  final exercise = widget.session.exercises[index];
  final isCorrect = widget.results[index];

  showDialog(
    context: context,
    builder: (context) => Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Solución detallada',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCorrect ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isCorrect ? 'Correcta' : 'Incorrecta',
                        style: TextStyle(
                          color: isCorrect ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Enunciado
                _buildSolutionSection(
                  context,
                  'Enunciado',
                  exercise.premisa,
                  Icons.description,
                  exercise.imagenUrl,
                  isSolution: false,
                ),
                const SizedBox(height: 24),

                // Solución
                _buildSolutionSection(
                  context,
                  'Solución',
                  exercise.solucion,
                  Icons.lightbulb,
                  exercise.solucionImagenUrl,
                  isSolution: true,
                ),
                const SizedBox(height: 24),

                // Botón de cierre
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ENTENDIDO'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildSolutionSection(BuildContext context, String title, String content, IconData icon, String? imageUrl, {bool isSolution = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          minHeight: 100, // Altura mínima
          maxHeight: 300, // Altura máxima antes de scroll
        ),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: true,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 80,
                ),
                child: TextoMatematico(
                  content,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        ),
      ),
      if (imageUrl != null && imageUrl.isNotEmpty) ...[
        const SizedBox(height: 16),
        Center(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: 300,
              maxWidth: MediaQuery.of(context).size.width - 80,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageViewer(
                imageUrl: imageUrl,
                initialScale: 1.0,
                showZoomControls: isSolution,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // Helpers para estilos dinámicos
  Color _getSuccessColor(int rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getPointsColor(int points) {
    if (points >= 20) return Colors.green;
    if (points >= 0) return Colors.blue;
    return Colors.red;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'facil':
        return Colors.green[100]!;
      case 'medio':
        return Colors.blue[100]!;
      case 'dificil':
        return Colors.orange[100]!;
      case 'experto':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getMotivationalMessage(int successRate) {
    if (successRate >= 90) return '¡Excelente trabajo! Dominas estos conceptos.';
    if (successRate >= 70) return '¡Buen resultado! Sigue practicando para mejorar.';
    if (successRate >= 50) return '¡Sigue así! Cada error es una oportunidad para aprender.';
    return '¡No te rindas! Revisa las soluciones y vuelve a intentarlo.';
  }
}