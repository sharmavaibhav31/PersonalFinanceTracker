import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatProvider with ChangeNotifier {
  static const String userRole = 'user';
  static const String botRole = 'bot';

  List<Map<String, String>> messages = [];

  Future<void> sendMessage(String userMessage) async {
    messages.add({'role': userRole, 'content': userMessage});
    notifyListeners();

    final apiKey = dotenv.env['AI_API_KEY']; // ✅ API key from .env
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    ); // ✅ Replace with actual API URL


    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // ✅ API key in header
        },
        body: json.encode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final aiResponse = json.decode(response.body)['response'];
        messages.add({'role': botRole, 'content': aiResponse});
      } else {
        messages.add({
          'role': botRole,
          'content': 'Sorry, something went wrong. (${response.statusCode})'
        });
      }
    } catch (e) {
      messages.add({'role': botRole, 'content': 'Error contacting AI.'});
    }

    notifyListeners();
  }
}
