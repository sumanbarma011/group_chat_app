import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Chart extends StatelessWidget {
  const Chart({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart Screen'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut(); // to signout user 
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      body: const Center(
        child: Text('No chart left'),
      ),
    );
  }
}
