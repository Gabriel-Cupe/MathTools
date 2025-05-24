import 'package:currency_converter_pro/currency_converter_pro.dart';

class Convertidor {
  // Tipos de unidades soportados
  static const List<String> unitTypes = [
    'Longitud',
    'Masa',
    'Temperatura',
    'Tiempo',
    'Moneda',
  ];

  // Unidades por tipo
  static const Map<String, List<String>> units = {
    'Longitud': ['Metros', 'Kilómetros', 'Millas', 'Pies', 'Pulgadas'],
    'Masa': ['Gramos', 'Kilogramos', 'Libras', 'Onzas'],
    'Temperatura': ['Celsius', 'Fahrenheit', 'Kelvin'],
    'Tiempo': ['Segundos', 'Minutos', 'Horas', 'Días'],
    'Moneda': ['USD', 'EUR', 'JPY', 'GBP', 'MXN', 'PEN', 'COP'],
  };

  // Factores de conversión
  static const Map<String, Map<String, double>> conversionFactors = {
    'Longitud': {
      'Metros': 1.0,
      'Kilómetros': 1000.0,
      'Millas': 1609.34,
      'Pies': 0.3048,
      'Pulgadas': 0.0254,
    },
    'Masa': {
      'Gramos': 1.0,
      'Kilogramos': 1000.0,
      'Libras': 453.592,
      'Onzas': 28.3495,
    },
    'Tiempo': {
      'Segundos': 1.0,
      'Minutos': 60.0,
      'Horas': 3600.0,
      'Días': 86400.0,
    },
  };

  // Conversión principal
  static Future<double> convert({
    required String unitType,
    required double amount,
    required String fromUnit,
    required String toUnit,
  }) async {
    if (unitType == 'Temperatura') {
      return _convertTemperature(amount, fromUnit, toUnit);
    } else if (unitType == 'Moneda') {
      return await _convertCurrency(amount, fromUnit, toUnit);
    } else {
      return _convertStandard(amount, fromUnit, toUnit, unitType);
    }
  }

  // Conversión de monedas usando currency_converter_pro
  static Future<double> _convertCurrency(double amount, String from, String to) async {
    try {
      final converter = CurrencyConverterPro();
      final result = await converter.convertCurrency(
        amount: amount,
        fromCurrency: from.toLowerCase(),
        toCurrency: to.toLowerCase(),
      );
      return result;
    } catch (e) {
      throw Exception('Error al convertir moneda: ${e.toString()}');
    }
  }

  // Conversión estándar
  static double _convertStandard(double value, String fromUnit, String toUnit, String unitType) {
    final fromFactor = conversionFactors[unitType]![fromUnit]!;
    final toFactor = conversionFactors[unitType]![toUnit]!;
    return value * fromFactor / toFactor;
  }

  // Conversión de temperatura
  static double _convertTemperature(double value, String fromUnit, String toUnit) {
    double toCelsius;
    switch (fromUnit) {
      case 'Celsius':
        toCelsius = value;
        break;
      case 'Fahrenheit':
        toCelsius = (value - 32) * 5 / 9;
        break;
      case 'Kelvin':
        toCelsius = value - 273.15;
        break;
      default:
        throw ArgumentError('Unidad no soportada');
    }

    switch (toUnit) {
      case 'Celsius':
        return toCelsius;
      case 'Fahrenheit':
        return toCelsius * 9 / 5 + 32;
      case 'Kelvin':
        return toCelsius + 273.15;
      default:
        throw ArgumentError('Unidad no soportada');
    }
  }
}