import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_converter_service.dart';

class CurrencyManager extends ChangeNotifier {
  CurrencyManager._() {
    _load();
  }

  static final CurrencyManager instance = CurrencyManager._();

  static const _key = 'app_currency';

  static const supportedCurrencies = <String>[
    'AED',
    'USD',
    'EUR',
    'GBP',
    'SAR',
    'JOD',
    'ILS',
  ];

  final CurrencyConverterService _service =
      const CurrencyConverterService();

  String _currency = 'AED';
  final Map<String, double> _rateCache = {};
  final Map<String, Future<double>> _pending = {};

  String get currency => _currency;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key)?.toUpperCase();
      if (saved != null && supportedCurrencies.contains(saved)) {
        _currency = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setCurrency(String value) async {
    final next = value.trim().toUpperCase();
    if (!supportedCurrencies.contains(next)) return;

    if (_currency != next) {
      _currency = next;
      _rateCache.clear();
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, next);
    } catch (_) {}
  }

  Future<double> convert({
    required double amount,
    required String sourceCurrency,
  }) async {
    final source = sourceCurrency.trim().toUpperCase();

    if (amount <= 0 || source.isEmpty || source == _currency) {
      return amount;
    }

    final cacheKey = '$source|$_currency';

    if (_rateCache.containsKey(cacheKey)) {
      return amount * _rateCache[cacheKey]!;
    }

    final existing = _pending[cacheKey];
    final future = existing ??
        _service.convert(
          amount: 1,
          from: source,
          to: _currency,
        );

    _pending[cacheKey] = future;

    try {
      final convertedOne = await future;
      _rateCache[cacheKey] = convertedOne;
      return amount * convertedOne;
    } finally {
      _pending.remove(cacheKey);
    }
  }
}
