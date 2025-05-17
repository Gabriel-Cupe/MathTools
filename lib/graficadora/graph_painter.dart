import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

class FunctionGraphPainter extends CustomPainter {
  final List<String> functions;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;
  final List<Color> lineColors;
  final double scale;
  final bool isDark;

  FunctionGraphPainter({
    required this.functions,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    required this.lineColors,
    this.scale = 1.0,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawFunctions(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = isDark ? Colors.grey.withOpacity(0.5) : Colors.grey.withOpacity(0.5)
      ..strokeWidth = 0.5 * scale;

    final majorGridPaint = Paint()
      ..color = isDark ? Colors.grey.withOpacity(0.8) : Colors.grey.withOpacity(0.8)
      ..strokeWidth = 0.8 * scale;

    // Ajustamos las coordenadas para mantener proporción cuadrada
    final width = size.width;
    final height = size.height;
    final contentRatio = (xMax - xMin) / (yMax - yMin);
    final screenRatio = width / height;
    
    double scaleX, scaleY, offsetX = 0, offsetY = 0;
    
    if (contentRatio > screenRatio) {
      // El contenido es más ancho que la pantalla
      scaleX = width / (xMax - xMin);
      scaleY = scaleX;
      offsetY = (height - (yMax - yMin) * scaleY) / 2;
    } else {
      // El contenido es más alto que la pantalla
      scaleY = height / (yMax - yMin);
      scaleX = scaleY;
      offsetX = (width - (xMax - xMin) * scaleX) / 2;
    }

    double toX(double x) => (x - xMin) * scaleX + offsetX;
    double toY(double y) => height - (y - yMin) * scaleY - offsetY;

    final gridStep = _calculateGridStep();
    final startX = (xMin / gridStep).floor() * gridStep;
    final startY = (yMin / gridStep).floor() * gridStep;

    // Dibujar líneas verticales
    for (var x = startX; x <= xMax; x += gridStep) {
      final xPos = toX(x);
      if (xPos >= 0 && xPos <= width) {
        canvas.drawLine(
          Offset(xPos, 0),
          Offset(xPos, height),
          x % (gridStep * 5) == 0 ? majorGridPaint : gridPaint,
        );
      }
    }

    // Dibujar líneas horizontales
    for (var y = startY; y <= yMax; y += gridStep) {
      final yPos = toY(y);
      if (yPos >= 0 && yPos <= height) {
        canvas.drawLine(
          Offset(0, yPos),
          Offset(width, yPos),
          y % (gridStep * 5) == 0 ? majorGridPaint : gridPaint,
        );
      }
    }
  }

  double _calculateGridStep() {
    final rangeX = xMax - xMin;
    final rangeY = yMax - yMin;
    final range = min(rangeX, rangeY); // Usamos el rango más pequeño
    
    if (range <= 0) return 1.0; // Evitar división por cero
    
    // Calculamos el paso basado en potencias de 10
    final power = (log(range) / ln10).floor();
    final fraction = range / pow(10, power);
    
    double step;
    if (fraction > 5) {
      step = pow(10, power).toDouble();
    } else if (fraction > 2) step = pow(10, power).toDouble() / 2;
    else if (fraction > 1) step = pow(10, power).toDouble() / 5;
    else step = pow(10, power).toDouble() / 10;
    
    // Limitamos el paso mínimo y máximo
    if (step < 1e-13) return 1e-13;
    if (step > 1e10) return 1e10;
    
    return step;
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeWidth = 1.8 * scale;

    final labelStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 10 * scale,
      backgroundColor: isDark ? Colors.grey[900]!.withOpacity(0.7) : Colors.white.withOpacity(0.7),
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Ajuste de coordenadas para mantener proporción cuadrada
    final width = size.width;
    final height = size.height;
    final contentRatio = (xMax - xMin) / (yMax - yMin);
    final screenRatio = width / height;
    
    double scaleX, scaleY, offsetX = 0, offsetY = 0;
    
    if (contentRatio > screenRatio) {
      scaleX = width / (xMax - xMin);
      scaleY = scaleX;
      offsetY = (height - (yMax - yMin) * scaleY) / 2;
    } else {
      scaleY = height / (yMax - yMin);
      scaleX = scaleY;
      offsetX = (width - (xMax - xMin) * scaleX) / 2;
    }

    double toX(double x) => (x - xMin) * scaleX + offsetX;
    double toY(double y) => height - (y - yMin) * scaleY - offsetY;

    // Dibujar eje X
    final xAxisY = toY(0);
    if (xAxisY >= 0 && xAxisY <= height) {
      canvas.drawLine(
        Offset(0, xAxisY),
        Offset(width, xAxisY),
        axisPaint,
      );
    }

    // Dibujar eje Y
    final yAxisX = toX(0);
    if (yAxisX >= 0 && yAxisX <= width) {
      canvas.drawLine(
        Offset(yAxisX, 0),
        Offset(yAxisX, height),
        axisPaint,
      );
    }

    // Dibujar etiquetas en los ejes
    final gridStep = _calculateGridStep();
    final startX = (xMin / gridStep).floor() * gridStep;
    final startY = (yMin / gridStep).floor() * gridStep;

    // Etiquetas del eje X
    for (var x = startX; x <= xMax; x += gridStep) {
      if (x != 0) { // No dibujar en el origen
        final xPos = toX(x);
        if (xPos >= 0 && xPos <= width) {
          final label = _formatLabel(x);
          textPainter.text = TextSpan(text: label, style: labelStyle);
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(xPos - textPainter.width / 2, xAxisY + 4 * scale),
          );
        }
      }
    }

    // Etiquetas del eje Y
    for (var y = startY; y <= yMax; y += gridStep) {
      if (y != 0) { // No dibujar en el origen
        final yPos = toY(y);
        if (yPos >= 0 && yPos <= height) {
          final label = _formatLabel(y);
          textPainter.text = TextSpan(text: label, style: labelStyle);
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(yAxisX + 4 * scale, yPos - textPainter.height / 2),
          );
        }
      }
    }

    // Etiqueta del origen (0,0)
    if (xMin <= 0 && xMax >= 0 && yMin <= 0 && yMax >= 0) {
      final xPos = toX(0);
      final yPos = toY(0);
      if (xPos >= 0 && xPos <= width && yPos >= 0 && yPos <= height) {
        textPainter.text = TextSpan(text: '0', style: labelStyle);
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(yAxisX + 4 * scale, xAxisY + 4 * scale),
        );
      }
    }
  }

  String _formatLabel(double value) {
    if (value.abs() >= 1000 || (value.abs() <= 0.001 && value != 0)) {
      return value.toStringAsExponential(2);
    } else if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      // Mostrar hasta 4 decimales si es necesario
      final str = value.toString();
      return str.length > 6 ? value.toStringAsFixed(4) : str;
    }
  }

  void _drawFunctions(Canvas canvas, Size size) {
    // Ajuste de coordenadas para mantener proporción cuadrada
    final width = size.width;
    final height = size.height;
    final contentRatio = (xMax - xMin) / (yMax - yMin);
    final screenRatio = width / height;
    
    double scaleX, scaleY, offsetX = 0, offsetY = 0;
    
    if (contentRatio > screenRatio) {
      scaleX = width / (xMax - xMin);
      scaleY = scaleX;
      offsetY = (height - (yMax - yMin) * scaleY) / 2;
    } else {
      scaleY = height / (yMax - yMin);
      scaleX = scaleY;
      offsetX = (width - (xMax - xMin) * scaleX) / 2;
    }

    double toX(double x) => (x - xMin) * scaleX + offsetX;
    double toY(double y) => height - (y - yMin) * scaleY - offsetY;

    for (var i = 0; i < functions.length; i++) {
      final function = functions[i];
      final color = lineColors[i % lineColors.length];
      
      try {
        String processedFunc = function
            .replaceAll('sen', 'sin')
            .replaceAllMapped(RegExp(r'(\d)(\()'), (m) => '${m.group(1)}*${m.group(2)}')
            .replaceAllMapped(RegExp(r'\)(\d)'), (m) => ')*${m.group(1)}')
            .replaceAllMapped(RegExp(r'\)\('), (m) => ')*(');

        // Manejo especial para logaritmos
        processedFunc = processedFunc.replaceAllMapped(
          RegExp(r'log\(([^,]+?),([^)]+)\)'), 
          (m) => '(ln(${m.group(2)})/ln(${m.group(1)}))'
        ).replaceAllMapped(
          RegExp(r'log\(([^)]+)\)'),
          (m) => '(log10(${m.group(1)}))'
        );

        final parser = Parser();
        final expr = parser.parse(processedFunc);
        final context = ContextModel();

        final paint = Paint()
          ..color = color
          ..strokeWidth = 2.5 * scale
          ..style = PaintingStyle.stroke;

        final path = Path();
        var firstPoint = true;
        var lastValidY = double.nan;
        final double step = (xMax - xMin) / (width * 1.5);

        for (var x = xMin; x <= xMax; x += step) {
          try {
            context.bindVariable(Variable('x'), Number(x));
            final y = expr.evaluate(EvaluationType.REAL, context);

            if (y.isFinite && !y.isNaN) {
              final xPixel = toX(x);
              final yPixel = toY(y);

              if (!lastValidY.isNaN && (y - lastValidY).abs() > (yMax - yMin) * 0.5) {
                firstPoint = true;
              }

              if (xPixel >= -100 && xPixel <= width + 100 &&
                  yPixel >= -100 && yPixel <= height + 100) {
                if (firstPoint) {
                  path.moveTo(xPixel, yPixel);
                  firstPoint = false;
                } else {
                  path.lineTo(xPixel, yPixel);
                }
                lastValidY = y;
              }
            } else {
              firstPoint = true;
              lastValidY = double.nan;
            }
          } catch (e) {
            firstPoint = true;
            lastValidY = double.nan;
            continue;
          }
        }

        canvas.drawPath(path, paint);
        
        // Dibujar asíntotas para funciones racionales
        if (function.contains('/')) {
          _drawAsymptotes(canvas, size, processedFunc, color);
        }
      } catch (e) {
        debugPrint('Error al dibujar función $function: ${e.toString()}');
      }
    }
  }

  void _drawAsymptotes(Canvas canvas, Size size, String function, Color color) {
    try {
      final parser = Parser();
      final context = ContextModel();
      final asymptotePaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 1 * scale
        ..style = PaintingStyle.stroke;

      if (function.contains('/')) {
        final parts = function.split('/');
        if (parts.length > 1) {
          final denominator = parts[1].contains('(') 
              ? parts[1].substring(0, parts[1].indexOf('(') + 1)
              : parts[1];
          
          final denominatorExpr = parser.parse(denominator);
          
          final step = (xMax - xMin) / 100;
          double? lastValue;
          
          for (double x = xMin; x <= xMax; x += step) {
            try {
              context.bindVariable(Variable('x'), Number(x));
              final value = denominatorExpr.evaluate(EvaluationType.REAL, context);
              
              if (lastValue != null && value * lastValue <= 0) {
                // Ajuste de coordenadas para mantener proporción cuadrada
                final width = size.width;
                final height = size.height;
                final contentRatio = (xMax - xMin) / (yMax - yMin);
                final screenRatio = width / height;
                
                double scaleX, offsetX = 0;
                
                if (contentRatio > screenRatio) {
                  scaleX = width / (xMax - xMin);
                } else {
                  scaleX = height / (yMax - yMin);
                  offsetX = (width - (xMax - xMin) * scaleX) / 2;
                }

                double toX(double x) => (x - xMin) * scaleX + offsetX;
                final xPixel = toX(x);
                
                canvas.drawLine(
                  Offset(xPixel, 0),
                  Offset(xPixel, height),
                  asymptotePaint,
                );
              }
              lastValue = value;
            } catch (e) {
              continue;
            }
          }
        }
      }
    } catch (e) {
      // Ignorar errores en asíntotas
    }
  }

  @override
  bool shouldRepaint(covariant FunctionGraphPainter oldDelegate) =>
      functions != oldDelegate.functions ||
      xMin != oldDelegate.xMin ||
      xMax != oldDelegate.xMax ||
      yMin != oldDelegate.yMin ||
      yMax != oldDelegate.yMax ||
      scale != oldDelegate.scale ||
      isDark != oldDelegate.isDark;
}