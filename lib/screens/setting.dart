import 'package:chat_app/screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/language.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SettingScreen();
  }
}

class _SettingScreen extends State<SettingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var _enteredLanguage = '';
  var _enteredLanguageCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Setting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future:
              _firestore.collection('users').doc(_auth.currentUser!.uid).get(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          userData['image_url'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: userData['username'],
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  userData['username'] = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              initialValue: userData['email'],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  userData['email'] = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              initialValue: userData['ucid'],
                              decoration: const InputDecoration(
                                labelText: 'UCID',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  userData['ucid'] = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            DropdownButtonFormField<String>(
                              value: languageCodes.keys.firstWhere((key) =>
                                  languageCodes[key] == userData['language']),
                              items: languages
                                  .map((lang) => DropdownMenuItem(
                                        value: lang,
                                        child: Text(lang),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _enteredLanguage = value!;
                                  _enteredLanguageCode =
                                      languageCodes[_enteredLanguage]!;
                                });
                              },
                              menuMaxHeight: 300,
                              borderRadius: BorderRadius.circular(15),
                              decoration: const InputDecoration(
                                labelText: 'Language',
                              ),
                              isExpanded: true,
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _firestore
                                    .collection('users')
                                    .doc(_auth.currentUser!.uid)
                                    .update({
                                  'username': userData['username'],
                                  'email': userData['email'],
                                  'ucid': userData['ucid'],
                                  'language': _enteredLanguageCode,
                                }).then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Updated data success!')),
                                  );
                                });
                              },
                              child: const Text('Update'),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _auth.signOut();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()),
                                );
                              },
                              child: const Text('Log Out', style: TextStyle(color: Colors.red),),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
