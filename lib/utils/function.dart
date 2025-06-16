import 'package:intl/intl.dart';

/// Currency format for Rupiah ( IDR )
NumberFormat currencyFormatter = NumberFormat.currency(
  locale: 'id',
  decimalDigits: 0,
  name: 'Rp ',
  symbol: 'Rp ',
);

/// Currency format for Rupiah ( IDR )
NumberFormat currencyFormatterNoLeading =
NumberFormat.currency(locale: 'id', decimalDigits: 0, name: '', symbol: '');

extension StringExtension on String {
  String get currencyWithoutRp =>
      currencyFormatter.format(double.tryParse(this)).replaceAll('Rp ', '');
}
