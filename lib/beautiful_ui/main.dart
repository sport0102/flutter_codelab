// Copyright 2017, 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.
import 'package:flutter/cupertino.dart'; // NEW
import 'package:flutter/foundation.dart'; // NEW
import 'package:flutter/material.dart';

void main() {
  runApp(
    const FriendlyChatApp(),
  );
}

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
      .copyWith(secondary: Colors.orangeAccent[400]),
);

class ChatMessage extends StatelessWidget {
  ChatMessage({
    required this.text, // NEW
    required this.animationController, // NEW
    Key? key,
  }) : super(key: key);
  final String text;
  final _name = ["aiden"];
  final AnimationController animationController; // NEW

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name[0], style: Theme.of(context).textTheme.headline4),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
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

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // MODIFIED
      title: 'FriendlyChat',
      theme: defaultTargetPlatform == TargetPlatform.iOS // NEW
          ? kIOSTheme // NEW
          : kDefaultTheme, // NEW
      home: const ChatScreen(), // MODIFIED
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<ChatMessage> _messages = []; // NEW
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // NEW
  bool _isComposing = false; // NEW

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      // NEW
      _isComposing = false; // NEW
    });
    var message = ChatMessage(
      // NEW
      text: text, // NEW
      animationController: AnimationController(
        // NEW
        duration: const Duration(milliseconds: 700), // NEW
        vsync: this, // NEW
      ), // NEW
    ); // NEW
    setState(() {
      // NEW
      _messages.insert(0, message); // NEW
    });
    _focusNode.requestFocus(); // NEW
    message.animationController.forward(); // NEW
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('FriendlyChat'),
          elevation: Theme.of(context).platform == TargetPlatform.iOS
              ? 0.0
              : 4.0), // NEW,

      body: Container(
        child: Column(
          // MODIFIED
          children: [
            // NEW
            Flexible(
              // NEW
              child: ListView.builder(
                // NEW
                padding: const EdgeInsets.all(8.0), // NEW
                reverse: true, // NEW
                itemBuilder: (_, index) => _messages[index], // NEW
                itemCount: _messages.length, // NEW
              ), // NEW
            ), // NEW
            const Divider(height: 1.0), // NEW
            Container(
              // NEW
              decoration:
                  BoxDecoration(color: Theme.of(context).cardColor), // NEW
              child: _buildTextComposer(), // MODIFIED
            ), // NEW
          ], // NEW
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS // NEW
            ? BoxDecoration(
                // NEW
                border: Border(
                  // NEW
                  top: BorderSide(color: Colors.grey[200]!), // NEW
                ), // NEW
              ) // NEW
            : null,
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  // NEW
                  setState(() {
                    // NEW
                    _isComposing = text.isNotEmpty; // NEW
                  }); // NEW
                },
                // NEW
                onSubmitted: _isComposing ? _handleSubmitted : null,
                // MODIFIED
                decoration:
                    const InputDecoration.collapsed(hintText: 'Send a message'),
                focusNode: _focusNode, // NEW
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? // MODIFIED
                    CupertinoButton(
                        // NEW
                        child: const Text('Send'), // NEW
                        onPressed: _isComposing // NEW
                            ? () =>
                                _handleSubmitted(_textController.text) // NEW
                            : null,
                      )
                    : // NEW
                    IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isComposing // MODIFIED
                            ? () => _handleSubmitted(
                                _textController.text) // MODIFIED
                            : null, // MODIFIED
                      )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
