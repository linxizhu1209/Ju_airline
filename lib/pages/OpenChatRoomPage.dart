import 'package:airline/providers/auth_provider.dart';
import 'package:airline/services/open_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/secure_storage.dart';

class OpenChatRoomPage extends StatefulWidget {
  final String roomId;
  final String myNickname;

  OpenChatRoomPage({required this.roomId, required this.myNickname, super.key});

  @override
  State<OpenChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<OpenChatRoomPage> {

  final List<Map<String, dynamic>> messages = [];
  late OpenChatService _chatService;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chatService = OpenChatService();
    _initializeRoom();


    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _addMessage({
    //     "sender": widget.myNickname,
    //     "content": "${widget.myNickname}님이 입장했습니다.",
    //     "sendAt": DateTime.now().toIso8601String(),
    //     "type": "ENTER",
    //   });
    // });
  }

  Future<void> _initializeRoom() async {
    final participant = await _chatService.fetchParticipant(
        roomId: widget.roomId,
        username: widget.myNickname,
    );

    final isFirstJoin = participant == null;

    await _chatService.connect(
      roomId: widget.roomId,
      nickname: widget.myNickname,
      onMessageReceived: (msg) {
        _addMessage(msg);
      },
    );

    if(!isFirstJoin){
      final messagesSince = await _chatService.fetchMessagesSince(
        roomId: widget.roomId,
        since: participant['joinedAt'],
      );
      for(final msg in messagesSince){
        _addMessage(msg);
      }
    }

    if(isFirstJoin){
      _chatService.sendMessage(
          roomId: widget.roomId,
          nickname: widget.myNickname,
          content: "${widget.myNickname}님이 입장했습니다.",
          type: "ENTER",
      );
    }
  }
  void _addMessage(Map<String, dynamic> message) {
    setState(() {
      messages.add(message);
    });

    Future.delayed(Duration(milliseconds: 100), (){
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if(text.isEmpty) return;

    final message = {
      "sender": widget.myNickname,
      "content": text,
      "sendAt": DateTime.now().toIso8601String(),
      "type": "TALK",
    };
    _chatService.sendMessage(
      roomId: widget.roomId,
      nickname: widget.myNickname,
      content: text,
      type: "TALK",
    );
    _addMessage(message);
    _controller.clear();
  }

  Widget _buildMessage(Map<String, dynamic> msg){
    final isMine = msg['sender'] == widget.myNickname;
    final type = msg['type'];
    final time = DateFormat('HH:mm').format(DateTime.parse(msg['sendAt']));

    if(type == 'ENTER'){
      return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              msg['content'],
              style: TextStyle(color: Colors.purple, fontWeight: FontWeight.w500),
            ),
        ),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        alignment: isMine? Alignment.centerRight : Alignment.centerLeft,
        widthFactor: 0.66,
        child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? Color(0xFFE1BEE7) : Color(0xFFF3E5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(!isMine)
              Text(
                msg['sender'],
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            SizedBox(height: 4),
            Text(msg['content'], style: TextStyle(fontSize: 15)),
            SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            )
          ],
        ),
      ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F5FC),
      appBar: AppBar(
        title: Text("오픈채팅방"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                padding: EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  return _buildMessage(messages[index]);
                },
              ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "메시지를 입력하세요",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                      ),
                    )),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Text("전송", style: TextStyle(color: Colors.white)),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}
