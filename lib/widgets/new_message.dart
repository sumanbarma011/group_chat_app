import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var _messageController = TextEditingController();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMesaage() async {
    final enteredMessages = _messageController.text;
    if (enteredMessages.trim().isEmpty) {
      return;
    }

    
    FocusScope.of(context).unfocus(); // to hide the keyboard as soon as select button is clicked
    _messageController.clear(); // clearing text message 


    // globally availabled firebaseAuth instance in this section is used to get data for logged in users
    final userId = FirebaseAuth.instance.currentUser!;

// getting data from the previous collection document
    final userData = await FirebaseFirestore.instance
        .collection('users_details')
        .doc(userId.uid)
        .get();

//sending message data to the cloud firestore

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessages,
      'createdAt': Timestamp.now(),
      'userId': userId.uid,
      'username': userData.data()!['userName'],
      'userImage': userData.data()!['image_url']
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              enableSuggestions: true,
              autocorrect: true,
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Send a message..'),
            ),
          ),
          IconButton(
            onPressed: _submitMesaage,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
    );
  }
}
