import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/error/exceptions.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    try {
      final orders = await _repository.getOrders();
      return Right(orders);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class RefreshOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  RefreshOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    try {
      final orders = await _repository.getOrders(forceRefresh: true);
      return Right(orders);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class CreateDeliveryUseCase extends UseCase<OrderEntity, CreateDeliveryParams> {
  CreateDeliveryUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, OrderEntity>> call(CreateDeliveryParams params) async {
    try {
      final order = await _repository.createDelivery(
        pickupAddress: params.pickupAddress,
        dropoffAddress: params.dropoffAddress,
        pickupLat: params.pickupLat,
        pickupLng: params.pickupLng,
        dropoffLat: params.dropoffLat,
        dropoffLng: params.dropoffLng,
        fee: params.fee,
        packageNotes: params.packageNotes,
      );
      return Right(order);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}

class CreateDeliveryParams {
  const CreateDeliveryParams({
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropoffLat,
    required this.dropoffLng,
    required this.fee,
    this.packageNotes,
  });

  final String pickupAddress;
  final String dropoffAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropoffLat;
  final double dropoffLng;
  final double fee;
  final String? packageNotes;
}

class GetCachedOrdersUseCase extends UseCase<List<OrderEntity>, NoParams> {
  GetCachedOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return Right(_repository.getCachedOrders());
  }
}
