import 'package:airline/BookingPage.dart';
import 'package:airline/ChatInputField.dart';
import 'package:airline/providers/auth_provider.dart';
import 'package:flutter/material.dart';
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

  List<Map<String, dynamic>> messages = [
    {
      "text": "문의 사항을 선택해주세요.",
      "buttons": ["예약 현황 확인", "상담사와 연결하기"],
      "isUser": false
    },
  ];

    void handleUserSelection(String requestType){
      setState(() {
        messages.add({"text": requestType, "isUser": true});
      });

      if(requestType == "예약 현황 확인"){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> BookingPage()),
        );
        return;
      }

      if(requestType == "상담사와 연결하기") {
        setState(() {
          messages.add({
            "text": "상담사와 연결중입니다. 내용을 입력해주세요.",
            "isUser": false
          });
          isChatInputVisible = true;
        });
        return;
      }


      _chatService.sendRequest(requestType).then((responseMessage){
        setState(() {
          messages.add({"text": responseMessage, "isUser":false});
        });
      });
    }

    void handleMessageSend(String message){
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final sender = authProvider.userName;

      if(sender == null){
        print("로그인된 유저x");
        return;
      }

      _chatService.sendChatMessage(sender, message);
      setState(() {
        messages.add({"text": message, "isUser":true});
      });
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

