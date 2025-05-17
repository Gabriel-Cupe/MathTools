import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mathtools/models/user_model.dart';
import 'package:mathtools/perfil/profile_avatar.dart';
import 'package:mathtools/perfil/profile_logic.dart';

class PerfilScreen extends StatefulWidget {
  final String userId;

  const PerfilScreen({super.key, required this.userId});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ProfileLogic _logic = ProfileLogic();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isLoading = true;
  bool _isEditingDescription = false;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _logic.loadUserData(widget.userId);
      if (user != null) {
        setState(() {
          _user = user;
          _descriptionController.text = user.description;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAvatar(String newAvatarUrl) async {
    try {
      await _logic.updateAvatar(widget.userId, newAvatarUrl);
      setState(() {
        _user = _user?.copyWith(avatar: newAvatarUrl);
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateDescription() async {
    try {
      await _logic.updateDescription(widget.userId, _descriptionController.text);
      setState(() {
        _user = _user?.copyWith(description: _descriptionController.text);
        _isEditingDescription = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final achievements = _logic.getAchievements(_user?.points ?? 0);

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // Colores adaptativos

    final textColor = isDark ? theme.colorScheme.onSurface : Colors.grey[800];
    final secondaryTextColor = isDark ? theme.colorScheme.onSurface.withOpacity(0.7) : Colors.grey[600];
    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = isDark ? theme.colorScheme.secondary : Colors.deepPurple[400];
    final adminBadgeColor = isDark ? const Color.fromARGB(255, 194, 87, 87) : const Color.fromARGB(255, 252, 111, 111);

    return Scaffold(
      backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
children: [
  Transform.translate(
    offset: const Offset(0, -60),
    child: _buildProfileHeader(
      theme, 
      isDark, 
      adminBadgeColor, // Provide a default color if null
      textColor ?? Colors.black,       // Provide a default color if null
      secondaryTextColor ?? Colors.grey // Provide a default color if null
    ),
  ),
  _buildUserStats(
    theme, 
    isDark, 
    primaryColor,       // Provide a default color if null
    secondaryColor ?? Colors.green,    // Provide a default color if null
    textColor ?? Colors.black,         // Provide a default color if null
    secondaryTextColor ?? Colors.grey  // Provide a default color if null
  ),
  const SizedBox(height: 24),
  _buildAchievementsSection(
    theme, 
    achievements, 
    isDark, 
    textColor ?? Colors.black          // Provide a default color if null
  ),
  const SizedBox(height: 40),
],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, bool isDark, Color adminBadgeColor, Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        const SizedBox(height: 100),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: ProfileAvatar(
                  currentImageUrl: _user!.avatar,
                  onImageUpdated: _updateAvatar,
                ),
              ),
            ),
            if (_user!.isAdmin)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: adminBadgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? theme.colorScheme.surface : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Iconsax.verify,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _user!.username,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          _user!.id,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildDescriptionSection(theme, isDark, textColor, secondaryTextColor),
      ],
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, bool isDark, Color textColor, Color secondaryTextColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          if (!_isEditingDescription)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _user!.description.isEmpty
                          ? 'Aún no hay descripción...'
                          : _user!.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: _user!.description.isEmpty
                            ? secondaryTextColor
                            : textColor,
                        fontStyle: _user!.description.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.edit,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => setState(() => _isEditingDescription = true),
                  ),
                ],
              ),
            ),
          if (_isEditingDescription)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 300,
                    style: GoogleFonts.poppins(color: textColor),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? theme.colorScheme.outline : Colors.grey[300]!,
                        ),
                      ),
                      hintText: 'Describe quién eres...',
                      hintStyle: GoogleFonts.poppins(color: secondaryTextColor),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => setState(() => _isEditingDescription = false),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _updateDescription,
                        child: Text(
                          'Guardar',
                          style: GoogleFonts.poppins(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserStats(ThemeData theme, bool isDark, Color primaryColor, Color secondaryColor, Color textColor, Color secondaryTextColor) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            Iconsax.ranking_1,
            'Posición',
            '#${_user!.globalRank}',
            secondaryColor,
            textColor,
            secondaryTextColor,
          ),
          _buildStatItem(
            Iconsax.star,
            'Puntos',
            '${_user!.points}',
            Colors.amber[600]!,
            textColor,
            secondaryTextColor,
          ),
          _buildStatItem(
            Iconsax.calendar,
            'Activo desde',
            '${_user!.seUnio}',
            Colors.teal[400]!,
            textColor,
            secondaryTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(ThemeData theme, List<Achievement> achievements, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Logros',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(achievement, theme, isDark, textColor);
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, ThemeData theme, bool isDark, Color textColor) {
    final unlockedColor = achievement.unlocked 
        ? achievement.color 
        : (isDark ? Colors.grey[600]! : Colors.grey[300]!);
        
    final progressBgColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHighest : Colors.white;
    final titleColor = achievement.unlocked ? textColor : textColor.withOpacity(0.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark 
              ? theme.colorScheme.outline.withOpacity(0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unlockedColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: achievement.unlocked ? Colors.white : Colors.grey[500],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: achievement.unlocked
                      ? 1.0
                      : (_user!.points / achievement.pointsRequired).clamp(0.0, 1.0),
                  backgroundColor: progressBgColor,
                  color: unlockedColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      achievement.unlocked
                          ? 'Completado'
                          : '${_user!.points}/${achievement.pointsRequired} puntos',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: unlockedColor,
                      ),
                    ),
                    if (achievement.unlocked)
                      Icon(
                        Iconsax.verify,
                        color: unlockedColor,
                        size: 16,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}