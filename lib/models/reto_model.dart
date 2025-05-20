class RetoModel {
  final String id;
  final String premisa;
  final String? imagenUrl;
  final Map<String, String> opciones;
  final String opcionCorrecta;
  final String solucion;
  final String apartado;
  final DateTime fechaPublicacion;
  final int puntosRecompensa;

  RetoModel({
    required this.id,
    required this.premisa,
    this.imagenUrl,
    required this.opciones,
    required this.opcionCorrecta,
    required this.solucion,
    required this.apartado,
    required this.fechaPublicacion,
    this.puntosRecompensa = 10,
  });

  factory RetoModel.fromMap(Map<String, dynamic> map) {
    // Manejo correcto del timestamp
    dynamic fecha = map['fechaPublicacion'];
    DateTime fechaPublicacion;
    
    if (fecha is int || fecha is double) {
      // Si es un número (timestamp en milisegundos)
      fechaPublicacion = DateTime.fromMillisecondsSinceEpoch(fecha.toInt());
    } else if (fecha is String) {
      // Si es un string (formato ISO o timestamp como string)
      fechaPublicacion = DateTime.tryParse(fecha) ?? 
          DateTime.fromMillisecondsSinceEpoch(int.tryParse(fecha) ?? DateTime.now().millisecondsSinceEpoch);
    } else {
      // Valor por defecto si no se puede parsear
      fechaPublicacion = DateTime.now();
    }

    return RetoModel(
      id: map['id'] ?? '',
      premisa: map['premisa'] ?? '',
      imagenUrl: map['imagenUrl'],
      opciones: Map<String, String>.from(map['opciones'] ?? {}),
      opcionCorrecta: map['opcionCorrecta'] ?? '',
      solucion: map['solucion'] ?? '',
      apartado: map['apartado'] ?? '',
      fechaPublicacion: fechaPublicacion,
      puntosRecompensa: map['puntosRecompensa']?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'premisa': premisa,
      'imagenUrl': imagenUrl,
      'opciones': opciones,
      'opcionCorrecta': opcionCorrecta,
      'solucion': solucion,
      'apartado': apartado,
      'fechaPublicacion': fechaPublicacion.millisecondsSinceEpoch,
      'puntosRecompensa': puntosRecompensa,
    };
  }
}