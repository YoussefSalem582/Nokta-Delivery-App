part of 'driver_chat_bloc.dart';

abstract class DriverChatState extends Equatable {
  const DriverChatState();

  @override
  List<Object?> get props => [];
}

class DriverChatInitial extends DriverChatState {
  const DriverChatInitial();
}

class DriverChatLoading extends DriverChatState {
  const DriverChatLoading();
}

class DriverChatLoaded extends DriverChatState {
  const DriverChatLoaded({
    required this.trip,
    required this.messages,
    this.isSending = false,
  });

  final TripEntity trip;
  final List<ChatMessageEntity> messages;
  final bool isSending;

  DriverChatLoaded copyWith({
    TripEntity? trip,
    List<ChatMessageEntity>? messages,
    bool? isSending,
  }) {
    return DriverChatLoaded(
      trip: trip ?? this.trip,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [trip, messages, isSending];
}

class DriverChatError extends DriverChatState {
  const DriverChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
