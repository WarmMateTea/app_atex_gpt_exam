import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:http/http.dart' as http;

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  TextEditingController text = TextEditingController();
  TextEditingController response = TextEditingController();

  Future<String?> request(String prompt) async {
    Uri chatUri = Uri.parse('https://api.openai.com/v1/chat/completions');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer NULL',
    };
    try {
      ChatRequest request = ChatRequest(model: "gpt-3.5-turbo", messages: [Message(role: "system", content: prompt)]);
      if (prompt.isEmpty) {
        return null;
      }
      print("pré-response");
      http.Response response = await http.post(
        chatUri,
        headers: headers,
        body: request.toJson(),
      );
      print("pós-response");
      ChatResponse chatResponse = ChatResponse.fromResponse(response);
      print(chatResponse.choices?[0].message?.content);
      return chatResponse.choices?[0].message?.content;
    } catch (e) {
      print("error $e");
    }
      return null;
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          Text("Chat Home"),
          TextFormField(
            controller: text,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              response.text = await request(text.text) ?? "";
              print(text.text);
              setState(() {});
            }, 
          child: Text("Enviar")),
          SizedBox(height: 20),
          TextFormField(
            controller: response,
          )
        ],
      )),
    );
  }
}

class ChatService {
  static final Uri chatUri = Uri.parse('https://api.openai.com/v1/chat/completions');

  static final Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer NULL',
  };

}

class ChatRequest {
  final String model;
  final List<Message> messages;

  ChatRequest({required this.model, required this.messages,});

  String toJson() {
    Map<String, dynamic> jsonBody = {
      'model': model,
      'messages': List<Map<String, dynamic>>.from(messages.map((message) => message.toJson())),
    };
    return jsonEncode(jsonBody);
  }
}

class Message {
  final String? role;
  final String? content;

  Message({this.role, this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}

class ChatResponse {
  final String? id;
  final String object;
  final int? created;
  final String? model;
  final List<Choice>? choices;
  final Usage usage;

  const ChatResponse({
    required this.id,
    required this.object,
    required this.created,
    required this.model,
    required this.choices,
    required this.usage,
  });

  factory ChatResponse.fromResponse(http.Response response) {
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> parsedBody = json.decode(responseBody);
    return ChatResponse(
      id: parsedBody['id'],
      object: parsedBody['object'],
      created: parsedBody['created'],
      model: parsedBody['model'],
      choices: List<Choice>.from(parsedBody['choices'].map((choice) => Choice.fromJson(choice))),
      usage: Usage.fromJson(parsedBody['usage']),
    );
  }
}

class Choice {
  final int? index;
  final Message? message;
  final String? finishReason;

  Choice(this.index, this.message, this.finishReason);

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      json['index'],
      Message.fromJson(json['message']),
      json['finish_reason'],
    );
  }
}

class Usage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  Usage({this.promptTokens, this.completionTokens, this.totalTokens});

  factory Usage.fromJson(Map<String, dynamic> json) {
    return Usage(
      promptTokens: json['prompt_tokens'],
      completionTokens: json['completion_tokens'],
      totalTokens: json['total_tokens'],
    );
  }
}