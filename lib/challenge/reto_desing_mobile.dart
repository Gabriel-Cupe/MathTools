import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mathtools/models/reto_model.dart';
import 'package:mathtools/widgets/texto_matematico.dart';
import 'package:iconsax/iconsax.dart';

class RetoDesignMobile extends StatelessWidget {
  final RetoModel reto;
  final String? opcionSeleccionada;
  final bool mostrarSolucion;
  final bool respuestaCorrecta;
  final bool puntosOtorgados;
  final bool mismoDia;
  final int puntosUsuario;
  final Function(String?) onOpcionSeleccionada;
  final VoidCallback onVerSolucion;

  const RetoDesignMobile({
    super.key,
    required this.reto,
    required this.opcionSeleccionada,
    required this.mostrarSolucion,
    required this.respuestaCorrecta,
    required this.puntosOtorgados,
    required this.mismoDia,
    required this.puntosUsuario,
    required this.onOpcionSeleccionada,
    required this.onVerSolucion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final primaryColor = Colors.blue.shade700; // Color primario azul profesional

    return Scaffold(
appBar: AppBar(
  leading: IconButton(
    icon: Transform.scale(
      scale: 1.2,  // Aumenta ligeramente el tamaño
      child: Icon(
        Iconsax.arrow_left_2,  // Flecha moderna de Iconsax
        color:  Colors.white,  // Color blanco para contraste
 
        size: 24,  // Tamaño óptimo
      ),
    ),
    tooltip: 'Regresar',  // Tooltip personalizado
    splashRadius: 20,  // Reduce el área de splash para que sea más elegante
    onPressed: () => Navigator.pop(context),
  ),
  title: Container(
    margin: const EdgeInsets.only(right: 20), // Compensa el espacio del botón de retroceso
    child: Row(
      mainAxisSize: MainAxisSize.min, // Importante para centrado real
      children: [
        Icon(Icons.emoji_events, 
          color: CupertinoColors.systemYellow,
          size: 28),
        const SizedBox(width: 8),
        Text(
          'Problema del día',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
            color: Colors.white, // Texto blanco para mejor contraste
          ),
        ),
      ],
    ),
  ),
  centerTitle: true,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF2196F3), // Azul claro
          Color(0xFF0D47A1), // Azul oscuro
        ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
        stops: const [0.1, 0.9],
      ),
    ),
  ),
  elevation: 0,
  shape: Border(
    bottom: BorderSide(
      color: Theme.of(context).dividerColor,
      width: 0.5,
    ),
  ),
  iconTheme: IconThemeData(
    color: Colors.white, // Ícono blanco para mejor contraste
  ),
),
    
      backgroundColor: isDark ? colorScheme.surface : Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Tarjeta del problema
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          reto.apartado,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextoMatematico(
                        reto.premisa,
                        fontSize: 15,
                        textColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                      ),
                      const SizedBox(height: 16),
                      if (reto.imagenUrl != null && reto.imagenUrl!.isNotEmpty)
                        Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  reto.imagenUrl!,
                                  width: double.infinity,
                                  height: 180,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tarjeta de opciones
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecciona una opción',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...reto.opciones.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: isDark
                                ? colorScheme.surfaceContainerHighest
                                : Colors.grey.shade50,
                            border: Border.all(
                              color: opcionSeleccionada == entry.key
                                  ? primaryColor
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                            ],
                          ),
                          child: RadioListTile<String>(
                            title: TextoMatematico(
                              entry.value,
                              textColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                            ),
                            value: entry.key,
                            groupValue: opcionSeleccionada,
                            onChanged: (mismoDia)
                                ? null
                                : onOpcionSeleccionada,
                            activeColor: primaryColor,
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return primaryColor;
                              }
                              return isDark
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400;
                            }),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botón de solución
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (opcionSeleccionada == null || mismoDia)
                        ? null
                        : onVerSolucion,
                    icon: const Icon(Iconsax.eye, size: 20),
                    label: Text(
                      'Ver Solución',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                if (mismoDia)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.info_circle,
                              size: 18, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Ya completaste el reto hoy',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),

                // Solución (si está visible)
                if (mostrarSolucion) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? colorScheme.surfaceContainerHighest : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: respuestaCorrecta
                            ? Colors.green.withOpacity(0.4)
                            : Colors.red.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: respuestaCorrecta
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                respuestaCorrecta
                                    ? Iconsax.tick_circle
                                    : Iconsax.close_circle,
                                color: respuestaCorrecta
                                    ? Colors.green
                                    : Colors.red,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              respuestaCorrecta ? '¡Correcto!' : 'Solución',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: respuestaCorrecta
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextoMatematico(
                          reto.solucion,
                          fontSize: 15,
                          textColor: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            respuestaCorrecta
                                ? puntosOtorgados
                                    ? ''
                                    : '✅ Respuesta correcta'
                                : 'La respuesta correcta es ${reto.opcionCorrecta.toUpperCase()}',
                            style: GoogleFonts.poppins(
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  
}