import 'package:airline/BookingPage.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("문의하기"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {} ,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    if(message.containsKey("buttons")) {
                      return buttonBubble(message["text"],message["buttons"]);
                    }
                    return chatBubble(message["text"], message["isUser"]);
                  },
              ),
          ),
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

