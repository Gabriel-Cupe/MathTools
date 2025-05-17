import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TextoMatematico extends StatelessWidget {
  final String texto;
  final double fontSize;
  final Color? textColor;
  final TextAlign? textAlign;

  const TextoMatematico(
    this.texto, {
    super.key,
    this.fontSize = 16,
    this.textColor,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    try {
      if (!texto.contains(r'$') && !texto.contains('**')) {
        return Text(
          texto,
          textAlign: textAlign,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        );
      }

      final partes = _procesarTexto(texto);
      final defaultColor = textColor ?? Theme.of(context).textTheme.bodyLarge?.color;

      return RichText(
        textAlign: textAlign ?? TextAlign.start,
        text: TextSpan(
          style: TextStyle(
            fontSize: fontSize,
            color: defaultColor,
          ),
          children: partes.map((parte) {
            if (parte.esFormula) {
              return WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Math.tex(
                    parte.contenido,
                    textStyle: TextStyle(
                      fontSize: fontSize,
                      color: defaultColor,
                    ),
                    mathStyle: MathStyle.text,
                    onErrorFallback: (e) => Text(
                      'Fórmula inválida',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // Manejar negritas (**texto**)
              final negritaRegex = RegExp(r'\*\*(.*?)\*\*');
              final spans = <InlineSpan>[];
              int lastIndex = 0;

              for (final match in negritaRegex.allMatches(parte.contenido)) {
                if (match.start > lastIndex) {
                  spans.add(TextSpan(
                    text: parte.contenido.substring(lastIndex, match.start),
                    style: TextStyle(color: defaultColor),
                  ));
                }

                spans.add(TextSpan(
                  text: match.group(1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: defaultColor,
                  ),
                ));

                lastIndex = match.end;
              }

              if (lastIndex < parte.contenido.length) {
                spans.add(TextSpan(
                  text: parte.contenido.substring(lastIndex),
                  style: TextStyle(color: defaultColor),
                ));
              }

              return TextSpan(children: spans);
            }
          }).toList(),
        ),
      );
    } catch (e) {
      return Text(
        texto,
        textAlign: textAlign,
        style: TextStyle(
          color: Colors.red,
          fontSize: fontSize,
        ),
      );
    }
  }

  List<_ParteTexto> _procesarTexto(String input) {
    final regex = RegExp(r'\$(.*?)\$');
    final partes = <_ParteTexto>[];
    int lastIndex = 0;

    for (final match in regex.allMatches(input)) {
      if (match.start > lastIndex) {
        partes.add(_ParteTexto(
          input.substring(lastIndex, match.start),
          false,
        ));
      }
      partes.add(_ParteTexto(match.group(1)!, true));
      lastIndex = match.end;
    }

    if (lastIndex < input.length) {
      partes.add(_ParteTexto(input.substring(lastIndex), false));
    }

    return partes;
  }
}

class _ParteTexto {
  final String contenido;
  final bool esFormula;

  _ParteTexto(this.contenido, this.esFormula);
}