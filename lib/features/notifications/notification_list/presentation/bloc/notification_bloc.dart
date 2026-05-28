import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_type.dart';
import 'package:delivery_app/features/notifications/shared/domain/usecases/notification_usecases.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';

part 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required GetTripsUseCase getTrips,
    required MarkNotificationReadUseCase markNotificationRead,
    required MarkAllNotificationsReadUseCase markAllRead,
    required DeleteNotificationUseCase deleteNotification,
    required AddNotificationUseCase addNotification,
    required GetUnreadNotificationCountUseCase getUnreadCount,
  })  : _getNotifications = getNotifications,
        _getTrips = getTrips,
        _markNotificationRead = markNotificationRead,
        _markAllRead = markAllRead,
        _deleteNotification = deleteNotification,
        _addNotification = addNotification,
        _getUnreadCount = getUnreadCount,
        super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationRefreshRequested>(_onRefresh);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllRead);
    on<NotificationDeleteRequested>(_onDelete);
    on<NotificationRestoreRequested>(_onRestore);
    on<NotificationCategoryChanged>(_onCategoryChanged);
    on<NotificationUnreadOnlyToggled>(_onUnreadOnlyToggled);
    on<NotificationReceived>(_onReceived);
  }

  final GetNotificationsUseCase _getNotifications;
  final GetTripsUseCase _getTrips;
  final MarkNotificationReadUseCase _markNotificationRead;
  final MarkAllNotificationsReadUseCase _markAllRead;
  final DeleteNotificationUseCase _deleteNotification;
  final AddNotificationUseCase _addNotification;
  final GetUnreadNotificationCountUseCase _getUnreadCount;

  NotificationCategoryFilter _categoryFilter = NotificationCategoryFilter.all;
  bool _unreadOnly = false;

  Future<void> _emitLoaded(Emitter<NotificationState> emit) async {
    final notifResult = await _getNotifications(const NoParams());
    final tripsResult = await _getTrips(const NoParams());
    final countResult = await _getUnreadCount(const NoParams());

    notifResult.fold(
      (Failure failure) => emit(NotificationError(failure.message)),
      (items) {
        final tripsById = <String, TripEntity>{};
        tripsResult.fold((_) {}, (trips) {
          for (final trip in trips) {
            tripsById[trip.id] = trip;
          }
        });
        final unreadCount = countResult.getOrElse(() => 0);
        emit(
          NotificationLoaded(
            notifications: items,
            tripsById: tripsById,
            unreadCount: unreadCount,
            categoryFilter: _categoryFilter,
            unreadOnly: _unreadOnly,
          ),
        );
      },
    );
  }

  Future<void> _onLoad(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await _emitLoaded(emit);
  }

  Future<void> _onRefresh(
    NotificationRefreshRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    await _emitLoaded(emit);
  }

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _markNotificationRead(MarkNotificationReadParams(event.id));
    await _emitLoaded(emit);
  }

  Future<void> _onMarkAllRead(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _markAllRead(const NoParams());
    await _emitLoaded(emit);
  }

  Future<void> _onDelete(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _deleteNotification(DeleteNotificationParams(event.id));
    await _emitLoaded(emit);
  }

  Future<void> _onRestore(
    NotificationRestoreRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _addNotification(event.notification);
    await _emitLoaded(emit);
  }

  void _onCategoryChanged(
    NotificationCategoryChanged event,
    Emitter<NotificationState> emit,
  ) {
    _categoryFilter = event.category;
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(categoryFilter: event.category));
    }
  }

  void _onUnreadOnlyToggled(
    NotificationUnreadOnlyToggled event,
    Emitter<NotificationState> emit,
  ) {
    _unreadOnly = event.unreadOnly;
    final current = state;
    if (current is NotificationLoaded) {
      emit(current.copyWith(unreadOnly: event.unreadOnly));
    }
  }

  Future<void> _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    await _emitLoaded(emit);
  }
}
