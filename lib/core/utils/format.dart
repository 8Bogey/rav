/// Format a number as Iraqi Dinar (IQD) with thousand separators.
/// Example: 50000 → "50,000"
String formatIQD(num amount) {
  final formatted = amount.toStringAsFixed(0);
  final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return formatted.replaceAllMapped(regex, (match) => '${match[1]},');
}

/// Format a date as Arabic short date.
/// Example: DateTime(2026, 4, 4) → "٢٠٢٦/٠٤/٠٤"
String formatDateShort(DateTime date) {
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

/// Arabic month names (Iraqi/Kurdish)
const arabicMonths = [
  'كانون الثاني',
  'شباط',
  'آذار',
  'نيسان',
  'أيار',
  'حزيران',
  'تموز',
  'آب',
  'أيلول',
  'تشرين الأول',
  'تشرين الثاني',
  'كانون الأول',
];

/// Get Arabic month name from month number (1-12)
String getArabicMonth(int month) {
  if (month < 1 || month > 12) return '';
  return arabicMonths[month - 1];
}
