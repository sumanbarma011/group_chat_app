import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat_app/widgets/user_image_picker.dart';
import 'dart:io';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredUserName = '';

  var _enteredPassword = '';
  bool _isAuthenticating = false;
  File? _selectedImage;
  void selectImage(File image) {
    _selectedImage = image;
    log('=========');
    print(_selectedImage);
  }

  final _form = GlobalKey<FormState>();
  void _submit() async {
    setState(() {
      _isAuthenticating = true;
    });

    bool isValid = _form.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the details correctly')));
      setState(() {
        _isAuthenticating = false;
      });

      return;
    }

    _form.currentState!.save();
    print(_enteredEmail);
    print(_enteredPassword);
    try {
      if (_isLogin) {
        // login mode
        final userCredentials = await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail,
            password:
                _enteredPassword); //to verify sighned in email and password on firebase for authentication
        print(userCredentials);
      } else {
        // sign up mode

        // to post email and password on firebase for authentication
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        //to upload the image on the firebae storage using firebase storage package
        // storageRef creates a folder along file path on firebase storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${userCredentials.user!.uid}.jpeg');

        // puts the file on the file path
        await storageRef.putFile(_selectedImage!);

        // generates a url to download the image
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);

        // store  the users data locally on firebase using package cloud_firestore
        FirebaseFirestore.instance
            .collection('users_details')
            .doc(userCredentials.user!.uid)
            .set({
          'userName': _enteredUserName,
          'email': _enteredEmail,
          'image_url': imageUrl
        });
      }
    }

    // since firebase auth shows some exception which is of type FirebaseAuthException
    on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication errro'),
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });

      // ?? operator is used where we want to show any other messages or information in case the data could be null
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
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.jpeg'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
                          if (!_isLogin)
                            UserImagePicker(selectImage: selectImage),
                             if (!_isLogin)
                            TextFormField(
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter a valid username';
                                }
                                return null;
                                
                              },
                              onSaved: (newValue) {
                                _enteredUserName=newValue!;
                              },
                              enableSuggestions: false,
                              decoration:
                                  const InputDecoration(labelText: 'UserName'),
                            ),
                          TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 5) {
                                return 'Please enter a valid password';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
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
                                    .primaryContainer,
                              ),
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
                      ),
                    ),
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
