import 'package:delivery_app/core/utils/constants.dart';

class CacheFreshness {
  CacheFreshness._();

  static bool isFresh(DateTime? lastFetchedAt, {String? cacheKey}) {
    if (lastFetchedAt == null) return false;
    
    Duration ttl;
    switch (cacheKey) {
      case 'trips':
        ttl = AppConstants.cacheTtlTrips;
      case 'orders':
        ttl = AppConstants.cacheTtlOrders;
      case 'profile':
        ttl = AppConstants.cacheTtlProfile;
      default:
        ttl = AppConstants.cacheTtlDefault;
    }
    
    return DateTime.now().difference(lastFetchedAt) < ttl;
  }
}
