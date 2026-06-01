import 'package:delivery_app/core/config/pricing_config.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/fare_estimate.dart';

abstract final class FareEstimateMapper {
  static FareEstimate fromBackendResponse(
    String tierKey,
    Map<String, dynamic> data,
  ) {
    final pricing = PricingConfig.forTierKey(tierKey);
    final fare = (data['fare'] as num).toDouble();
    final distanceKm = (data['distanceKm'] as num?)?.toDouble() ?? 0;
    final distanceCharge =
        (fare - pricing.baseFare).clamp(0, double.infinity).toDouble();

    return FareEstimate(
      tierKey: tierKey,
      distanceKm: distanceKm,
      baseFare: pricing.baseFare,
      distanceCharge: distanceCharge,
      fare: fare,
      minimumFare: pricing.minimumFare,
    );
  }
}
