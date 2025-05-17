import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mathtools/models/user_model.dart';

class ProfileLogic {
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref().child('users');
  
  Future<UserModel?> loadUserData(String userId) async {
    try {
      final snapshot = await _userRef.child(userId).get();
      if (snapshot.exists) {
        return UserModel.fromMap(Map<String, dynamic>.from(snapshot.value as Map));
      }
      return null;
    } catch (e) {
      debugPrint('Error loading user data: $e');
      return null;
    }
  }

  Future<void> updateAvatar(String userId, String newAvatarUrl) async {
    try {
      await _userRef.child(userId).update({
        'avatar': newAvatarUrl,
        'updated_at': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating avatar: $e');
      rethrow;
    }
  }

  Future<void> updateDescription(String userId, String newDescription) async {
    try {
      await _userRef.child(userId).update({
        'description': newDescription,
        'updated_at': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating description: $e');
      rethrow;
    }
  }

  List<Achievement> getAchievements(int userPoints) {
    return [
      Achievement(
        title: 'Novato',
        pointsRequired: 100,
        icon: Icons.emoji_events_outlined,
        color: Colors.blue,
      ),
      Achievement(
        title: 'Aprendiz',
        pointsRequired: 250,
        icon: Icons.star_outline,
        color: Colors.green,
      ),
      Achievement(
        title: 'Experto',
        pointsRequired: 500,
        icon: Icons.workspace_premium_outlined,
        color: Colors.orange,
      ),
      Achievement(
        title: 'Maestro',
        pointsRequired: 1000,
        icon: Icons.diamond_outlined,
        color: Colors.purple,
      ),
      Achievement(
        title: 'Leyenda',
        pointsRequired: 2000,
        icon: Icons.verified_outlined,
        color: Colors.red,
      ),
    ].map((achievement) => achievement.copyWith(
      unlocked: userPoints >= achievement.pointsRequired,
    )).toList();
  }
}

class Achievement {
  final String title;
  final int pointsRequired;
  final IconData icon;
  final Color color;
  final bool unlocked;

  Achievement({
    required this.title,
    required this.pointsRequired,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });

  Achievement copyWith({
    bool? unlocked,
  }) {
    return Achievement(
      title: title,
      pointsRequired: pointsRequired,
      icon: icon,
      color: color,
      unlocked: unlocked ?? this.unlocked,
    );
  }
}