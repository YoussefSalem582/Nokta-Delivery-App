import 'dart:convert';

import 'package:delivery_app/core/utils/constants.dart';
import 'package:delivery_app/features/trips/shared/domain/entities/chat_message_entity.dart';
import 'package:hive/hive.dart';

class ChatLocalDataSource {
  ChatLocalDataSource(this._box);

  final Box<String> _box;

  List<ChatMessageEntity> getMessages(String tripId) {
    final raw = _box.get(tripId);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => ChatMessageEntity.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
  }

  Future<void> saveMessages(String tripId, List<ChatMessageEntity> messages) async {
    final encoded = jsonEncode(messages.map((m) => m.toJson()).toList());
    await _box.put(tripId, encoded);
  }
}

Future<Box<String>> openChatMessagesBox() async {
  return Hive.openBox<String>(AppConstants.chatMessagesBox);
}
