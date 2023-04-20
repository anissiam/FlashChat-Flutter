import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat_flutter/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
late User loggerUser;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;

  late String messageText;
  final messageTextController = TextEditingController();

  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser;

      if (user != null) {
        loggerUser = user;
        print(loggerUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  /* getMessages() async {
    final messages = await _firestore.collection('messages').get();
    for(var message in messages.docs){
      print(message.data());
    }
  }*/

 /* Future<void> messageStream() async {
    await _firestore.collection('messages').snapshots().listen((event) {
      for (var message in event.docs) {
        // print(message.data());
      }
    });
  }*/

  @override
  void initState() {
    getCurrentUser();
    //getMessages();
    //messageStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality

                try {
                  _auth.signOut();
                  Navigator.pop(context);
                } catch (e) {}
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      //Implement send functionality.
                      messageTextController.clear();
                      try {
                        var test = _firestore.collection('messages').add(
                            {'text': messageText, 'sender': loggerUser.email});
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        List<MessageBubble> messageBubbles = [];
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        snapshot.data?.docs.reversed.forEach(
          (e) {
            print(e.data());
            final messageText = e.get('text');
            final messageSender = e.get('sender');

            final currentUser = loggerUser.email;

            final messageWidget = MessageBubble(
              text: messageText,
              sender: messageSender,
              ifMe: currentUser == messageSender,
            );
            messageBubbles.add(messageWidget);
          },
        );
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool ifMe;

  const MessageBubble(
      {required this.sender, required this.text, required this.ifMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child:
          Column(crossAxisAlignment:ifMe? CrossAxisAlignment.end :CrossAxisAlignment.start,
              children: <Widget>[
        Text(
          sender,
          style: TextStyle(fontSize: 12.0, color: Colors.black54),
        ),
        Material(
            borderRadius:ifMe
                ?BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0))
                :BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: ifMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                '$text',
                style: TextStyle(
                  color: ifMe ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            )),
      ]),
    );
  }
}
