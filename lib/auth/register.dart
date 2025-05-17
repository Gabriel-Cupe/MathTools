import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';
import 'dart:math';

class RegisterService {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');
  final DatabaseReference _counterRef = FirebaseDatabase.instance.ref().child('user_counter');

  Future<Map<String, dynamic>?> registerUser({
    required String username,
    required String password,
  }) async {
    try {
      // Verificar si el username ya existe
      final usernameSnapshot = await _usersRef
          .orderByChild('username')
          .equalTo(username)
          .once();

      if (usernameSnapshot.snapshot.value != null) {
        return {'error': 'Username already exists'};
      }

      // Obtener el siguiente número de usuario
      final counterSnapshot = await _counterRef.once();
      int nextIdNumber = 1;
      
      if (counterSnapshot.snapshot.value != null) {
        nextIdNumber = (counterSnapshot.snapshot.value as int) + 1;
      }

      // Actualizar el contador
      await _counterRef.set(nextIdNumber);

      // Generar letra aleatoria (A-Z)
      final random = Random();
      final randomLetter = String.fromCharCode(65 + random.nextInt(26)); // A-Z

      // Formatear el ID con 6 dígitos y la letra
      final userId = '${nextIdNumber.toString().padLeft(6, '0')}$randomLetter';

      // Crear nuevo usuario
      final newUser = UserModel(
        id: userId,
        username: username,
        password: password,
        isOnline: true,
        seUnio: DateTime.now().year,
      );

      // Guardar usuario en la base de datos
      await _usersRef.child(userId).set(newUser.toMap());

      return {
        'userId': userId,
        'username': username
      };
    } catch (e) {
      return {'error': 'Registration failed: ${e.toString()}'};
    }
  }
}