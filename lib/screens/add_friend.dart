import 'package:chat_app/screens/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddFriendScreenState();
  }
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ucidController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Add Friends'),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                    child: TextFormField(
                      controller: _ucidController,
                      decoration: InputDecoration(
                          hintText: 'Enter UCID',
                          hintStyle: const TextStyle(fontSize: 12),
                          filled: true,
                          fillColor: Colors.grey[200],
                          contentPadding: const EdgeInsets.all(16.0),
                          prefixIcon: const Icon(Icons.search)),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your friend\'s UCID';
                        }
                        return null;
                      },
                    ),
                  ),
                  // TextFormField(
                  //   controller: _ucidController,
                  //   decoration: const InputDecoration(
                  //     labelText: 'Enter UCID',
                  //     filled: true,
                  //     fillColor: Colors.grey,
                  //   ),
                  //   validator: (value) {
                  //     if (value!.isEmpty) {
                  //       return 'Please enter your friend\'s UCID';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _addFriend,
                    child: const Text('Add Friend'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Requests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.start,),
              ],
            ),
            const SizedBox(height: 10,),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('to',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error mengambil data'));
                  }
                  


                  final requests = snapshot.data!.docs;

                  if (requests.isEmpty) {
                    return const Center(child: Text('No Request'),);
                  }

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      final fromUid = request['from'];
                      final fromRef = FirebaseFirestore.instance
                          .collection('users')
                          .doc(fromUid);

                      return FutureBuilder<DocumentSnapshot>(
                        future: fromRef.get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error mengambil data'));
                          }

                          final fromDoc = snapshot.data!;

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            fromDoc['image_url']),
                                        radius: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(fromDoc['username']),
                                          Text('Status: ${request['status']}', style: TextStyle(fontSize: 12, color: request['status'] == 'pending' ? Colors.orange : request['status'] == 'accepted' ? Colors.green : Colors.red),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 35,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('requests')
                                                .doc(request.id)
                                                .update({
                                              'status': 'accepted',
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('requests')
                                                .doc(request.id)
                                                .delete();
                                        
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              'friends': FieldValue.arrayUnion(
                                                  [fromUid]),
                                            });
                                        
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(fromUid)
                                                .update({
                                              'friends': FieldValue.arrayUnion([
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                              ]),
                                            });
                                          },
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(fontSize: 12, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        height: 35,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('requests')
                                                .doc(request.id)
                                                .delete();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text(
                                            'Reject',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addFriend() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      final ucId = _ucidController.text;
      final user = FirebaseAuth.instance.currentUser!;

      final friendRef = FirebaseFirestore.instance
          .collection('users')
          .where('ucid', isEqualTo: ucId);

      final friendQuery = await friendRef.get();

      if (friendQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User tidak ditemukan'),
          ),
        );
        setState(() {
          _loading = false;
        });
        return;
      }

      final friendUid = friendQuery.docs.first.id;

      // Cek apakah ucid yang dimasukan sudah menjadi teman
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final userDoc = await userRef.get();

      if (userDoc.exists) {
        final friends = userDoc.get('friends');

        if (friends.contains(friendUid)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User sudah menjadi teman'),
            ),
          );
          setState(() {
            _loading = false;
          });
          return;
        }
      }

      final requestRef =
          FirebaseFirestore.instance.collection('requests').doc();

      await requestRef.set({
        'from': user.uid,
        'to': friendQuery.docs.first.id,
        'status': 'pending',
      });

      // final requestQuery = await requestRef.get();
      // if (requestQuery.exists) {
      //   print('Request pertemanan disimpan di Firestore');
      // } else {
      //   print('Request pertemanan tidak disimpan di Firestore');
      // }

      final user2Ref = FirebaseFirestore.instance
          .collection('users')
          .doc(friendQuery.docs.first.id);
      try {
        final user2Doc = await user2Ref.get();
        if (user2Doc.exists) {
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User 2 tidak ada di Firestore'),
            ),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
        return;
      }

      // final requestQuery2 = await requestRef.get();
      // if (requestQuery2.exists) {
      //   print('Request pertemanan dikirim ke user 2');
      // } else {
      //   print('Request pertemanan tidak dikirim ke user 2');
      // }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permintaan pertemanan telah dikirim'),
        ),
      );

      setState(() {
        _loading = false;
        _ucidController.clear();
      });
    }
  }
}
