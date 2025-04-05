class ChatRoom {
  final String roomId;
  final String userName;
  final String lastMessage;
  final String lastTimestamp;

  ChatRoom({
    required this.roomId,
    required this.userName,
    required this.lastMessage,
    required this.lastTimestamp,
});

  factory ChatRoom.fromJson(Map<String, dynamic> json){
    return ChatRoom(
        roomId: json['roomId'] ?? 'Unknown',
        userName: json['sender'] ?? 'Unknown',
        lastMessage: json['lastMessage'] ?? 'No message',
        lastTimestamp: json['lastMessageTime'] ?? 'Unknown',
    );
  }
}