import 'package:delivery_app/core/error/failures.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/trip_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/chat_usecases.dart';
import 'package:delivery_app/features/trips/shared/domain/usecases/trip_usecases.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'driver_chat_event.dart';
part 'driver_chat_state.dart';

class DriverChatBloc extends Bloc<DriverChatEvent, DriverChatState> {
  DriverChatBloc({
    required GetTripDetailUseCase getTripDetail,
    required GetChatMessagesUseCase getChatMessages,
    required SendChatMessageUseCase sendChatMessage,
  })  : _getTripDetail = getTripDetail,
        _getChatMessages = getChatMessages,
        _sendChatMessage = sendChatMessage,
        super(const DriverChatInitial()) {
    on<DriverChatLoadRequested>(_onLoad);
    on<DriverChatMessageSent>(_onSend);
  }

  final GetTripDetailUseCase _getTripDetail;
  final GetChatMessagesUseCase _getChatMessages;
  final SendChatMessageUseCase _sendChatMessage;

  Future<void> _onLoad(
    DriverChatLoadRequested event,
    Emitter<DriverChatState> emit,
  ) async {
    emit(const DriverChatLoading());

    final tripResult = await _getTripDetail(GetTripDetailParams(event.tripId));
    await tripResult.fold(
      (Failure failure) async => emit(DriverChatError(failure.message)),
      (TripEntity trip) async {
        final messagesResult = await _getChatMessages(
          GetChatMessagesParams(
            tripId: event.tripId,
            welcomeText: 'chat_driver_welcome'.tr(),
          ),
        );
        messagesResult.fold(
          (Failure failure) => emit(DriverChatError(failure.message)),
          (List<ChatMessageEntity> messages) => emit(
            DriverChatLoaded(
              trip: trip,
              messages: messages,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSend(
    DriverChatMessageSent event,
    Emitter<DriverChatState> emit,
  ) async {
    final current = state;
    if (current is! DriverChatLoaded) return;

    final trimmed = event.text.trim();
    if (trimmed.isEmpty) return;

    emit(current.copyWith(isSending: true));

    final result = await _sendChatMessage(
      SendChatMessageParams(
        tripId: current.trip.id,
        text: trimmed,
        welcomeText: 'chat_driver_welcome'.tr(),
        autoReplyText: 'chat_driver_reply'.tr(),
      ),
    );

    result.fold(
      (Failure failure) => emit(DriverChatError(failure.message)),
      (List<ChatMessageEntity> messages) => emit(
        DriverChatLoaded(
          trip: current.trip,
          messages: messages,
          isSending: false,
        ),
      ),
    );
  }
}
