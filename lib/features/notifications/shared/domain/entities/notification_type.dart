enum NotificationType {
  tripUpdate,
  driverOnTheWay,
  driverArrived,
  tripAccepted,
  tripCompleted,
  promo,
  general,
  message,
  call;

  String toJsonKey() {
    return switch (this) {
      NotificationType.tripUpdate => 'tripUpdate',
      NotificationType.driverOnTheWay => 'driverOnTheWay',
      NotificationType.driverArrived => 'driverArrived',
      NotificationType.tripAccepted => 'tripAccepted',
      NotificationType.tripCompleted => 'tripCompleted',
      NotificationType.promo => 'promo',
      NotificationType.general => 'general',
      NotificationType.message => 'message',
      NotificationType.call => 'call',
    };
  }

  static NotificationType fromJsonKey(String? value) {
    return switch (value) {
      'tripUpdate' => NotificationType.tripUpdate,
      'driverOnTheWay' => NotificationType.driverOnTheWay,
      'driverArrived' => NotificationType.driverArrived,
      'tripAccepted' => NotificationType.tripAccepted,
      'tripCompleted' => NotificationType.tripCompleted,
      'promo' => NotificationType.promo,
      'message' => NotificationType.message,
      'call' => NotificationType.call,
      _ => NotificationType.general,
    };
  }

  /// Infers type from legacy i18n title keys when Hive rows lack [type].
  static NotificationType inferFromTitleKey(String title) {
    if (title.contains('new_message') || title.contains('chat_message')) {
      return NotificationType.message;
    }
    if (title.contains('missed_call') || title.contains('call_ended')) {
      return NotificationType.call;
    }
    if (title.contains('driver_on_the_way') || title.contains('heading_pickup')) {
      return NotificationType.driverOnTheWay;
    }
    if (title.contains('driver_arrived')) {
      return NotificationType.driverArrived;
    }
    if (title.contains('trip_accepted')) {
      return NotificationType.tripAccepted;
    }
    if (title.contains('trip_completed') || title.contains('thanks_riding')) {
      return NotificationType.tripCompleted;
    }
    if (title.contains('trip_update')) {
      return NotificationType.tripUpdate;
    }
    if (title.contains('promo')) {
      return NotificationType.promo;
    }
    return NotificationType.general;
  }
}

enum NotificationCategoryFilter { all, trips, messages, calls }

extension NotificationTypeCategory on NotificationType {
  NotificationCategoryFilter get categoryFilter {
    return switch (this) {
      NotificationType.message => NotificationCategoryFilter.messages,
      NotificationType.call => NotificationCategoryFilter.calls,
      NotificationType.promo || NotificationType.general =>
        NotificationCategoryFilter.all,
      _ => NotificationCategoryFilter.trips,
    };
  }

  bool matchesCategory(NotificationCategoryFilter filter) {
    if (filter == NotificationCategoryFilter.all) return true;
    return categoryFilter == filter;
  }
}
