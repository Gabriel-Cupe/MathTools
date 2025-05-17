import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  List<UserModel> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final snapshot = await _usersRef.get();
      if (snapshot.exists) {
        final usersMap = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _users = usersMap.entries.map((e) {
            return UserModel.fromMap(Map<String, dynamic>.from(e.value as Map));
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading users: $e');
    }
  }

  Future<void> _toggleBan(UserModel user) async {
    try {
      await _usersRef.child(user.id).update({'banned': !user.banned});
      setState(() {
        _users = _users.map((u) => u.id == user.id ? u.copyWith(banned: !u.banned) : u).toList();
      });
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  List<UserModel> get _filteredUsers {
    return _users.where((user) {
      return user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.id.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildUserList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          prefixIcon: const Icon(Iconsax.search_normal, size: 20),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _UserCard(
          user: user,
          onBanPressed: () => _toggleBan(user),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onBanPressed;

  const _UserCard({required this.user, required this.onBanPressed});

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 24, backgroundImage: NetworkImage(user.avatar)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.username, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('ID: ${user.id}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                  if (user.banned) _buildBannedBadge(),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBannedBadge() {
    final errorColor = const Color(0xFFE53935);
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'BANEADO',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: errorColor,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final primaryColor = const Color(0xFF0924AA);
    final errorColor = const Color(0xFFE53935);

    return Row(
      children: [
        IconButton(
          icon: const Icon(Iconsax.profile_circle, size: 22),
          color: primaryColor,
          onPressed: () {/* Navegar a perfil */},
        ),
        IconButton(
          icon: Icon(
            user.banned ? Iconsax.unlock : Iconsax.lock,
            size: 22,
            color: user.banned ? Colors.green : errorColor,
          ),
          onPressed: onBanPressed,
        ),
      ],
    );
  }
}