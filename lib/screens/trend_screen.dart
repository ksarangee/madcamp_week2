import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/document.dart';
import 'document_detail_screen.dart';
import '../secret.dart';

class TrendScreen extends StatefulWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  _TrendScreenState createState() => _TrendScreenState();
}

class _TrendScreenState extends State<TrendScreen> {
  List<Document> _documents = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final int _maxDocuments = 10; //최대 볼 수 있는 문서 수 정의

  @override
  void initState() {
    super.initState();
    _fetchTrendingDocuments();
  }

  Future<void> _fetchTrendingDocuments() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/posts'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Document> documents =
            data.map((doc) => Document.fromJson(doc)).toList();

        // Sort documents by todayViews in descending order
        documents.sort((a, b) => (b.todayViews ?? 0).compareTo(a.todayViews ?? 0));

        //트렌드 글 10개만 보여주기
        documents = documents.take(_maxDocuments).toList();

        setState(() {
          _documents = documents;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trending Posts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    Document document = _documents[index];
                    return ListTile(
                      title: Text(document.title),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DocumentDetailScreen(document: document),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
