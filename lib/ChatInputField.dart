import 'package:flutter/material.dart';

class ChatInputField extends StatelessWidget {

  final Future<void> Function(String message) onSend;

  ChatInputField({required this.onSend});

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (message){
                    if(message.isNotEmpty){
                      onSend(message);
                      _controller.clear();
                    }
                  },
                ),
            ),
            IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  if(_controller.text.isNotEmpty){
                    await onSend(_controller.text);
                    _controller.clear();
                  }
                },
            )
          ],
        ),
    );
  }
}
