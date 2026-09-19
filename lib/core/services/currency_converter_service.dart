import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyConversionException
    implements Exception {
  const CurrencyConversionException(
      this.message,
      );

  final String message;

  @override
  String toString() => message;
}

class CurrencyConverterService {
  const CurrencyConverterService();

  Future<double> convertToAed({
    required double amount,
    required String currency,
  }) async {
    if (amount <= 0) {
      throw const CurrencyConversionException(
        'Amount must be greater than zero.',
      );
    }

    final normalizedCurrency =
    currency.toUpperCase();

    if (normalizedCurrency == 'AED') {
      return amount;
    }

    final uri = Uri.parse(
      'https://api.frankfurter.dev/v2/rate/'
          '${normalizedCurrency.toLowerCase()}/aed',
    );

    try {
      final response = await http
          .get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      )
          .timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        throw CurrencyConversionException(
          'Unable to retrieve the exchange rate.',
        );
      }

      final decoded =
      jsonDecode(response.body);

      if (decoded
      is! Map<String, dynamic>) {
        throw const CurrencyConversionException(
          'Invalid exchange rate response.',
        );
      }

      final rateValue =
      decoded['rate'];

      final rate = double.tryParse(
        rateValue?.toString() ?? '',
      );

      if (rate == null || rate <= 0) {
        throw const CurrencyConversionException(
          'Invalid exchange rate.',
        );
      }

      return amount * rate;
    } on CurrencyConversionException {
      rethrow;
    } on TimeoutException {
      throw const CurrencyConversionException(
        'Currency conversion timed out.',
      );
    } on http.ClientException catch (
    error) {
      throw CurrencyConversionException(
        error.message,
      );
    } catch (_) {
      throw const CurrencyConversionException(
        'Unable to convert the amount to AED.',
      );
    }
  }
}