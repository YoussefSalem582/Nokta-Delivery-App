part of 'notification_bloc.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

class NotificationRefreshRequested extends NotificationEvent {
  const NotificationRefreshRequested();
}

class NotificationMarkReadRequested extends NotificationEvent {
  const NotificationMarkReadRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

class NotificationDeleteRequested extends NotificationEvent {
  const NotificationDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class NotificationRestoreRequested extends NotificationEvent {
  const NotificationRestoreRequested(this.notification);
  final NotificationEntity notification;
  @override
  List<Object?> get props => [notification];
}

class NotificationCategoryChanged extends NotificationEvent {
  const NotificationCategoryChanged(this.category);
  final NotificationCategoryFilter category;
  @override
  List<Object?> get props => [category];
}

class NotificationUnreadOnlyToggled extends NotificationEvent {
  const NotificationUnreadOnlyToggled(this.unreadOnly);
  final bool unreadOnly;
  @override
  List<Object?> get props => [unreadOnly];
}

class NotificationReceived extends NotificationEvent {
  const NotificationReceived();
}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    required this.notifications,
    required this.tripsById,
    required this.unreadCount,
    this.categoryFilter = NotificationCategoryFilter.all,
    this.unreadOnly = false,
    this.isRefreshing = false,
  });

  final List<NotificationEntity> notifications;
  final Map<String, TripEntity> tripsById;
  final int unreadCount;
  final NotificationCategoryFilter categoryFilter;
  final bool unreadOnly;
  final bool isRefreshing;

  List<NotificationEntity> get filteredNotifications {
    var items = notifications.where(
      (n) => n.type.matchesCategory(categoryFilter),
    );
    if (unreadOnly) {
      items = items.where((n) => !n.isRead);
    }
    return items.toList();
  }

  TripEntity? tripFor(NotificationEntity notification) {
    final tripId = notification.tripId;
    if (tripId == null) return null;
    return tripsById[tripId];
  }

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    Map<String, TripEntity>? tripsById,
    int? unreadCount,
    NotificationCategoryFilter? categoryFilter,
    bool? unreadOnly,
    bool? isRefreshing,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      tripsById: tripsById ?? this.tripsById,
      unreadCount: unreadCount ?? this.unreadCount,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        tripsById,
        unreadCount,
        categoryFilter,
        unreadOnly,
        isRefreshing,
      ];
}

class NotificationError extends NotificationState {
  const NotificationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
