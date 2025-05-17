import 'package:firebase_database/firebase_database.dart';
import 'package:mathtools/models/user_model.dart';

class UserService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');



  Future<UserModel?> obtenerUsuario(String userId) async {
    try {
      final snapshot = await _usersRef.child(userId).get();
      if (snapshot.exists) {
        return UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e'); // Debug
      return null;
    }
  }

Stream<Map<String, dynamic>> getUserStream(String userId) {
  return FirebaseDatabase.instance
      .ref('users/$userId')
      .onValue
      .map((event) => event.snapshot.value as Map<String, dynamic>? ?? {});
}

}