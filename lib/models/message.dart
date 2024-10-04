class Message {
  final String text;
  final String senderId;
  final DateTime timestamp;

  Message({required this.text, required this.senderId, required this.timestamp});

  static fromDocument(message) {}
}