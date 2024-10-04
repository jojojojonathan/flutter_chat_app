import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messeges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.chatRoom});

  final ChatRoom chatRoom;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  String _friendName = '';
  String _friendImage = '';

  @override
  void initState() {
    super.initState();
    _getFriendData();
  }

  Future<void> _getFriendData() async {
    final friendId = widget.chatRoom.participants[1];
    final friendRef = FirebaseFirestore.instance.collection('users').doc(friendId);
    final friendSnapshot = await friendRef.get();
    if (friendSnapshot.exists) {
      _friendName = friendSnapshot.data()!['username'];
      _friendImage = friendSnapshot.data()!['image_url'];
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(_friendImage),
              ),
              const SizedBox(width: 10),
              Text(_friendName),
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
             Expanded(
              child: ChatMessages(chatRoom: widget.chatRoom,),
            ),
            NewMessege(chatRoom: widget.chatRoom,)
          ],
        )),
    );
  }
}
