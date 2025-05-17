import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/challenge/reto_screen.dart';
import 'package:mathtools/models/reto_model.dart';
import 'package:mathtools/services/reto_service.dart';
import 'package:mathtools/widgets/texto_matematico.dart';

class DailyChallengeContainer extends StatefulWidget {

  const DailyChallengeContainer({
    super.key,
  });

  @override
  State<DailyChallengeContainer> createState() => _DailyChallengeContainerState();
}

class _DailyChallengeContainerState extends State<DailyChallengeContainer> {
  final RetoService _retoService = RetoService();
  RetoModel? _reto;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarReto();
  }

  Future<void> _cargarReto() async {
    try {
      final data = await _retoService.obtenerProblemaDelDia();
      if (data != null) {
        setState(() {
          _reto = RetoModel.fromMap(data);
          _isLoading = false;
          _error = null;
        });
      } else {
        setState(() {
          _error = 'No hay reto disponible hoy';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el reto';
        _isLoading = false;
      });
      debugPrint('Error loading daily challenge: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF2196F3);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF2D3748);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    if (_isLoading) {
      return _buildLoadingContainer(cardColor);
    }

    if (_error != null) {
      return _buildErrorContainer(_error!, cardColor, textColor);
    }

    if (_reto == null) {
      return _buildNoChallengeContainer(cardColor, textColor);
    }

    return _buildChallengeContainer(
      context,
      _reto!,
      isDarkMode,
      primaryColor,
      textColor,
      cardColor,
    );
  }

  Widget _buildLoadingContainer(Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Widget _buildErrorContainer(String error, Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: GoogleFonts.poppins(color: textColor),
      ),
    );
  }

  Widget _buildNoChallengeContainer(Color cardColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'No hay reto disponible hoy',
        style: GoogleFonts.poppins(color: textColor),
      ),
    );
  }

  Widget _buildChallengeContainer(
    BuildContext context,
    RetoModel reto,
    bool isDarkMode,
    Color primaryColor,
    Color textColor,
    Color cardColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reto Diario',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidStar,
                            size: 15,
                            color: const Color(0xFFFFD700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.grey.shade800.withOpacity(0.5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reto.apartado,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido desplazable
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextoMatematico(
                    reto.premisa,
                    fontSize: 14,
                    textColor: textColor.withOpacity(0.9),
                  ),
if (reto.imagenUrl != null && reto.imagenUrl!.isNotEmpty) ...[
  const SizedBox(height: 12),
  Container( // Contenedor padre invisible de ancho completo
    width: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 200, // Altura máxima que deseas
        ),
        child: Image.network(
          reto.imagenUrl!,
          fit: BoxFit.scaleDown, // Ajusta manteniendo relación de aspecto
          width: double.infinity, // Ocupa el ancho disponible del padre
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      ),
    ),
  ),
],
                ],
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RetoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.boltLightning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Resolver Reto',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}