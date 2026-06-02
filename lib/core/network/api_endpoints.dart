import 'package:delivery_app/config/environment/env_config.dart';

class ApiEndpoints {
  static String get baseUrl =>
      EnvConfig.useMockApi ? 'https://mock.nokta.app/api' : EnvConfig.apiBaseUrl;

  static const trips = '/trips';
  static const tripsActive = '/trips/active';
  static const orders = '/orders';
  static const deliveries = '/deliveries';
  static const profile = '/profile';
  static const drivers = '/drivers';
  static const riders = '/riders';
  static const requestTrip = '/trips/request';
  static const estimateFare = '/rides/estimate-fare';

  static const syncActions = '/sync/actions';
  static const syncReconcile = '/sync/reconcile';

  static const authRegister = '/v1/auth/register';
  static const authLogin = '/v1/auth/login';
  static const authRefresh = '/v1/auth/refresh';
  static const authLogout = '/v1/auth/logout';
  static const authForgotPassword = '/v1/auth/forgot-password';
  static const authDeviceToken = '/v1/auth/device-token';

  static String get driverRegister => _driverPath('/register');
  static String get driverProfile => _driverPath('/profile');
  static String get driverAvailability => _driverPath('/availability');
  static String get driverOffers => _driverPath('/offers');

  static String deliveryById(String id) => '/deliveries/$id';
  static String deliveryTracking(String id) => '/deliveries/$id/tracking';
  static String deliveryStatus(String id) => '/deliveries/$id/status';
  static String deliveryLocation(String id) => '/deliveries/$id/location';

  static String tripById(String id) => '/trips/$id';
  static String tripStatus(String id) => '/trips/$id/status';
  static String driverReviews(String driverId) => '/drivers/$driverId/reviews';
  static String driverOfferAccept(String tripId) =>
      '${_driverPath('/offers')}/$tripId/accept';
  static String driverOfferDecline(String tripId) =>
      '${_driverPath('/offers')}/$tripId/decline';
  static String driverTripStatus(String tripId) =>
      '/trips/$tripId/status';
  static String driverTripLocation(String tripId) =>
      '/trips/$tripId/location';

  static String _driverPath(String suffix) {
    if (EnvConfig.useMockApi || EnvConfig.useMockDriverApi) {
      return '/driver$suffix';
    }
    return '/v1/driver$suffix';
  }
}
