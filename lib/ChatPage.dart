import 'package:airline/BookingPage.dart';
import 'package:airline/ChatInputField.dart';
import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

import 'ChatService.dart';
import 'models/ChatRoom.dart';

class ChatPage extends StatefulWidget {
  final ChatRoom chatRoom;

  const ChatPage({Key? key, required this.chatRoom}) : super(key: key);
  

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService();
  bool isChatInputVisible = false;
  String? _roomId;
  List<Map<String, dynamic>> messages = [];
  @override
  void dispose() {
    _chatService.stompClient?.deactivate();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sender = widget.chatRoom.userName; // 여기 이거 userName말고, 채팅방 당사자 이름
      _roomId = _chatService.generateRoomId(sender!); // 또는 widget.chatRoom.roomId
      final loginUser = authProvider.userName;
      /*
      1. roomId 가 이미 존재하는지 서버에 확인 요청 (이미 오늘 문의기록있는지)
       */
      _chatService.checkRoomExists(_roomId!).then((exists) {
        print("sender $sender");
        if (exists) {
          /*
          2. 방이 존재한다면, 이전 문의기록을 불러오고, stomp 연결
           */
          _chatService.getMessagesForRoom(_roomId!).then((previousMessage) {
            setState(() {
              messages.addAll(previousMessage.map((msg) {
                return {
                  "text": msg["message"],
                  "isUser": msg["sender"] == loginUser
                };
              }));
              isChatInputVisible = true;
            });

            _chatService.connectStomp(_roomId!, (msg) {
              print("msg $msg");
              setState(() {
                messages.add({
                  "text": msg["message"],
                  "isUser": msg["sender"] == loginUser
                });
              });
            });
          });
        } else {
          /*
          3. 오늘 처음 문의하는 거라면 (roomId가없다면) 버튼만 보여주고 대기
           */
          setState(() {
            messages = [
              {
                "text": "문의 사항을 선택해주세요.",
                "buttons": ["예약 현황 확인", "상담사와 연결하기"],
                "isUser": false
              }
            ];
          });
        }
      });
    });
  }

      void handleUserSelection(String requestType) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final sender = authProvider.userName;
        final roomId = _chatService.generateRoomId(sender!);
        setState(() {
          messages.add({"text": requestType, "isUser": true});
        });

        if (requestType == "예약 현황 확인") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingPage()),
          );
          return;
        }

        if (requestType == "상담사와 연결하기") {
          setState(() {
            messages.add({
              "text": "상담사와 연결중입니다. 내용을 입력해주세요.",
              "isUser": false
            });
            isChatInputVisible = true;
          });

          _chatService.connectStomp(roomId, (msg) {
            setState(() {
              messages.add({
                "text": msg["message"],
                "isUser": msg["sender"] == sender
              });
            });
          });
          return;
        }
      }

      void handleMessageSend(String message) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final sender = authProvider.userName;
        if(_roomId! == null){
          _roomId = _chatService.generateRoomId(sender!);
        }
        if (sender == null) {
          print("로그인된 유저x");
          return;
        }
        _chatService.sendStompMessage(_roomId!, sender, message);

      }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("문의하기"),
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return Column(
                      crossAxisAlignment: message["isUser"]
                      ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: message["isUser"]? Colors.blue : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message["text"],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        if(message.containsKey("buttons"))
                          Wrap(
                            spacing: 8,
                            children: List<Widget>.generate(
                              message["buttons"].length,
                                (btnIndex) => ElevatedButton(
                                    onPressed: ()=> handleUserSelection(message["buttons"][btnIndex]),
                                    child: Text(message["buttons"][btnIndex]),
                                ),
                            ),
                          ),
                      ],
                    );
                  },
              ),
          ),
          if(isChatInputVisible)
            ChatInputField(onSend: handleMessageSend),
        ],
      ),
    );
  }

  Widget chatBubble(String text, bool isUser){
     return Align(
       alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
       child: Container(
         margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
         padding: const EdgeInsets.all(10),
         decoration: BoxDecoration(
           color: isUser ? Colors.blueAccent : Colors.grey[300],
           borderRadius: BorderRadius.circular(15),
         ),
         child: Text(text, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
       ),
     );
}

  Widget buttonBubble(String text, List<String> options){
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text, style: TextStyle(color: Colors.black)),
            const SizedBox(height: 10),
            Column(
              children: options.map((option){
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.blueAccent),
                ),
                ),
                onPressed: () => handleUserSelection(option),
                child: Text(option, style: const TextStyle(fontSize: 16)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

