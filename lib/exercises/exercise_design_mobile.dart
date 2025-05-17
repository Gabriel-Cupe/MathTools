import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mathtools/models/exercise_model.dart';
import 'package:mathtools/widgets/texto_matematico.dart';

class ExerciseDesignMobile extends StatelessWidget {
  final ExerciseModel exercise;
  final String? selectedOption;
  final Function(String?) onOptionSelected;
final int currentIndex;
final int totalExercises;
final VoidCallback onContinuePressed;
final VoidCallback onPreviousPressed;


  const ExerciseDesignMobile({
    super.key,
    required this.exercise,
    required this.selectedOption,
    required this.onOptionSelected,
  required this.currentIndex,
  required this.totalExercises,
  required this.onContinuePressed,
  required this.onPreviousPressed,    
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
appBar: AppBar(
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
  title: const Text(
    'Ejercicios',
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      shadows: [
        Shadow(
          blurRadius: 2.0,
          color: Colors.black26,
          offset: Offset(1.0, 1.0),
    )],
    ),
  ),
  centerTitle: true,
  backgroundColor: const Color(0xFF0924AA),
  elevation: 4,
  shadowColor: Colors.black.withOpacity(0.3),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      bottom: Radius.circular(20),
    ),
  ),
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0924AA),
          Colors.blue.shade700,
        ],
        stops: const [0.3, 1.0],
      ),
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(20),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade900.withOpacity(0.4),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 5),
        ),
      ],
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 28,
  ),
),
  
      backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Tarjeta del problema
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              exercise.tema,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(exercise.dificultad).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getDifficultyColor(exercise.dificultad).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              exercise.dificultad.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getDifficultyColor(exercise.dificultad),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextoMatematico(
                        exercise.premisa,
                        fontSize: 15,
                        textColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                      ),
                      const SizedBox(height: 16),
                      if (exercise.imagenUrl != null && exercise.imagenUrl!.isNotEmpty)
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  exercise.imagenUrl!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjeta de opciones
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona una opción',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...exercise.opciones.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                : Colors.grey.shade50,
                            border: Border.all(
                              color: selectedOption == entry.key
                                  ? primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: RadioListTile<String>(
                            title: TextoMatematico(
                              entry.value,
                              textColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                            ),
                            value: entry.key,
                            groupValue: selectedOption,
                            onChanged: (value) => onOptionSelected(value),
                            activeColor: primaryColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return primaryColor;
                              }
                              return isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400;
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12),
                          ),
                        );
                      }
                      
                      ),
                                              _buildBottomControls(context),

                    ],
                 
                  ),
                
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'facil': return Colors.green;
      case 'medio': return Colors.blue;
      case 'dificil': return Colors.orange;
      case 'experto': return Colors.red;
      default: return Colors.grey;
    }
  }


Widget _buildBottomControls(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Iconsax.close_circle, color: Colors.white),
          label: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 90, 90),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        Row(
          children: [
            Text(
              'Ejercicio ${currentIndex + 1} de $totalExercises',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Iconsax.arrow_left_2),
              onPressed: currentIndex > 0
                  ? () => onPreviousPressed()
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Iconsax.arrow_right_2),
              onPressed: selectedOption != null
                  ? () => onContinuePressed()
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}