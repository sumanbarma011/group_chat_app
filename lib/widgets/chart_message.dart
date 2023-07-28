import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_chat_app/widgets/message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartMessage extends StatelessWidget {
  const ChartMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final _loggedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(// available collection of documents of chart
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Conversation'),
          );
        }
        if (chatSnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        final loadedMessages = chatSnapshot.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chartMessage = loadedMessages[index].data();
              final nextMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chartMessage['userId'];
              final nextMessageUserId =
                  nextMessage != null ? nextMessage['userId'] : null;
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chartMessage['text'],
                    isMe: _loggedUser.uid == currentMessageUserId);
              } else {
                return MessageBubble.first(
                    userImage: chartMessage['userImage'],
                    username: chartMessage['username'],
                    message: chartMessage['text'],
                    isMe: _loggedUser.uid == currentMessageUserId);
              }
            });
      },
    );
  }
}
