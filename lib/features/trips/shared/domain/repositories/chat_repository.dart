import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';

abstract class ChatRepository {
  Future<List<ChatMessageEntity>> getMessages(String tripId);

  Future<List<ChatMessageEntity>> seedWelcome({
    required String tripId,
    required String welcomeText,
  });

  Future<List<ChatMessageEntity>> sendMessage({
    required String tripId,
    required String text,
    required String welcomeText,
    required String autoReplyText,
  });
}
