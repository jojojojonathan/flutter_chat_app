import 'dart:io';

import 'package:chat_app/screens/language.dart';
import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _enteredUCID = '';
  var _enteredLanguage = 'English';
  var _enteredLanguageCode= '';
  File? _selectedImage;
  var _isAuthenticating = false;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage == null) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'ucid': _enteredUCID,
          'language': _enteredLanguageCode,
          'image_url': imageURL,
          'friends': []
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication Failed.'),
      ));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLogin)
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('assets/images/chat.png'),
                ),
              if (!_isLogin)
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 100,
                  child: Image.asset('assets/images/chat.png'),
                ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isLogin)
                              const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              ),
                            const SizedBox(
                              height: 20,
                            ),
                            if (!_isLogin)
                              const Text('Register',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w700)),
                            const SizedBox(
                              height: 20,
                            ),
                            if (!_isLogin)
                              UserImagePicker(
                                onPickedImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    labelText: 'Username'),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 5) {
                                    return 'Please enter username at least 5 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUsername = value!;
                                },
                              ),
                            if (!_isLogin)
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'UCID'),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().length < 5) {
                                    return 'Please enter UCID at least 5 characters.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredUCID = value!;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  labelText: 'Email Address'),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            if (!_isLogin)
                              DropdownButtonFormField<String>(
                                // value: _enteredLanguage,
                                hint: const Text('Choose your language'),
                                items: languages
                                    .map((lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(lang),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _enteredLanguage = value!;
                                     _enteredLanguageCode = languageCodes[_enteredLanguage]!;

                                  });
                                },
                                menuMaxHeight: 300,
                                borderRadius: BorderRadius.circular(15),
                                decoration: const InputDecoration(
                                  labelText: 'Language',
                                ),
                                isExpanded: true,
                              ),
                            const SizedBox(height: 12),
                            if (_isAuthenticating)
                              const CircularProgressIndicator(),
                            if (!_isAuthenticating)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!_isAuthenticating)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'I already have an account'),
                              ),
                          ],
                        )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
