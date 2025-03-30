
import 'package:airline/ChatPage.dart';
import 'package:airline/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/ChatRoom.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {

  List<ChatRoom> chatRooms = [];

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      List<ChatRoom> fetchedRooms = await ChatService().getChatRooms();
      setState(() {
        chatRooms = fetchedRooms;
      });
    } catch (e) {
      print("채팅방 목록 불러오기 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("상담 요청 목록")),
      body: FutureBuilder<List<ChatRoom>>(
          future: ChatService().getChatRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("오류 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("상담 요청이 없습니다."));
            }
            final chatRooms = snapshot.data!;
            return ListView.builder(
              itemCount: chatRooms.length,
              itemBuilder: (context, index) {
                final room = chatRooms[index];
                final formattedTime = DateFormat('MM-dd HH:mm').format(DateTime.parse(room.lastTimestamp));
                return ListTile(
                  title: Text(room.userName),
                  subtitle: Text("마지막 메시지: ${room.lastMessage}"),
                  trailing: Text(formattedTime),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(chatRoom: room)),
                    );
                  },
                );
              },
            );
          },
        ),
    );
  }
}
