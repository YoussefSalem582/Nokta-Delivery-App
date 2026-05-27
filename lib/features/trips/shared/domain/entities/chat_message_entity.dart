import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  const ChatMessageEntity({
    required this.id,
    required this.tripId,
    required this.text,
    required this.isFromDriver,
    required this.sentAt,
  });

  final String id;
  final String tripId;
  final String text;
  final bool isFromDriver;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'text': text,
        'isFromDriver': isFromDriver,
        'sentAt': sentAt.toIso8601String(),
      };

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      text: json['text'] as String,
      isFromDriver: json['isFromDriver'] as bool,
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, tripId, text, isFromDriver, sentAt];
}
