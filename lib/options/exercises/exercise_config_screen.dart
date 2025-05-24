import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mathtools/options/exercises/exercise_screen.dart';
import 'package:mathtools/services/exercise_service.dart';
import 'package:mathtools/models/exercise_model.dart';

class ExerciseConfigScreen extends StatefulWidget {
  
   const ExerciseConfigScreen({super.key});

  @override
  _ExerciseConfigScreenState createState() => _ExerciseConfigScreenState();
}


class _ExerciseConfigScreenState extends State<ExerciseConfigScreen> {
    bool _isLoading = false;

  final ExerciseService _service = ExerciseService();
  final List<String> _selectedTemas = [];
  final Map<String, List<String>> _selectedSubtemas = {};
  final Map<String, int> _counts = {
    'facil': 0,
    'medio': 0,
    'dificil': 0,
    'experto': 0,
  };
  bool _randomOrder = false;

@override
Widget build(BuildContext context) {
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
    'Configurar Ejercicios',
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
  actions: [
    IconButton(
      icon: const Icon(Icons.help_outline),
      onPressed: () {
        // Acción de ayuda
      },
      tooltip: 'Ayuda',
    ),
  ],
),
  
    body: Container(
      color: Theme.of(context).colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          
          if (isLargeScreen) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna izquierda (Temas y subtemas)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildTemaSection(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_selectedTemas.isNotEmpty)
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildSubtemasSection(),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Columna derecha (Configuración y botón)
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: _buildDifficultyCounters(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                          child: SwitchListTile(
                            title: const Text(
                              'Orden aleatorio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: _randomOrder,
                            onChanged: (value) => setState(() => _randomOrder = value),
                            activeColor: const Color(0xFF0380FB),
                          ),
                        ),
                        const SizedBox(height: 30),
ElevatedButton(
  onPressed: _isLoading ? null : _validateAndStart,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0924AA),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12), // Añade padding consistente
  ),
  child: _isLoading
      ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12), // Espacio entre el spinner y el texto
            Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        )
      : const Text('COMENZAR EJERCICIOS'),
),
                    
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Versión móvil (original)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildTemaSection(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedTemas.isNotEmpty)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildSubtemasSection(),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildDifficultyCounters(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                    child: SwitchListTile(
                      title: const Text(
                        'Orden aleatorio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: _randomOrder,
                      onChanged: (value) => setState(() => _randomOrder = value),
                      activeColor: const Color(0xFF0380FB),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: 
                    ElevatedButton(
  onPressed: _isLoading ? null : _validateAndStart,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF0924AA),
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 2,
    padding: const EdgeInsets.symmetric(vertical: 12), // Añade padding consistente
  ),
  child: _isLoading
      ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12), // Espacio entre el spinner y el texto
            Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        )
      : const Text('COMENZAR EJERCICIOS'),
),
              
                  ),
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}
  Widget _buildTemaSection() {
    return FutureBuilder<List<String>>(
      future: _service.getTemas(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(
            color: Color(0xFF0380FB),
          ));
        }
        
        final temas = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Temas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0924AA),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: temas.map((tema) {
                final isSelected = _selectedTemas.contains(tema);
                return FilterChip(
                  label: Text(
                    tema,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTemas.add(tema);
                        _selectedSubtemas[tema] = [];
                      } else {
                        _selectedTemas.remove(tema);
                        _selectedSubtemas.remove(tema);
                      }
                    });
                  },
                  backgroundColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : const Color(0xFF1E293B),
                  selectedColor: const Color(0xFF0380FB),
                  checkmarkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF0380FB)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubtemasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedTemas.map((tema) {
        return FutureBuilder<List<String>>(
          future: _service.getSubtemas(tema),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox();
            
            final subtemas = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subtemas de $tema',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0924AA),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subtemas.map((subtema) {
                    final isSelected = _selectedSubtemas[tema]?.contains(subtema) ?? false;
                    return FilterChip(
                      label: Text(
                        subtema,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSubtemas[tema]?.add(subtema);
                          } else {
                            _selectedSubtemas[tema]?.remove(subtema);
                          }
                        });
                      },
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xFF1E293B),
                      selectedColor: const Color(0xFF0380FB),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF0380FB)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildDifficultyCounters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cantidad por dificultad',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0924AA),
          ),
        ),
        const SizedBox(height: 12),
        _buildCounter('Fáciles (+1)', 'facil', const Color(0xFFA8EFFA)),
        _buildCounter('Medios (+3)', 'medio', const Color(0xFF0380FB)),
        _buildCounter('Difíciles (+5)', 'dificil', const Color(0xFF0924AA)),
        _buildCounter('Expertos (+10)', 'experto', const Color(0xFFFFCB87)),
      ],
    );
  }

  Widget _buildCounter(String label, String difficulty, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 20),
                  onPressed: () => setState(() => _counts[difficulty] = (_counts[difficulty]! - 1).clamp(0, 100)),
                  color: accentColor,
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    '${_counts[difficulty]}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: () => setState(() => _counts[difficulty] = _counts[difficulty]! + 1),
                  color: accentColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

void _validateAndStart() async {
  if (_isLoading) return; // Evitar múltiples ejecuciones

  setState(() => _isLoading = true);

  try {
    final totalExercises = _counts.values.reduce((a, b) => a + b);
    if (totalExercises == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona al menos un ejercicio'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Verificar que al menos un tema y subtema estén seleccionados
    bool hasSubtemas = false;
    for (final tema in _selectedTemas) {
      if (_selectedSubtemas[tema]?.isNotEmpty ?? false) {
        hasSubtemas = true;
        break;
      }
    }

    if (!hasSubtemas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecciona al menos un tema y subtema'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    // Combinar todos los subtemas seleccionados de todos los temas
    final allSubtemas = <String>[];
    for (final tema in _selectedTemas) {
      if (_selectedSubtemas[tema]?.isNotEmpty ?? false) {
        allSubtemas.addAll(_selectedSubtemas[tema]!);
      }
    }

    final exercises = await _service.getExercises(
      temas: _selectedTemas,
      subtemas: allSubtemas,
      facil: _counts['facil']!,
      medio: _counts['medio']!,
      dificil: _counts['dificil']!,
      experto: _counts['experto']!,
    );

    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se encontraron ejercicios con los criterios seleccionados'),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseScreen(
          session: ExerciseSession(
            exercises: _randomOrder ? (exercises..shuffle()) : exercises,
            randomOrder: _randomOrder,
          ),
        ),
      ),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
}