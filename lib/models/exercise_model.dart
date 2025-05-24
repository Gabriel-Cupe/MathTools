class ExerciseModel {
  final String id;
  final String tema;
  final String subtema;
  final String dificultad;
  final String premisa;
  final Map<String, String> opciones;
  final String opcionCorrecta;
  final String solucion;
  final String? imagenUrl;
  final String? solucionImagenUrl; // Nuevo campo

  ExerciseModel({
    required this.id,
    required this.tema,
    required this.subtema,
    required this.dificultad,
    required this.premisa,
    required this.opciones,
    required this.opcionCorrecta,
    required this.solucion,
    this.imagenUrl,
    this.solucionImagenUrl, // Nuevo campo
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'],
      tema: map['tema'],
      subtema: map['subtema'],
      dificultad: map['dificultad'],
      premisa: map['premisa'],
      opciones: Map<String, String>.from(map['opciones']),
      opcionCorrecta: map['opcionCorrecta'],
      solucion: map['solucion'],
      imagenUrl: map['imagenUrl'],
      solucionImagenUrl: map['solucionImagenUrl'], // Nuevo campo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tema': tema,
      'subtema': subtema,
      'dificultad': dificultad,
      'premisa': premisa,
      'opciones': opciones,
      'opcionCorrecta': opcionCorrecta,
      'solucion': solucion,
      'imagenUrl': imagenUrl,
      'solucionImagenUrl': solucionImagenUrl, // Nuevo campo
    };
  }
}

class ExerciseSession {
  final List<ExerciseModel> exercises;
  final bool randomOrder;
  final Map<String, int> puntosPorDificultad = {
    'facil': 1,
    'medio': 3,
    'dificil': 5,
    'experto': 10,
  };
  final Map<String, int> penalizacionPorDificultad = {
    'facil': 0,
    'medio': -1,
    'dificil': -3,
    'experto': -5,
  };

  ExerciseSession({
    required this.exercises,
    required this.randomOrder,
  });

  int calculatePoints(List<bool> results) {
    int total = 0;
    for (int i = 0; i < results.length; i++) {
      final exercise = exercises[i];
      if (results[i]) {
        total += puntosPorDificultad[exercise.dificultad] ?? 0;
      } else {
        total += penalizacionPorDificultad[exercise.dificultad] ?? 0;
      }
    }
    return total;
  }
}