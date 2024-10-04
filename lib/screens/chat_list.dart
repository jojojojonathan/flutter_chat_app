import 'package:chat_app/screens/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/chat_room.dart';
// import 'package:chat_app/screens/global.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Lists',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No chats found'),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong...'),
            );
          }

          final userData = snapshot.data!;

          if (userData.data()?.containsKey('roomIds') ?? false) {
          final roomIds = userData['roomIds'];

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('roomId', whereIn: roomIds)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No chats found'),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong...'),
                  );
                }

                final chats = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data();
                    final participants = chat['participants'];
                    final friendId = participants.firstWhere(
                        (id) => id != FirebaseAuth.instance.currentUser!.uid);
                    final friendRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(friendId);

                    return FutureBuilder(
                      future: friendRef.get(),
                      builder: (context, friendSnapshot) {
                        if (friendSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!friendSnapshot.hasData ||
                            friendSnapshot.data == null) {
                          return const Center(
                            child: Text('Chat list not found'),
                          );
                        }

                        if (friendSnapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong...'),
                          );
                        }

                        final friend = friendSnapshot.data!;

                        return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection('chat')
                              .where('roomId', isEqualTo: chat['roomId'])
                              .orderBy('createdAt', descending: true)
                              .limit(1)
                              .get(),
                          builder: (context, messageSnapshot) {
                            if (messageSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (messageSnapshot.data!.docs.isNotEmpty) {
                              final lastMessage =
                                  messageSnapshot.data!.docs[0].data();

                              return ListTile(
                                title: Text(friend['username'] ?? 'Unknown'),
                                subtitle: Text(
                                    messageSnapshot.data!.docs.isEmpty
                                        ? ''
                                        : lastMessage['text']),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(friend['image_url'] ?? ''),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatRoom: ChatRoom(
                                          roomId: chat['roomId'],
                                          participants: [userData.id, friendId],
                                          messages: [],
                                        ),
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {});
                                    }
                                  });
                                },
                              );
                            } else {
                              return ListTile(
                                title: Text(friend['username'] ?? 'Unknown'),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(friend['image_url'] ?? ''),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                        chatRoom: ChatRoom(
                                          roomId: chat['roomId'],
                                          participants: [userData.id, friendId],
                                          messages: [],
                                        ),
                                      ),
                                    ),
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {});
                                    }
                                  });
                                },
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('No chat list'),
            );
          }
        },
      ),
    );
  }
}
