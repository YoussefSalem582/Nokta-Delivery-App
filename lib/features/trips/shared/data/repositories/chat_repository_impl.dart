import 'package:delivery_app/features/trips/shared/data/datasources/chat_local_datasource.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';
import 'package:delivery_app/features/trips/shared/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({required ChatLocalDataSource local}) : _local = local;

  final ChatLocalDataSource _local;

  @override
  Future<List<ChatMessageEntity>> getMessages(String tripId) async {
    return _local.getMessages(tripId);
  }

  @override
  Future<List<ChatMessageEntity>> seedWelcome({
    required String tripId,
    required String welcomeText,
  }) async {
    final messages = _local.getMessages(tripId);
    if (messages.isNotEmpty) return messages;

    final seeded = [
      ChatMessageEntity(
        id: '${tripId}_welcome',
        tripId: tripId,
        text: welcomeText,
        isFromDriver: true,
        sentAt: DateTime.now(),
      ),
    ];
    await _local.saveMessages(tripId, seeded);
    return seeded;
  }

  @override
  Future<List<ChatMessageEntity>> sendMessage({
    required String tripId,
    required String text,
    required String welcomeText,
    required String autoReplyText,
  }) async {
    final now = DateTime.now();
    final messages = List<ChatMessageEntity>.from(_local.getMessages(tripId));

    if (messages.isEmpty) {
      messages.add(
        ChatMessageEntity(
          id: '${tripId}_welcome',
          tripId: tripId,
          text: welcomeText,
          isFromDriver: true,
          sentAt: now.subtract(const Duration(seconds: 1)),
        ),
      );
    }

    messages.add(
      ChatMessageEntity(
        id: '${now.microsecondsSinceEpoch}_user',
        tripId: tripId,
        text: text,
        isFromDriver: false,
        sentAt: now,
      ),
    );

    await _local.saveMessages(tripId, messages);

    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final replyAt = DateTime.now();
    messages.add(
      ChatMessageEntity(
        id: '${replyAt.microsecondsSinceEpoch}_driver',
        tripId: tripId,
        text: autoReplyText,
        isFromDriver: true,
        sentAt: replyAt,
      ),
    );

    await _local.saveMessages(tripId, messages);
    return messages;
  }
}
