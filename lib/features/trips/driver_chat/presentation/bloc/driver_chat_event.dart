part of 'driver_chat_bloc.dart';

abstract class DriverChatEvent extends Equatable {
  const DriverChatEvent();

  @override
  List<Object?> get props => [];
}

class DriverChatLoadRequested extends DriverChatEvent {
  const DriverChatLoadRequested(this.tripId);

  final String tripId;

  @override
  List<Object?> get props => [tripId];
}

class DriverChatMessageSent extends DriverChatEvent {
  const DriverChatMessageSent(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}
