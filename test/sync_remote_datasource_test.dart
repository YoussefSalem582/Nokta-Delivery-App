import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/sync/sync_remote_datasource.dart';
import 'package:dio/dio.dart';

void main() {
  group('SyncRemoteDataSource', () {
    test('parses batch sync results envelope', () async {
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'messageKey': 'sync.processed',
                  'data': {
                    'results': [
                      {
                        'clientActionId': 'client-1',
                        'status': 'processed',
                        'response': {'id': 'trip-1', 'status': 'requested'},
                      },
                    ],
                  },
                },
              ),
            );
          },
        ),
      );

      final dataSource = SyncRemoteDataSource(dio);
      final results = await dataSource.syncActionsBatch([
        {
          'clientActionId': 'client-1',
          'actionType': 'ride.request',
          'payload': {'pickupAddress': 'A', 'dropoffAddress': 'B'},
        },
      ]);

      expect(results, hasLength(1));
      expect(results.first['clientActionId'], 'client-1');
      expect(results.first['status'], 'processed');
    });
  });
}
