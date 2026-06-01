import 'package:dartz/dartz.dart';
import 'package:delivery_app/config/environment/env_config.dart';
import 'package:delivery_app/core/config/pricing_config.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/data/datasources/trip_remote_datasource.dart';
import 'package:delivery_app/features/trips/shared/data/mappers/fare_estimate_mapper.dart';
import 'package:delivery_app/features/trips/shared/data/mappers/ride_tier_mapper.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/fare_estimate.dart';
import 'package:equatable/equatable.dart';

class EstimateFareUseCase extends UseCase<FareEstimate, EstimateFareParams> {
  EstimateFareUseCase({TripRemoteDataSource? remote}) : _remote = remote;

  final TripRemoteDataSource? _remote;

  @override
  Future<Either<Failure, FareEstimate>> call(EstimateFareParams params) async {
    if (params.distanceKm < 0) {
      return const Left(
        ValidationFailure(
          message: 'Invalid distance',
          fieldErrors: {'distanceKm': ['must be non-negative']},
        ),
      );
    }

    if (EnvConfig.usesRealBackend &&
        _remote != null &&
        params.hasRouteCoordinates) {
      try {
        final body = <String, dynamic>{
          'pickupLat': params.pickupLat,
          'pickupLng': params.pickupLng,
          'dropoffLat': params.dropoffLat,
          'dropoffLng': params.dropoffLng,
        };
        final backendTier = RideTierMapper.toBackendTierKey(params.tierKey);
        if (backendTier != null) {
          body['rideTierKey'] = backendTier;
        }

        final data = await _remote!.estimateFare(body);
        return Right(FareEstimateMapper.fromBackendResponse(params.tierKey, data));
      } catch (_) {
        // Fall back to local pricing when the backend is unreachable.
      }
    }

    return Right(_estimateLocally(params));
  }

  FareEstimate _estimateLocally(EstimateFareParams params) {
    final pricing = PricingConfig.forTierKey(params.tierKey);
    final distanceCharge =
        (params.distanceKm * pricing.ratePerKm * 100).roundToDouble() / 100;
    final fare = pricing.calculateFare(params.distanceKm);

    return FareEstimate(
      tierKey: pricing.tierKey,
      distanceKm: params.distanceKm,
      baseFare: pricing.baseFare,
      distanceCharge: distanceCharge,
      fare: fare,
      minimumFare: pricing.minimumFare,
    );
  }
}

class EstimateFareParams extends Equatable {
  const EstimateFareParams({
    required this.tierKey,
    required this.distanceKm,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
  });

  final String tierKey;
  final double distanceKm;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;

  bool get hasRouteCoordinates =>
      pickupLat != null &&
      pickupLng != null &&
      dropoffLat != null &&
      dropoffLng != null;

  @override
  List<Object?> get props => [
        tierKey,
        distanceKm,
        pickupLat,
        pickupLng,
        dropoffLat,
        dropoffLng,
      ];
}
