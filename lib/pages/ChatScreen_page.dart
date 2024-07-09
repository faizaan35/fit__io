import 'package:fit_io/pages/Home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final Box _chatBox = Hive.box('chatBox'); // Reference to the Hive box
  List<ChatMessage> _messages = [];

  final String apiKey = 'YOUR_API_KEY';

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final messages = _chatBox.get('messages', defaultValue: []) as List;
    setState(() {
      _messages = messages.map((message) {
        return ChatMessage.fromMap(Map<String, dynamic>.from(message));
      }).toList();
    });
  }

  void _saveMessages() {
    _chatBox.put('messages', _messages.map((msg) => msg.toMap()).toList());
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        message: _controller.text,
        isBot: false,
      ));
      _controller.clear();
    });

    _saveMessages();

    final response = await _callOpenAI(_messages.last.message);

    setState(() {
      _messages.add(ChatMessage(
        message: response,
        isBot: true,
      ));
    });

    _saveMessages();
  }

  Future<String> _callOpenAI(String prompt) async {
    const url = 'https://api.openai.com/v1/engines/davinci-codex/completions';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'max_tokens': 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['text'].trim();
    } else {
      throw Exception('Failed to load response from OpenAI');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text(
          'Chatbot.ai',
          style: GoogleFonts.cabin(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context), // Navigate back to previous screen
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[300],
        child: Column(
          children: [
            Container(
              color: Colors.grey[300],
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'online',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _messages.map((message) {
                      return Align(
                        alignment: message.isBot
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: _buildChatBubble(
                          message.message,
                          isBot: message.isBot,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(255, 0, 0, 0),
                        hintText: 'Enter a prompt here ...',
                        hintStyle: GoogleFonts.cabin(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Padding(
                          padding: EdgeInsets.all(9.0),
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
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

  Widget _buildChatBubble(String message, {required bool isBot}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBot ? Color.fromARGB(255, 0, 0, 0) : Colors.green,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft:
              isBot ? const Radius.circular(0) : const Radius.circular(15),
          bottomRight:
              isBot ? const Radius.circular(15) : const Radius.circular(0),
        ),
      ),
      child: Text(
        message,
        style: GoogleFonts.cabin(color: Colors.white),
      ),
    );
  }
}

class ChatMessage {
  final String message;
  final bool isBot;

  ChatMessage({required this.message, required this.isBot});

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isBot': isBot,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] as String,
      isBot: map['isBot'] as bool,
    );
  }
}
