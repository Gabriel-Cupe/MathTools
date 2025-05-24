import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class ScientificCalculator extends StatefulWidget {
  const ScientificCalculator({super.key});

  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  // Paleta de colores Math Tools
  final Color _primaryColor = const Color(0xFF0924AA);
  final Color _secondaryColor = const Color(0xFF0380FB);
  final Color _accentColor = const Color(0xFFFFCB87);


  // Colores adaptados al tema
  Color get _backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF0F172A)
      : const Color(0xFFF8FAFC);
  
  Color get _displayColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E293B)
      : Colors.white;
  
  Color get _numberButtonColor => Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF334155)
      : const Color(0xFFEDF2F7);
  
  Color get _operationButtonColor => _secondaryColor.withOpacity(0.2);
  Color get _scientificButtonColor => _primaryColor.withOpacity(0.2);
  Color get _equalsButtonColor => _secondaryColor;
  Color get _clearButtonColor => const Color(0xFFE53935).withOpacity(0.2);
  Color get _secondFunctionButtonColor => _accentColor.withOpacity(0.2);
  
  Color get _textColor => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF2D3748);
  
  Color get _displayTextColor => _textColor;

  String _display = '0';
  String _currentInput = '';
  double? _firstOperand;
  String? _operation;
  bool _isRadians = true;
  bool _isSecondFunction = false;
  

  // Gamma function approximation for factorial of non-integers
double gamma(double z) {
  const p = [
    676.5203681218851,
    -1259.1392167224028,
    771.32342877765313,
    -176.61502916214059,
    12.507343278686905,
    -0.13857109526572012,
    9.9843695780195716e-6,
    1.5056327351493116e-7
  ];
  const double g = 7;

  if (z < 0.5) {
    return math.pi / (math.sin(math.pi * z) * gamma(1 - z));
  }

  z -= 1;
  double x = 0.99999999999980993;

  for (int i = 0; i < p.length; i++) {
    x += p[i] / (z + i + 1);
  }

  double t = z + g + 0.5;
  return math.sqrt(2 * math.pi) * math.pow(t, z + 0.5) * math.exp(-t) * x;
}

  double _factorial(double x) {
    if (x < 0) {
      return double.nan; // No definido para negativos
    }
    
    if (x.floor() == x) {
      // Para enteros positivos
      if (x > 170) return double.infinity; // Evitar overflow
      double result = 1;
      for (int i = 2; i <= x; i++) {
        result *= i;
      }
      return result;
    } else {
      // Para decimales usando gamma
      try {
        return gamma(x + 1);
      } catch (e) {
        return double.nan;
      }
    }
  }

  String _formatNumber(double num) {
    if (num.isInfinite) {
      return '∞';
    }
    
    if (num.isNaN) {
      return 'No definido';
    }
    
    // Manejar números muy pequeños (prácticamente cero)
    if (num.abs() >= 1e10 || (num.abs() <= 1e-5 && num != 0)) {
      // Formatear con notación científica
      String sciNotation = num.toStringAsExponential(8);
      
      // Manejar el caso especial de ±∞
      if (sciNotation.contains('Infinity')) {
        return num.isNegative ? '-∞' : '∞';
      }
      
      // Convertir a formato más legible: 1.23e+5 → 1.23×10^5
      sciNotation = sciNotation.replaceAllMapped(
        RegExp(r'([+-]?\d*\.?\d+)e([+-]\d+)'),
        (Match m) => '${m[1]}×10^${int.parse(m[2]!)}' // Convertir exponente a int para quitar ceros
      );
      
      return sciNotation;
    }
    
    // Para números normales, limitar a 10 decimales máximo
    String formatted = num.toString();
    
    // Si tiene muchos decimales, limitarlos
    if (formatted.contains('.') && formatted.split('.')[1].length > 10) {
      formatted = num.toStringAsFixed(10);
    }
    
    // Eliminar ceros decimales innecesarios
    formatted = formatted.replaceAll(RegExp(r'\.0+$'), '')
                         .replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');
    
    return formatted;
  }

