abstract final class RideTierMapper {
  /// Maps Flutter ride option keys to backend [rideTierKey] values.
  static String? toBackendTierKey(String flutterTierKey) {
    switch (flutterTierKey) {
      case 'ride_premium':
        return 'premium';
      case 'ride_economy':
      case 'ride_delivery':
        return null;
      default:
        return null;
    }
  }
}
