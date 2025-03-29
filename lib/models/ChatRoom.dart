class ChatRoom {
  final String userName;
  final String lastMessage;
  final String lastTimestamp;

  ChatRoom({
    required this.userName,
    required this.lastMessage,
    required this.lastTimestamp,
});

  factory ChatRoom.fromJson(Map<String, dynamic> json){
    return ChatRoom(
        userName: json['userName'] ?? 'Unknown',
        lastMessage: json['lastMessage'] ?? 'No message',
        lastTimestamp: json['lastTimestamp'] ?? 'Unknown',
    );
  }
}