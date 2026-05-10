import 'constants.dart';

class QrParser {
  QrParser._();

  // parses a qr code value and returns the tableId, or null if invalid.
  // Format: ipot://table/{tableId}
  static String? parseTableId(String rawValue) {
    try {
      final uri = Uri.parse(rawValue);
      if (uri.scheme != AppConstants.qrScheme) return null;
      if (uri.host != AppConstants.qrTablePath) return null;
      final segments = uri.pathSegments;
      if (segments.isEmpty) return null;
      return segments.first;
    } catch (_) {
      return null;
    }
  }
}
