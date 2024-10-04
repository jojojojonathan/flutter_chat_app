import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/repository/user_data_repository.dart';
import 'package:chat_app/screens/add_friend.dart';
import 'package:chat_app/screens/chat_room.dart';
import 'package:chat_app/screens/setting.dart';
import 'package:chat_app/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _searchController = TextEditingController();

  final UserDataRepository _userDataRepository = UserDataRepository();

  List<String> _friendsList = [];
  List<String> _filteredFriendsList = [];

  @override
  void dispose() {
    friendsList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _userDataRepository.getUserDataStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching user data'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SplashScreen();
        }

        final userData = snapshot.data;
        final username = userData?['username'];
        final userProfile = userData?['image_url'];

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 200,
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(userProfile),
                  ),
                  Text('hello, $username'),
                ],
              ),
            ),
            actions: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('to',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (snapshot.hasError) {
                    return const Text('Error mengambil data');
                  }

                  final requests = snapshot.data!.docs;

                  return IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddFriendScreen()),
                      );
                    },
                    icon: requests.isEmpty
                        ? const Icon(Icons.person_add)
                        : Badge.count(
                            count: requests.length.toInt(),
                            child: const Icon(Icons.person_add),
                          ),
                  );
                },
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingScreen()),
                    );
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 20,
                  )),
            ],
            backgroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.all(16.0),
                        prefixIcon: const Icon(Icons.search)),
                    onChanged: (text) {
                      setState(() {
                        _filteredFriendsList = _friendsList
                            .where((friend) => friend
                                .toLowerCase()
                                .contains(text.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 20, bottom: 10),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Friend lists',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
              Expanded(
                  child: FutureBuilder<DocumentSnapshot>(
                future: _userDataRepository.getUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error mengambil data'));
                  }

                  if (snapshot.hasData) {
                    snapshot.data?.get('friends')?.forEach((friend) {
                      friendsList.add(friend);
                    });

                    if (friendsList.isNotEmpty) {
                      return ListView.builder(
                        itemCount: friendsList.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(friendsList[index])
                                .get(),
                            builder: (context, friendSnapshot) {
                              if (friendSnapshot.hasData) {
                                return ColoredBox(
                                  color: Colors.green,
                                  child: Material(
                                    child: ListTile(
                                      title: Text(
                                          friendSnapshot.data?.get('username')),
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            friendSnapshot.data
                                                ?.get('image_url')),
                                      ),
                                      onTap: () async {
                                        final roomId =
                                            '${user.uid}-${friendsList[index]}';

                                        final chatRoomRef = FirebaseFirestore
                                            .instance
                                            .collection('chats')
                                            .doc(roomId);

                                        await chatRoomRef.set({
                                          'roomId': roomId,
                                          'participants': [
                                            user.uid,
                                            friendsList[index]
                                          ],
                                          'messages': [],
                                          'createdAt': Timestamp.now()
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .update({
                                          'roomIds':
                                              FieldValue.arrayUnion([roomId])
                                        });

                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(friendsList[index])
                                            .update({
                                          'roomIds':
                                              FieldValue.arrayUnion([roomId])
                                        });

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ChatRoomScreen(
                                              chatRoom: ChatRoom(
                                                roomId: roomId,
                                                participants: [
                                                  user.uid,
                                                  friendsList[index]
                                                ],
                                                messages: [],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No Friends'));
                    }
                  }
                  return const SizedBox.shrink();
                },
              )),
            ],
          ),
        );
      },
    );
  }
}
