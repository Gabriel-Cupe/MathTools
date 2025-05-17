import 'package:firebase_database/firebase_database.dart';
import 'package:mathtools/models/user_model.dart';

class PuntosService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Actualizar puntos de un usuario
  Future<void> actualizarPuntos(String userId, int nuevosPuntos) async {
    await _dbRef.child('users/$userId').update({
      'points': nuevosPuntos,
    });
    await _actualizarGlobalRank();
  }

  // Añadir puntos a un usuario
  Future<void> addPuntos(String userId, int addPuntos) async {
    final userRef = _dbRef.child('users/$userId');
    final snapshot = await userRef.get();
    
    if (snapshot.exists) {
      final currentPoints = (snapshot.value as Map)['points'] as int? ?? 0;
      await userRef.update({
        'points': currentPoints + addPuntos,
      });
      await actualizarTodosLosRanks();
    }
  }

  // Actualizar el ranking global de todos los usuarios
  Future<void> _actualizarGlobalRank() async {
    final usersSnapshot = await _dbRef.child('users').get();
    
    if (usersSnapshot.exists) {
      final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;
      final usersList = usersMap.entries.map((entry) {
        final userData = entry.value as Map<dynamic, dynamic>;
        return UserModel.fromMap(Map<String, dynamic>.from(userData));
      }).toList();

      // Ordenar usuarios por puntos (descendente)
      usersList.sort((a, b) => b.points.compareTo(a.points));

      // Actualizar el global_rank de cada usuario según su posición
      final batchUpdates = <String, Map<String, dynamic>>{};
      for (int i = 0; i < usersList.length; i++) {
        final userId = usersList[i].id;
        batchUpdates['users/$userId'] = {'global_rank': i + 1}; // Rank 1 es el mejor
      }

      await _dbRef.update(batchUpdates);
    }
  }

  // Obtener stream de cambios en el ranking
  Stream<List<UserModel>> get rankingGlobalStream {
    return _dbRef.child('users')
      .orderByChild('global_rank')
      .onValue
      .map((event) {
        if (event.snapshot.exists) {
          final usersMap = event.snapshot.value as Map<dynamic, dynamic>;
          return usersMap.entries
              .map((entry) => UserModel.fromMap(
                    Map<String, dynamic>.from(entry.value as Map),
                  ))
              .toList()
            ..sort((a, b) => a.globalRank.compareTo(b.globalRank));
        }
        return [];
      });
  }

  // Obtener posición específica de un usuario
  Future<int> obtenerRankingUsuario(String userId) async {
    final snapshot = await _dbRef.child('users/$userId/global_rank').get();
    return snapshot.exists ? snapshot.value as int : 0;
  }

  // Obtener los top N usuarios
  Future<List<UserModel>> obtenerTopUsuarios(int cantidad) async {
    final snapshot = await _dbRef.child('users')
      .orderByChild('global_rank')
      .limitToFirst(cantidad)
      .get();

    if (snapshot.exists) {
      final usersMap = snapshot.value as Map<dynamic, dynamic>;
      return usersMap.entries
          .map((entry) => UserModel.fromMap(
                Map<String, dynamic>.from(entry.value as Map),
              ))
          .toList()
        ..sort((a, b) => a.globalRank.compareTo(b.globalRank));
    }
    return [];
  }
// En puntos.dart
Future<void> actualizarRankingGlobal() async {
  await _actualizarGlobalRank();
}  
// Añade este método a tu PuntosService existente

Future<void> actualizarTodosLosRanks() async {
  try {
    // Obtener todos los usuarios ordenados por puntos (descendente)
    final snapshot = await _dbRef.child('users')
      .orderByChild('points')
      .get();

    if (!snapshot.exists) return;

    final usersMap = Map<String, dynamic>.from(snapshot.value as Map);
    final sortedUsers = usersMap.entries.toList()
      ..sort((a, b) => (b.value['points'] as num).compareTo(a.value['points'] as num));

    // Preparar actualización masiva
    final Map<String, dynamic> updates = {};

    // Asignar ranks según posición
    for (int i = 0; i < sortedUsers.length; i++) {
      final userId = sortedUsers[i].key;
      updates['users/$userId/global_rank'] = i + 1; // Rank 1 es el top
    }

    // Aplicar todas las actualizaciones en una sola transacción
    await _dbRef.update(updates);
    print('Todos los rankings actualizados correctamente');
  } catch (e) {
    print('Error al actualizar rankings: $e');
  }
}
}