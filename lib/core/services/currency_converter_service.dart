import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyConversionException implements Exception {
  const CurrencyConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Live exchange-rate service. The API returns a full rate table, which lets
/// us support AED, USD, EUR, GBP, SAR, JOD and ILS instead of relying on a
/// provider that only exposes a small subset of currencies.
class CurrencyConverterService {
  const CurrencyConverterService();

  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (amount <= 0) return 0;

    final source = from.trim().toUpperCase();
    final target = to.trim().toUpperCase();

    if (source.isEmpty || target.isEmpty || source == target) {
      return amount;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://open.er-api.com/v6/latest/$source',
        ),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw const CurrencyConversionException(
          'Unable to retrieve the exchange rate.',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const CurrencyConversionException(
          'Invalid exchange rate response.',
        );
      }

      final rates = decoded['rates'];
      if (rates is! Map) {
        throw const CurrencyConversionException(
          'Exchange rates are unavailable.',
        );
      }

      final rate = double.tryParse(
        rates[target]?.toString() ?? '',
      );

      if (rate == null || rate <= 0) {
        throw CurrencyConversionException(
          'Exchange rate for $target is unavailable.',
        );
      }

      return amount * rate;
    } on CurrencyConversionException {
      rethrow;
    } on TimeoutException {
      throw const CurrencyConversionException(
        'Currency conversion timed out.',
      );
    } on http.ClientException catch (error) {
      throw CurrencyConversionException(error.message);
    } catch (_) {
      throw const CurrencyConversionException(
        'Unable to convert the amount.',
      );
    }
  }

  Future<double> convertToAed({
    required double amount,
    required String currency,
  }) {
    return convert(
      amount: amount,
      from: currency,
      to: 'AED',
    );
  }
}
