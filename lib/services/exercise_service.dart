import 'package:firebase_database/firebase_database.dart';
import 'package:mathtools/models/exercise_model.dart';

class ExerciseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('ejercicios');

  Future<List<String>> getTemas() async {
    final snapshot = await _dbRef.child('temas').get();
    if (snapshot.exists) {
      return List<String>.from(snapshot.value as List);
    }
    return [];
  }

  Future<List<String>> getSubtemas(String tema) async {
    final snapshot = await _dbRef.child('subtemas/$tema').get();
    if (snapshot.exists) {
      return List<String>.from(snapshot.value as List);
    }
    return [];
  }

Future<List<ExerciseModel>> getExercises({
  required List<String> temas,  // Cambiado de String a List<String>
  required List<String> subtemas,
  required int facil,
  required int medio,
  required int dificil,
  required int experto,
}) async {
  final List<ExerciseModel> exercises = [];

  for (final tema in temas) {
    for (final subtema in subtemas) {
      final snapshot = await _dbRef.child('ejercicios/$tema/$subtema').get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        data.forEach((key, value) {
          final exercise = ExerciseModel.fromMap(Map<String, dynamic>.from(value));
          exercises.add(exercise);
        });
      }
    }
  }

  // Mezclar aleatoriamente todos los ejercicios antes de filtrar
  exercises.shuffle();

  // Filtrar por dificultad y cantidad solicitada
  final filteredExercises = <ExerciseModel>[];
  filteredExercises.addAll(_filterByDifficulty(exercises, 'facil', facil));
  filteredExercises.addAll(_filterByDifficulty(exercises, 'medio', medio));
  filteredExercises.addAll(_filterByDifficulty(exercises, 'dificil', dificil));
  filteredExercises.addAll(_filterByDifficulty(exercises, 'experto', experto));

  return filteredExercises;
}
  List<ExerciseModel> _filterByDifficulty(
    List<ExerciseModel> exercises, 
    String difficulty, 
    int count,
  ) {
    final filtered = exercises.where((e) => e.dificultad == difficulty).toList();
    return count > filtered.length ? filtered : filtered.sublist(0, count);
  }
}