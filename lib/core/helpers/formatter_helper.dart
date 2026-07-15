class Formatter {
  Formatter._();

  /// Formats distance in km or miles.
  static String formatDistance(double km, {bool useMiles = false}) {
    if (useMiles) {
      final double miles = km * 0.621371;
      return miles < 1
          ? 'Less than a mile away'
          : '${miles.toStringAsFixed(1)} miles away';
    } else {
      return km < 1
          ? 'Less than a km away'
          : '${km.toStringAsFixed(1)} km away';
    }
  }

  /// Truncates string to a max length with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Formats a phone number into readable spacing (e.g. +1 234 567 8901)
  static String formatPhoneNumber(String rawPhone) {
    // Basic phone formatting based on typical lengths
    final digits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11) {
      return '+${digits.substring(0, 1)} (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }
    return rawPhone;
  }
}
