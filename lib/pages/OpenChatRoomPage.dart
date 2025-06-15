import 'package:airline/services/open_chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      onNewMessage: (msg) {
        setState(() {
          _addMessage(msg);
        });
      },
      onUnreadCountUpdated: (messageId, updatedCount) {
        final index = messages.indexWhere((m) => m['id'] == messageId);
        if (!mounted) return;
        if (index != -1) {
          setState(() {
            messages[index]['unreadCount'] = updatedCount;
          });
        }
      },
    );

    if(!isFirstJoin){
      final lastReadMessageId = await _chatService.fetchLastReadMessageId(widget.roomId, widget.myNickname);
      print("lastRead $lastReadMessageId");
      final messagesSince = await _chatService.fetchMessagesSince(
        roomId: widget.roomId,
        since: participant['joinedAt'],
        username: widget.myNickname
      );


      int focusIndex = 0;
      for (int i=0; i< messagesSince.length; i++){
        _addMessage(messagesSince[i]);
        if(messagesSince[i]['id'] == lastReadMessageId){
          focusIndex = i + 1;
        }

        if (
        messagesSince[i]['sender'] != widget.myNickname &&
            (messagesSince[i]['unreadCount'] ?? 0) > 0
        ) {
          _chatService.sendReadNotification(
            roomId: widget.roomId,
            messageId: messagesSince[i]['id'],
            username: widget.myNickname,
          );
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final scrollTarget = (focusIndex * 80.0).clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.animateTo(
          scrollTarget,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
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

  Future<void> _addMessage(Map<String, dynamic> message) async {
    setState(() {
      messages.add(message);
    });

    if (message['type'] == 'TALK') {
      final index = messages.length - 1;

      // 내가 보낸 메시지가 아니라면 읽음 처리
      if (message['sender'] != widget.myNickname) {
        await _chatService.markMessageAsRead(
          roomId: widget.roomId,
          messageId: message['id'],
          username: widget.myNickname,
        );
      }

      // 💡 모든 메시지에 대해 unreadCount 조회 (내가 보낸 메시지 포함)
      final count = await _chatService.fetchUnreadCount(
        widget.roomId,
        message['id'],
      );
      setState(() {
        messages[index]['unreadCount'] = count;
      });
    }

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
    _controller.clear();
  }

  Widget _buildMessage(Map<String, dynamic> msg){
    final isMine = msg['sender'] == widget.myNickname;
    final type = msg['type'];
    final time = DateFormat('HH:mm').format(DateTime.parse(msg['sendAt']));
    final unreadCount = msg['unreadCount'] ?? 0;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: isMine
                  ? [

                    if (unreadCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "$unreadCount",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      )
                  ]
                : [
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  if (unreadCount > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$unreadCount",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),

            ],
            ),
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
