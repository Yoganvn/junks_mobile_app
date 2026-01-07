class ChatItem {
  final String id;
  final String name;
  final String message;
  final String time;
  final String avatarUrl;
  final int unreadCount;

  ChatItem({
    required this.id,
    required this.name,
    required this.message,
    required this.time,
    required this.avatarUrl,
    this.unreadCount = 0,
  });

  factory ChatItem.fromJson(Map<String, dynamic> json) {
    return ChatItem(
      id: json['id'],
      name: json['name'],
      message: json['message'],
      time: json['time'],
      avatarUrl: json['avatarUrl'],
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}