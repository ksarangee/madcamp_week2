import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/document.dart';
import '../screens/document_detail_screen.dart';
import '../secret.dart'; // 백엔드 URL 등의 민감 정보

class RandomService {
  static Future<Document?> getRandomDocument() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/posts'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          var randomIndex = DateTime.now().millisecondsSinceEpoch % data.length;
          Map<String, dynamic> randomDocumentData = data[randomIndex];
          return Document.fromJson(randomDocumentData);
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  static Future<void> performAction(BuildContext context) async {
    Document? document = await getRandomDocument();
    if (document != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentDetailScreen(document: document),
        ),
      );
    } else {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load random document')),
      );
    }
  }
}
