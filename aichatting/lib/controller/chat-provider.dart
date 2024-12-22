import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  final String apiKey = 'AIzaSyDGztwO2CTnBNJh04T4EHAxNCxlBPocWCU'; // Replace with your actual API key
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  /// Sends a text message to the Google Gemini API and handles the response.
  Future<void> sendMessages({required String userMessage}) async {
    // Add the user's message to the messages list
    _messages.add({
      "role": "user",
      "message": userMessage,
      "isImage": false,
    });
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$apiKey'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": userMessage}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the bot's reply
        String botReply = "";

        // Check if the response contains the 'candidates' field
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          // Extract the 'text' from the first candidate's 'content' parts
          botReply = data['candidates'][0]['content']['parts'][0]['text'] ?? "I don't have an answer.";
        } else {
          botReply = "No response from the model.";
        }

        print("Bot Reply: $botReply");
        // Add the bot's reply to the messages list
        _messages.add({
          "role": "bot",
          "message": botReply,
          "isImage": false,
        });
      } else {
        print('Error: ${response.body}');
        _messages.add({
          "role": "bot",
          "message": "Failed to reply: ${response.statusCode}",
          "isImage": false,
        });
      }
    } catch (e) {
      print('Exception: $e');
      _messages.add({
        "role": "bot",
        "message": "An error occurred. Please try again.",
        "isImage": false,
      });
    }

    notifyListeners();
  }

  /// Sends an image to the Google Gemini API and handles the response.
  Future<void> sendImage(File image) async {
    _messages.add({
      "role": "user",
      "message": "You sent an image.",
      "isImage": true,
      "image": image,
    });
    notifyListeners();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/models/gemini-1.5-flash:generateContent?key=$apiKey'),
      );
      request.headers['Authorization'] = "Bearer $apiKey";
      request.headers['Content-Type'] = "application/json";

      // Send the image as a base64 string
      final imageBytes = await image.readAsBytes();
      request.fields['contents'] = jsonEncode({
        "contents": [
          {
            "parts": [
              {"imageData": base64Encode(imageBytes)}
            ]
          }
        ]
      });

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String botReply = data['contents']?[0]?['parts']?[0]?['text'] ?? "I can't reply to this image.";

        _messages.add({
          "role": "bot",
          "message": botReply,
          "isImage": false,
        });
      } else {
        print('Error: ${response.body}');
        _messages.add({
          "role": "bot",
          "message": "Failed to reply to image: ${response.statusCode}",
          "isImage": false,
        });
      }
    } catch (e) {
      print('Exception: $e');
      _messages.add({
        "role": "bot",
        "message": "An error occurred while sending the image.",
        "isImage": false,
      });
    }

    notifyListeners();
  }
}
