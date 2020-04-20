import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _fireStore = Firestore.instance;
  FirebaseUser loggedInUser;
  String usersMessage;
  final _controller = TextEditingController();

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        debugPrint("user email is ${user.email}");
        loggedInUser = user;
      }
    } catch (e) {
      debugPrint("caught an exception with getting current user $e");
    }
  }

  void _getMessages() async {
    final messages = await _fireStore.collection("messages").getDocuments();
    messages.documents.forEach((documents) => debugPrint("documents are ${documents.data}"));
  }

  _logoutUser() {
    _auth.signOut();
    Navigator.pushNamed(context, '/login');
  }

  Widget _buildChatList(QuerySnapshot data) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      child: ListView.builder(
          reverse: true,
          itemCount: data.documents.length,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot snapshot = data.documents.reversed.toList()[index];
            String currentUser = loggedInUser.email;
            String sendersEmail = snapshot.data['sender'];

            bool isMe = currentUser == sendersEmail;

            print(snapshot.data);
            return Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Text(snapshot.data['sender'],
                    style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                SizedBox(height: 5.0),
                Material(
                  borderRadius: isMe
                      ? BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          bottomRight: Radius.circular(30.0))
                      : BorderRadius.only(
                          bottomRight: Radius.circular(30.0),
                          bottomLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0)),
                  elevation: 5.0,
                  color: isMe ? Colors.lightBlueAccent : Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    child: Text(snapshot.data['text'],
                        style:
                            TextStyle(color: isMe ? Colors.white : Colors.black54, fontSize: 15.0)),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                )
              ],
            );
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
                _logoutUser();
              })
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _fireStore.collection("messages").orderBy("time", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _buildChatList(snapshot.data);
                  } else {
                    return Center(
                      child: Text('No Chats'),
                    );
                  }
                },
              ),
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      maxLines: 2,
                      controller: _controller,
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        usersMessage = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //Implement send functionality.
                      _fireStore.collection("messages").add({
                        "text": usersMessage,
                        "sender": loggedInUser.email,
                        "time": DateTime.now()
                      });
                      setState(() => _controller.clear());
                    },
                    icon: Icon(Icons.send),
                    iconSize: 30.0,
                    color: Colors.lightBlue,
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
