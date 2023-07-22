import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;



class Artificial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ask Teacher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  List<String> _messages = [];
  bool isLoading = false;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  void _submitMessage(String message) async {
    setState(() {
      isLoading = true;
    });
    _controller.clear();
    _messages.insert(0, message);

    var response =
    await http.post(Uri.parse('https://api.openai.com/v1/engines/davinci-codex/completions'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_KEY_HERE',
        },
        body: json.encode({
          'prompt': message,
          'temperature': 0.5,
          'max_tokens': 100,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 0
        }));
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var aiResponse = jsonResponse['choices'][0]['text'];
      setState(() {
        isLoading = false;
        _messages.insert(0, "AI response: " + aiResponse);
        _animationController!.reverse(from: 1.0);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    _animationController!.forward(from: 0.0);
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _controller,
              onSubmitted: _submitMessage,
              decoration:
              const InputDecoration.collapsed(hintText: "Enter your message"),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                _submitMessage(_controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Flexible(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        reverse: true,
        itemCount: _messages.length + 1,
        itemBuilder: (_, int index) {
          if (index == 0 && isLoading) {
            return FadeTransition(
              opacity: _animation!,
              child: const SpinKitChasingDots(
                color: Colors.black,
                size: 50.0,
              ),
            );
          }
          if (index == _messages.length) {
            return const SizedBox.shrink();
          }
          return ChatBubble(
            isAI: index % 2 == 0,
            message: _messages[index],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.deepPurple],
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: CustomScrollView(
                slivers: <Widget>[
                  const SliverAppBar(
                    backgroundColor: Colors.deepPurple,
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(60.0),
                        bottomRight: Radius.circular(60.0),
                      ),
                    ),
                    expandedHeight: 120.0,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'let us learn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    fillOverscroll: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildMessageList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: _buildTextComposer(),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isAI;
  final String message;

  ChatBubble({required this.isAI, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OpenContainer(
        closedColor: isAI ? Colors.grey[200]! : Colors.blue[200]!,
        transitionDuration: const Duration(milliseconds: 400),
        closedElevation: 5.0,
        openElevation: 0.0,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 16.0),
            ),
          );
        },
        closedBuilder: (BuildContext context, VoidCallback _) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}


