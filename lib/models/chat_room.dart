import 'package:chat_app/models/message.dart';

class ChatRoom {
  final String roomId;
  final List<String> participants;
  final List<Message> messages;

  ChatRoom(
      {required this.roomId,
      required this.participants,
      this.messages = const []});
}
