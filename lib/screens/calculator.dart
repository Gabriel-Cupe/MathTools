import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

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
  double _gamma(double x) {
    if (x < 0.5) {
      return math.pi / (math.sin(math.pi * x) * _gamma(1 - x));
    }
    
    double t = x + 6.5;
    double sum = 1.000000000190015;
    sum += 76.18009172947146 / (x + 1);
    sum -= 86.50532032941677 / (x + 2);
    sum += 24.01409824083091 / (x + 3);
    sum -= 1.231739572450155 / (x + 4);
    sum += 0.1208650973866179e-2 / (x + 5);
    sum -= 0.5395239384953e-5 / (x + 6);
    
    return math.pow(t, x - 0.5) * math.exp(-t) * math.sqrt(2 * math.pi) * sum;
  }

  double _factorial(double x) {
    if (x.floor() == x && x >= 0) {
      // For positive integers
      double result = 1;
      for (int i = 2; i <= x; i++) {
        result *= i;
      }
      return result;
    } else {
      // For decimals and negative numbers using gamma function
      return _gamma(x + 1);
    }
  }

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
        _currentInput = result.toString();
        _display = _currentInput;
        _firstOperand = null;
        _operation = null;
      });
    }
  }

  void _scientificFunction(String function) {
    double input = double.parse(_currentInput);
    double result = 0;

    switch (function) {
      case 'sin':
        result = _isRadians ? math.sin(input) : math.sin(input * math.pi / 180);
        break;
      case 'cos':
        result = _isRadians ? math.cos(input) : math.cos(input * math.pi / 180);
        break;
      case 'tan':
        result = _isRadians ? math.tan(input) : math.tan(input * math.pi / 180);
        break;
      case 'asin':
        result = _isRadians ? math.asin(input) : math.asin(input) * 180 / math.pi;
        break;
      case 'acos':
        result = _isRadians ? math.acos(input) : math.acos(input) * 180 / math.pi;
        break;
      case 'atan':
        result = _isRadians ? math.atan(input) : math.atan(input) * 180 / math.pi;
        break;
      case 'log':
        result = math.log(input) / math.ln10;
        break;
      case 'ln':
        result = math.log(input);
        break;
      case '√':
        result = math.sqrt(input);
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
        result = 1 / input;
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
      _currentInput = result.toString();
      _display = _currentInput;
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
              child: Text(
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
                        child: Text(
                          _display,
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: _displayTextColor,
                          ),
                        ),
                      ),
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
                      onPressed: () => _scientificFunction('π'),
                    ),
                    _buildButton(
                      text: 'e',
                      color: _scientificButtonColor,
                      onPressed: () => _scientificFunction('e'),
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
}