import 'package:flutter/material.dart';

import '../state/currency_manager.dart';

class CurrencyPrice extends StatefulWidget {
  const CurrencyPrice({
    super.key,
    required this.amount,
    required this.sourceCurrency,
    this.suffix = '',
    this.style,
    this.maxLines = 1,
  });

  final double amount;
  final String sourceCurrency;
  final String suffix;
  final TextStyle? style;
  final int maxLines;

  @override
  State<CurrencyPrice> createState() => _CurrencyPriceState();
}

class _CurrencyPriceState extends State<CurrencyPrice> {
  double? _converted;
  String _lastTarget = '';

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  void didUpdateWidget(covariant CurrencyPrice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount ||
        oldWidget.sourceCurrency != widget.sourceCurrency ||
        oldWidget.sourceCurrency !=
            CurrencyManager.instance.currency) {
      _convert();
    }
  }

  Future<void> _convert() async {
    final manager = CurrencyManager.instance;
    final source = widget.sourceCurrency.trim().toUpperCase();
    _lastTarget = manager.currency;

    if (source.isEmpty || source == manager.currency) {
      if (mounted) setState(() => _converted = widget.amount);
      return;
    }

    try {
      final value = await manager.convert(
        amount: widget.amount,
        sourceCurrency: source,
      );
      if (mounted) setState(() => _converted = value);
    } catch (_) {
      if (mounted) setState(() => _converted = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurrencyManager.instance,
      builder: (context, _) {
        final manager = CurrencyManager.instance;
        final source = widget.sourceCurrency.trim().toUpperCase();
        final targetChanged = _lastTarget != manager.currency;
        if (targetChanged) {
          _converted = null;
          _lastTarget = manager.currency;
        }

        final sameCurrency = source.isEmpty || source == manager.currency;
        final value = sameCurrency ? widget.amount : _converted;

        if (!sameCurrency && value == null) {
          _convert();
        }

        final displayCurrency =
            sameCurrency ? source : manager.currency;

        final text = value == null
            ? '${_format(widget.amount)} $source'
            : '${displayCurrency.isEmpty ? '' : '$displayCurrency '}${_format(value)}${widget.suffix}';

        return Text(
          text.trim(),
          maxLines: widget.maxLines,
          overflow: TextOverflow.ellipsis,
          style: widget.style,
        );
      },
    );
  }

  String _format(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }
}
