import 'package:dartz/dartz.dart';

import 'package:delivery_app/core/usecase/usecase.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/chat_repository.dart';

class GetChatMessagesParams {
  const GetChatMessagesParams({
    required this.tripId,
    required this.welcomeText,
  });

  final String tripId;
  final String welcomeText;
}

class GetChatMessagesUseCase
    extends UseCase<List<ChatMessageEntity>, GetChatMessagesParams> {
  GetChatMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(
    GetChatMessagesParams params,
  ) async {
    try {
      final messages = await _repository.getMessages(params.tripId);
      if (messages.isEmpty) {
        return Right(
          await _repository.seedWelcome(
            tripId: params.tripId,
            welcomeText: params.welcomeText,
          ),
        );
      }
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class SendChatMessageParams {
  const SendChatMessageParams({
    required this.tripId,
    required this.text,
    required this.welcomeText,
    required this.autoReplyText,
  });

  final String tripId;
  final String text;
  final String welcomeText;
  final String autoReplyText;
}

class SendChatMessageUseCase
    extends UseCase<List<ChatMessageEntity>, SendChatMessageParams> {
  SendChatMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> call(
    SendChatMessageParams params,
  ) async {
    try {
      final messages = await _repository.sendMessage(
        tripId: params.tripId,
        text: params.text,
        welcomeText: params.welcomeText,
        autoReplyText: params.autoReplyText,
      );
      return Right(messages);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