//EL PEPEPE
  void _addDigit(String digit) {
    setState(() {
      if (_currentInput == '0' && digit != '.') {
        _currentInput = digit;
      } else {
        _currentInput += digit;
      }
      _display = _currentInput;
    });
  }

  void _addDecimalPoint() {
    if (!_currentInput.contains('.')) {
      _addDigit('.');
    }
  }

  void _clear() {
    setState(() {
      _currentInput = '0';
      _firstOperand = null;
      _operation = null;
      _display = '0';
      _isSecondFunction = false;
    });
  }

  void _deleteLastDigit() {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        if (_currentInput.isEmpty) {
          _currentInput = '0';
        }
        _display = _currentInput;
      });
    }
  }

  void _toggleSign() {
    if (_currentInput.isNotEmpty && _currentInput != '0') {
      setState(() {
        if (_currentInput.startsWith('-')) {
          _currentInput = _currentInput.substring(1);
        } else {
          _currentInput = '-$_currentInput';
        }
        _display = _currentInput;
      });
    }
  }

  void _setOperation(String operation) {
    if (_currentInput.isNotEmpty) {
      setState(() {
        _firstOperand = double.parse(_currentInput);
        _operation = operation;
        _currentInput = '';
        _display = operation;
      });
    }
  }

  void _calculate() {
    if (_firstOperand != null && _operation != null && _currentInput.isNotEmpty) {
      double secondOperand = double.parse(_currentInput);
      double result = 0;

      switch (_operation) {
        case '+':
          result = _firstOperand! + secondOperand;
          break;
        case '-':
          result = _firstOperand! - secondOperand;
          break;
        case '×':
          result = _firstOperand! * secondOperand;
          break;
        case '÷':
          result = _firstOperand! / secondOperand;
          break;
        case '^':
          result = math.pow(_firstOperand!, secondOperand).toDouble();
          break;
        case 'mod':
          result = _firstOperand! % secondOperand;
          break;
      }

      setState(() {
        _currentInput = _formatNumber(result);
        _display = _currentInput;
        _firstOperand = null;
        _operation = null;
      });
    }
  }

  void _scientificFunction(String function) {
    double input;
    try {
      input = double.parse(_currentInput);
    } catch (e) {
      // Si hay un error al parsear (como "No definido")
      setState(() {
        _currentInput = 'No definido';
        _display = _currentInput;
      });
      return;
    }

    double result = 0;
    bool specialCase = false;

    switch (function) {
      case 'sin':
        if (!_isRadians) {
          // Manejar ángulos cuadrantales en grados
          double modAngle = input % 360;
          if (modAngle == 90 || modAngle == 270) {
            specialCase = true;
            result = modAngle == 90 ? double.infinity : double.negativeInfinity;
          } else if (modAngle == 0 || modAngle == 180) {
            specialCase = true;
            result = 0;
          }
        }
        if (!specialCase) {
          result = _isRadians ? math.sin(input) : math.sin(input * math.pi / 180);
        }
        break;
        
      case 'cos':
        if (!_isRadians) {
          // Manejar ángulos cuadrantales en grados
          double modAngle = input % 360;
          if (modAngle == 90 || modAngle == 270) {
            specialCase = true;
            result = 0;
          } else if (modAngle == 0) {
            specialCase = true;
            result = 1;
          } else if (modAngle == 180) {
            specialCase = true;
            result = -1;
          }
        }
        if (!specialCase) {
          result = _isRadians ? math.cos(input) : math.cos(input * math.pi / 180);
        }
        break;
        
      case 'tan':
        if (!_isRadians) {
          // Manejar ángulos cuadrantales en grados
          double modAngle = input % 180;
          if (modAngle == 90) {
            specialCase = true;
            result = input % 360 == 90 ? double.infinity : double.negativeInfinity;
          } else if (input % 180 == 0) {
            specialCase = true;
            result = 0;
          }
        } else {
          // Manejar ángulos cuadrantales en radianes
          double modPi = input % math.pi;
          if (modPi == math.pi/2) {
            specialCase = true;
            result = (input / (math.pi/2)).round() % 2 == 1 ? double.infinity : double.negativeInfinity;
          } else if (modPi == 0) {
            specialCase = true;
            result = 0;
          }
        }
        if (!specialCase) {
          result = _isRadians ? math.tan(input) : math.tan(input * math.pi / 180);
        }
        break;
        
      case 'asin':
        if (input < -1 || input > 1) {
          specialCase = true;
          result = double.nan;
        } else {
          result = _isRadians ? math.asin(input) : math.asin(input) * 180 / math.pi;
        }
        break;
        
      case 'acos':
        if (input < -1 || input > 1) {
          specialCase = true;
          result = double.nan;
        } else {
          result = _isRadians ? math.acos(input) : math.acos(input) * 180 / math.pi;
        }
        break;
        
      case 'atan':
        result = _isRadians ? math.atan(input) : math.atan(input) * 180 / math.pi;
        break;
        
      case 'log':
        if (input <= 0) {
          specialCase = true;
          result = double.nan;
        } else {
          result = math.log(input) / math.ln10;
        }
        break;
        
      case 'ln':
        if (input <= 0) {
          specialCase = true;
          result = double.nan;
        } else {
          result = math.log(input);
        }
        break;
        
      case '√':
        if (input < 0) {
          specialCase = true;
          result = double.nan;
        } else {
          result = math.sqrt(input);
        }
        break;
        
      case 'x²':
        result = math.pow(input, 2).toDouble();
        break;
        
      case 'x³':
        result = math.pow(input, 3).toDouble();
        break;
        
      case 'x^y':
        _setOperation('^');
        return;
        
      case '10^x':
        result = math.pow(10, input).toDouble();
        break;
        
      case 'e^x':
        result = math.exp(input);
        break;
        
      case '1/x':
        if (input == 0) {
          specialCase = true;
          result = double.infinity;
        } else {
          result = 1 / input;
        }
        break;
        
      case '|x|':
        result = input.abs();
        break;
        
      case 'n!':
        result = _factorial(input);
        break;
        
      case 'π':
        result = math.pi;
        break;
        
      case 'e':
        result = math.e;
        break;
        
      case 'mod':
        _setOperation('mod');
        return;
    }

    setState(() {
      _currentInput = _formatNumber(result);
      _display = _currentInput;
    });
  }

  void _useConstant(String constant) {
    setState(() {
      if (_operation != null && _firstOperand != null) {
        // Si hay una operación pendiente, usar la constante como segundo operando
        if (constant == 'π') {
          _currentInput = math.pi.toString();
        } else if (constant == 'e') {
          _currentInput = math.e.toString();
        }
        _display = _currentInput;
      } else {
        // Si no hay operación pendiente, usar la constante como nuevo valor
        if (constant == 'π') {
          _currentInput = math.pi.toString();
        } else if (constant == 'e') {
          _currentInput = math.e.toString();
        }
        _display = _currentInput;
      }
    });
  }

  void _toggleAngleUnit() {
    setState(() {
      _isRadians = !_isRadians;
    });
  }

  void _toggleSecondFunction() {
    setState(() {
      _isSecondFunction = !_isSecondFunction;
    });
  }

  Widget _buildButton({
    required String text,
    Color? color,
    VoidCallback? onPressed,
    bool isWide = false,
    bool isTall = false,
    double fontSize = 20,
  }) {
    return Container(
      margin: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            width: isWide ? 152 : 72,
            height: isTall ? 152 : 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Center(
              child: text.contains('^') || text.contains('∞') || text == 'π' 
                ? Math.tex(
                    text.replaceAll('×10^', '\\times10^{').replaceAll('^', '^{') + (text.contains('^') && !text.contains('}') ? '}' : ''),
                    textStyle: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                      color: _textColor,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Calculadora Científica',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: _textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
      ),
      body: Container(
        color: _backgroundColor,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _displayColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isRadians ? 'RAD' : 'DEG',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _primaryColor,
                              ),
                            ),
                          ),
                          if (_isSecondFunction)
                            const SizedBox(width: 8),
                          if (_isSecondFunction)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '2nd',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _accentColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                                              child: _buildDisplayText(_display),),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Teclado
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  children: [
                    // Fila 1 - Funciones científicas
                    _buildButton(
                      text: _isSecondFunction ? 'asin' : 'sin',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'asin' : 'sin'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? 'acos' : 'cos',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'acos' : 'cos'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? 'atan' : 'tan',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'atan' : 'tan'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? 'x^y' : 'x²',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'x^y' : 'x²'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? 'n!' : 'x³',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'n!' : 'x³'),
                    ),
                    
                    // Fila 2 - Más funciones
                    _buildButton(
                      text: _isSecondFunction ? 'e^x' : 'ln',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'e^x' : 'ln'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? '10^x' : 'log',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? '10^x' : 'log'),
                    ),
                    _buildButton(
                      text: _isSecondFunction ? 'mod' : '√',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction(_isSecondFunction ? 'mod' : '√'),
                    ),
                    _buildButton(
                      text: 'π',
                      color: _scientificButtonColor,
                      onPressed: () => _useConstant('π'),
                    ),
                    _buildButton(
                      text: 'e',
                      color: _scientificButtonColor,
                      onPressed: () => _useConstant('e'),
                    ),
                    
                    // Fila 3 - Controles y operaciones básicas
                    _buildButton(
                      text: '2nd',
                      color: _secondFunctionButtonColor,
                      onPressed: _toggleSecondFunction,
                    ),
                    _buildButton(
                      text: '⌫',
                      color: _clearButtonColor,
                      onPressed: _deleteLastDigit,
                    ),
                    _buildButton(
                      text: 'C',
                      color: _clearButtonColor,
                      onPressed: _clear,
                    ),
                    _buildButton(
                      text: '÷',
                      color: _operationButtonColor,
                      onPressed: () => _setOperation('÷'),
                    ),
                    _buildButton(
                      text: '×',
                      color: _operationButtonColor,
                      onPressed: () => _setOperation('×'),
                    ),
                    
                    // Fila 4 - Números
                    _buildButton(
                      text: '7',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('7'),
                    ),
                    _buildButton(
                      text: '8',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('8'),
                    ),
                    _buildButton(
                      text: '9',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('9'),
                    ),
                    _buildButton(
                      text: '-',
                      color: _operationButtonColor,
                      onPressed: () => _setOperation('-'),
                    ),
                    _buildButton(
                      text: '+',
                      color: _operationButtonColor,
                      onPressed: () => _setOperation('+'),
                      isTall: true,
                    ),
                    
                    // Fila 5 - Más números
                    _buildButton(
                      text: '4',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('4'),
                    ),
                    _buildButton(
                      text: '5',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('5'),
                    ),
                    _buildButton(
                      text: '6',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('6'),
                    ),
                    _buildButton(
                      text: '±',
                      color: _operationButtonColor,
                      onPressed: _toggleSign,
                    ),
                    
                    // Fila 6 - Últimos números y controles
                    _buildButton(
                      text: '1',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('1'),
                    ),
                    _buildButton(
                      text: '2',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('2'),
                    ),
                    _buildButton(
                      text: '3',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('3'),
                    ),
                    _buildButton(
                      text: _isRadians ? 'RAD' : 'DEG',
                      color: _scientificButtonColor,
                      onPressed: _toggleAngleUnit,
                    ),
                    
                    // Fila 7 - Cero y decimal
                    _buildButton(
                      text: '0',
                      color: _numberButtonColor,
                      onPressed: () => _addDigit('0'),
                      isWide: true,
                    ),
                    _buildButton(
                      text: '.',
                      color: _numberButtonColor,
                      onPressed: _addDecimalPoint,
                    ),
                    _buildButton(
                      text: '1/x',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction('1/x'),
                    ),
                    _buildButton(
                      text: '=',
                      color: _equalsButtonColor,
                      onPressed: _calculate,
                      isTall: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildDisplayText(String text) {
    // Lista de patrones que deben ser renderizados con Math.tex
    const mathPatterns = ['×10^', '∞', 'π', '\\^'];
    
    // Verificar si el texto contiene algún patrón matemático
    final shouldUseMathTex = mathPatterns.any((pattern) => text.contains(pattern));
    
    if (shouldUseMathTex) {
      try {
        // Preprocesar el texto para Math.tex
        String texText = text
          .replaceAll('×10^', '\\times 10^{')
          .replaceAllMapped(RegExp(r'\^(-?\d+)'), (m) => '^{${m[1]}}')
          .replaceAll('∞', '\\infty');
        
        // Asegurar que los corchetes estén balanceados
        final openBraces = texText.split('{').length - 1;
        final closeBraces = texText.split('}').length - 1;
        if (openBraces > closeBraces) {
          texText += '}' * (openBraces - closeBraces);
        }
        
        return Math.tex(
          texText,
          textStyle: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: _displayTextColor,
          ),
          onErrorFallback: (error) => Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: _displayTextColor,
            ),
          ),
        );
      } catch (e) {
        // Fallback si hay error en el parseo
        return Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: _displayTextColor,
          ),
        );
      }
    } else {
      return Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: _displayTextColor,
        ),
      );
    }
  }
}