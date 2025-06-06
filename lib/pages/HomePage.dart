import 'dart:math';

import 'package:airline/services/ChatService.dart';
import 'package:airline/services/open_chat_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final OpenChatService openChatService = OpenChatService();
  Map<String, List<Map<String, dynamic>>> groupedRooms = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  Future<void> _loadChatRooms() async {
    try {
      final data = await openChatService.fetchGroupedChatRooms();
      setState(() {
        groupedRooms = data;
        isLoading = false;
      });
    } catch (e) {
      print("오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("홈"),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Color(0xFFF8F5FC),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 여행지 소통방 섹션
              Text(
                "여행지 소통방",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 12),

              // 서버에서 받아온 여행지별 채팅방 목록 렌더링
              ...groupedRooms.entries.map((entry) {
                final destination = entry.key;
                final chatRooms = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: min(chatRooms.length, 2),
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, i) {
                        final room = chatRooms[i];
                        return GestureDetector(
                          onTap: () {
                            // TODO: 채팅방 입장 로직
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.purpleAccent.shade100,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple
                                      .withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    room['imageUrl'],
                                    height: 100,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    room['roomName'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                  ],
                );
              }).toList(),

              // 섹션 구분선
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  thickness: 1,
                  color: Colors.deepPurple.shade100,
                ),
              ),

              // 추천 게시글 섹션
              Text(
                "추천 게시글",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "🛫 곧 추가될 여행 정보 콘텐츠 영역입니다.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}