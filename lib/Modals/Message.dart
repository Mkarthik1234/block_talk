class Message {
  final int id;
  final String senderName;
  final String text;
  final bool isSender;
  final String time;
  bool isSending;

  Message({
    required this.id,
    required this.senderName,
    required this.text,
    required this.isSender,
    required this.time,
    this.isSending = false
  });
}