import 'package:firebase_database/firebase_database.dart';
import 'package:mathtools/puntos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class LoginService {
  final PuntosService _puntosService = PuntosService();
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref().child('users');


Future<UserModel?> loginUser({
  required String userId,
  required String password,
}) async {
  try {
    // Validaciones existentes...
    final userSnapshot = await _usersRef.child(userId).once();
    if (userSnapshot.snapshot.value == null) return null;

    final user = UserModel.fromMap(
      Map<String, dynamic>.from(userSnapshot.snapshot.value as Map)
    );

    if (user.password != password) return null;
    if (user.banned) return null;

    // Actualización original
    await _usersRef.child(user.id).update({'is_online': true});

    // Añadir ESTO para actualizar todos los ranks (asíncrono)
    _puntosService.actualizarTodosLosRanks().then((_) {
      print('Rankings globales actualizados después del login');
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', user.id);

    return user;
  } catch (e) {
    print('Error en login: $e');
    return null;
  }
}
}