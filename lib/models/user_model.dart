import 'package:firebase_database/firebase_database.dart';

class UserModel {
  final String id;
  final String username;
  final String password;
  final String avatar;
  final String description;
  final bool isOnline;
  final bool isAdmin;
  final bool banned;
  final int points;
  final int globalRank;
  final List<String> achievements;
  late final bool diarioCompleto;
  final DateTime? ultimoIntentoDiario;
  final int seUnio; // Nueva propiedad para el año de registro

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    this.avatar = 'https://i.ibb.co/HL1xkdFM/Chat-GPT-Image-16-may-2025-06-21-25-p-m-modified.png',
    this.description = '',
    this.isOnline = false,
    this.isAdmin = false,
    this.banned = false,
    this.points = 0,
    this.globalRank = 0,
    this.achievements = const [],
    this.diarioCompleto = false,
    this.ultimoIntentoDiario,
    required this.seUnio, // Hacerla requerida
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      avatar: map['avatar'] ?? 'https://i.ibb.co/HL1xkdFM/Chat-GPT-Image-16-may-2025-06-21-25-p-m-modified.png',
      description: map['description'] ?? '',
      isOnline: map['is_online'] ?? false,
      isAdmin: map['is_admin'] ?? false,
      banned: map['banned'] ?? false,
      points: map['points'] ?? 0,
      globalRank: map['global_rank'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      diarioCompleto: map['diario_completo'] ?? false,
      ultimoIntentoDiario: map['ultimo_intento_diario']?.toDate(),
      seUnio: map['se_unio'] ?? DateTime.now().year, // Valor por defecto si no existe
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'avatar': avatar,
      'description': description,
      'is_online': isOnline,
      'is_admin': isAdmin,
      'banned': banned,
      'points': points,
      'global_rank': globalRank,
      'achievements': achievements,
      'diario_completo': diarioCompleto,
      'ultimo_intento_diario': ultimoIntentoDiario,
      'se_unio': seUnio, // Incluir en el mapa
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? password,
    String? avatar,
    String? description,
    bool? isOnline,
    bool? isAdmin,
    bool? banned,
    int? points,
    int? globalRank,
    List<String>? achievements,
    bool? diarioCompleto,
    DateTime? ultimoIntentoDiario,
    int? seUnio,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      isOnline: isOnline ?? this.isOnline,
      isAdmin: isAdmin ?? this.isAdmin,
      banned: banned ?? this.banned,
      points: points ?? this.points,
      globalRank: globalRank ?? this.globalRank,
      achievements: achievements ?? this.achievements,
      diarioCompleto: diarioCompleto ?? this.diarioCompleto,
      ultimoIntentoDiario: ultimoIntentoDiario ?? this.ultimoIntentoDiario,
      seUnio: seUnio ?? this.seUnio,
    );
  }

  UserModel marcarRetoCompletado(bool respuestaCorrecta, int puntosRecompensa) {
    final hoy = DateTime.now();
    final mismoDia = ultimoIntentoDiario != null &&
        ultimoIntentoDiario!.year == hoy.year &&
        ultimoIntentoDiario!.month == hoy.month &&
        ultimoIntentoDiario!.day == hoy.day;

    if (mismoDia || !respuestaCorrecta) {
      return copyWith(
        diarioCompleto: true,
        ultimoIntentoDiario: hoy,
      );
    }

    return copyWith(
      points: points + puntosRecompensa,
      diarioCompleto: true,
      ultimoIntentoDiario: hoy,
    );
  }

  Stream<Map<String, dynamic>> getUserStream(String userId) {
    return FirebaseDatabase.instance
        .ref('users/$userId')
        .onValue
        .map((event) => event.snapshot.value as Map<String, dynamic>? ?? {});
  }
}