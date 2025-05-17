import 'package:firebase_database/firebase_database.dart';

class RetoService {
  final DatabaseReference _retoRef = FirebaseDatabase.instance.ref('retos/problema_del_dia');

  Future<Map<String, dynamic>?> obtenerProblemaDelDia() async {
    try {
      final snapshot = await _retoRef.get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      }
      print('No se encontró el reto en Firebase'); // Debug
      return null;
    } catch (e) {
      print('Error al obtener reto: $e'); // Debug
      return null;
    }
  }
}