import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'convertidor.dart';

class ConvertidorScreen extends StatefulWidget {
  const ConvertidorScreen({super.key});

  @override
  State<ConvertidorScreen> createState() => _ConvertidorScreenState();
}

class _ConvertidorScreenState extends State<ConvertidorScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedUnitType = Convertidor.unitTypes.first;
  String _fromUnit = Convertidor.units[Convertidor.unitTypes.first]!.first;
  String _toUnit = Convertidor.units[Convertidor.unitTypes.first]!.last;
  String _convertedResult = '';
  bool _isLoading = false;

  // Paleta de colores adaptativa por tipo de conversión
  Color _getTypeColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (_selectedUnitType) {
      case 'Longitud':
        return isDark ? Colors.blueAccent.shade400 : Colors.blue.shade700;
      case 'Masa':
        return isDark ? Colors.tealAccent.shade400 : Colors.teal.shade700;
      case 'Temperatura':
        return isDark ? Colors.orangeAccent.shade400 : Colors.orange.shade700;
      case 'Tiempo':
        return isDark ? Colors.purpleAccent.shade400 : Colors.purple.shade700;
      case 'Moneda':
        return isDark ? Colors.greenAccent.shade400 : Colors.green.shade700;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final typeColor = _getTypeColor(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final surfaceVariant = theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Conversor',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
            color: onSurfaceColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: surfaceColor,
        elevation: 0,
        shape: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: onSurfaceColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Card principal
              Card(
                elevation: isDark ? 1 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                color: surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Selector de tipo
                      _buildTypeSelector(typeColor, onSurfaceColor, surfaceVariant),
                      const SizedBox(height: 20),

                      // Selectores de unidades
                      _buildUnitSelectors(typeColor, isDark, surfaceVariant),
                      const SizedBox(height: 20),

                      // Campo de entrada
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: onSurfaceColor,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Valor a convertir',
                          labelStyle: GoogleFonts.poppins(
                            color: onSurfaceColor.withOpacity(0.7),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: typeColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: typeColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: typeColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark 
                              ? surfaceVariant.withOpacity(0.5)
                              : Colors.grey[50]!.withOpacity(0.5),
                          prefixIcon: Icon(
                            _getTypeIcon(),
                            color: typeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón de conversión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _convert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : Text(
                          'Convertir',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Resultado
              if (_convertedResult.isNotEmpty)
                Card(
                  elevation: 0,
                  color: typeColor.withOpacity(isDark ? 0.15 : 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: typeColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Resultado',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: typeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _convertedResult,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: onSurfaceColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (_selectedUnitType) {
      case 'Longitud':
        return Iconsax.ruler;
      case 'Masa':
        return Iconsax.weight;
      case 'Temperatura':
        return Iconsax.cloud_snow;
      case 'Tiempo':
        return Iconsax.clock;
      case 'Moneda':
        return Iconsax.dollar_circle;
      default:
        return Iconsax.convert;
    }
  }

  Widget _buildTypeSelector(Color typeColor, Color textColor, Color surfaceVariant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de conversión',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUnitType,
              isExpanded: true,
              icon: Icon(Iconsax.arrow_down_1, color: textColor),
              dropdownColor: surfaceVariant,
              items: Convertidor.unitTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      type,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnitType = value!;
                  _fromUnit = Convertidor.units[value]!.first;
                  _toUnit = Convertidor.units[value]!.last;
                  _convertedResult = '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitSelectors(Color typeColor, bool isDark, Color surfaceVariant) {
    return Row(
      children: [
        Expanded(child: _buildUnitSelector(true, typeColor, surfaceVariant)),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _swapUnits,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.arrow_swap_horizontal,
              color: typeColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildUnitSelector(false, typeColor, surfaceVariant)),
      ],
    );
  }

  Widget _buildUnitSelector(bool isFrom, Color typeColor, Color surfaceVariant) {
    final currentUnit = isFrom ? _fromUnit : _toUnit;
    final unitList = Convertidor.units[_selectedUnitType]!;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isFrom ? 'De' : 'A',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: textColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentUnit,
              isExpanded: true,
              icon: Icon(Iconsax.arrow_down_1, color: textColor),
              dropdownColor: surfaceVariant,
              items: unitList.map((unit) {
                return DropdownMenuItem(
                  value: unit,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      unit,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  if (isFrom) {
                    _fromUnit = value!;
                  } else {
                    _toUnit = value!;
                  }
                  _convertedResult = '';
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
      _convertedResult = '';
    });
  }

  Future<void> _convert() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ingrese un valor para convertir',
            style: GoogleFonts.poppins(),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _convertedResult = '';
    });

    try {
      final amount = double.parse(_amountController.text);
      final result = await Convertidor.convert(
        unitType: _selectedUnitType,
        amount: amount,
        fromUnit: _fromUnit,
        toUnit: _toUnit,
      );

      setState(() {
        _convertedResult = '${amount.toStringAsFixed(2)} $_fromUnit = '
            '${result.toStringAsFixed(4)} $_toUnit';
      });
    } catch (e) {
      setState(() {
        _convertedResult = 'Error en la conversión';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}