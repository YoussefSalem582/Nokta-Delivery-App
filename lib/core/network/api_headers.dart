import 'package:dio/dio.dart';

abstract final class ApiHeaders {
  static const idempotencyKey = 'Idempotency-Key';
}

Options idempotencyOptions(String key) {
  return Options(headers: {ApiHeaders.idempotencyKey: key});
}
