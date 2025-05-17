import 'package:flutter/material.dart';
import 'package:mathtools/perfil/image_service.dart';

class ProfileAvatar extends StatefulWidget {
  final String currentImageUrl;
  final Function(String) onImageUpdated;
  
  const ProfileAvatar({
    super.key,
    required this.currentImageUrl,
    required this.onImageUpdated,
  });

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool _isUploading = false;
  String? _tempImageUrl;

  Future<void> _updateImage() async {
    setState(() => _isUploading = true);
    
    try {
      final imageUrl = await ImageService.pickAndUploadImage();
      if (imageUrl != null) {
        setState(() => _tempImageUrl = imageUrl);
        widget.onImageUpdated(imageUrl);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = _tempImageUrl ?? widget.currentImageUrl;
    
    return GestureDetector(
      onTap: _updateImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: _buildImageProvider(imageUrl),
            child: _isUploading 
                ? null 
                : (imageUrl.isEmpty 
                    ? const Icon(Icons.add_a_photo, size: 30, color: Colors.white)
                    : null),
          ),
          if (_isUploading)
            const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }

  ImageProvider _buildImageProvider(String url) {
    if (url.isEmpty) {
      return const AssetImage('assets/images/default_avatar.png');
    }
    return NetworkImage(url);
  }
}