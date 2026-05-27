import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/notifications/shared/domain/entities/notification_entity.dart';
import 'package:delivery_app/features/notifications/shared/domain/usecases/notification_usecases.dart';

part 'notification_event.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markNotificationRead,
    required GetUnreadNotificationCountUseCase getUnreadCount,
  })  : _getNotifications = getNotifications,
        _markNotificationRead = markNotificationRead,
        _getUnreadCount = getUnreadCount,
        super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoad);
    on<NotificationMarkReadRequested>(_onMarkRead);
    on<NotificationReceived>(_onReceived);
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markNotificationRead;
  final GetUnreadNotificationCountUseCase _getUnreadCount;

  Future<void> _emitLoaded(Emitter<NotificationState> emit) async {
    final result = await _getNotifications(const NoParams());
    final countResult = await _getUnreadCount(const NoParams());
    result.fold(
      (Failure failure) => emit(NotificationError(failure.message)),
      (items) {
        final unreadCount = countResult.getOrElse(() => 0);
        emit(NotificationLoaded(items, unreadCount));
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

  Future<void> _onMarkRead(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    await _markNotificationRead(MarkNotificationReadParams(event.id));
    await _emitLoaded(emit);
  }

  Future<void> _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) async {
    await _emitLoaded(emit);
  }
}
