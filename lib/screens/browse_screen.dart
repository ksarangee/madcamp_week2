import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './../secret.dart';
import '../models/document.dart';
import 'document_detail_screen.dart';
import 'create_post_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  BrowseScreenState createState() => BrowseScreenState();
}

class BrowseScreenState extends State<BrowseScreen> {
  static const String serverPort = '80'; // 서버 포트 번호
  static const String endpoint = '/posts'; // 서버 엔드포인트 경로

  List<Document> _allDocuments = []; // 모든 문서를 저장할 리스트
  List<Document> _filteredDocuments = []; // 필터링된 문서를 저장할 리스트
  bool _isLoading = true;
  String _errorMessage = '';

  TextEditingController _searchController =
      TextEditingController(); // 검색어 입력을 관리하는 컨트롤러
  bool _searchByTitle = true; // 제목으로 검색할지 여부를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _fetchDocuments(); // 문서 데이터를 서버에서 가져오는 메소드 호출
  }

  Future<void> _fetchDocuments() async {
    try {
      final response =
          await http.get(Uri.parse('$backendUrl:$serverPort$endpoint'));

      print('Server Response: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // mounted 체크 추가
        if (mounted) {
          setState(() {
            _allDocuments = data.map((doc) => Document.fromJson(doc)).toList();
            _filteredDocuments = _allDocuments; // 초기에는 모든 문서를 보여줌
            _isLoading = false; // 데이터 로딩 완료
          });
        }
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print('Error: $e');
      // 에러 처리 로직 추가
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  // 검색어를 기준으로 문서를 필터링하는 메소드
  void _filterDocuments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = _allDocuments; // 검색어 없으면 모든 문서 보여줌
      } else {
        _filteredDocuments = _allDocuments.where((doc) {
          if (_searchByTitle) {
            // 제목으로 검색할 경우
            return doc.title.toLowerCase().contains(query.toLowerCase());
          } else {
            // 내용으로 검색할 경우
            return doc.content != true &&
                doc.content.toLowerCase().contains(query.toLowerCase());
          }
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filterDocuments, // 검색어 입력 변화 감지
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text(
                      '제목',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _searchByTitle
                          ? Colors.brown[300]
                          : Colors.yellow[100],
                    ),
                    onPressed: () {
                      setState(() {
                        _searchByTitle = true;
                        _filterDocuments(_searchController.text); // 제목으로 검색
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    child: Text(
                      '내용',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_searchByTitle
                          ? Colors.brown[300]
                          : Colors.yellow[100],
                    ),
                    onPressed: () {
                      setState(() {
                        _searchByTitle = false;
                        _filterDocuments(_searchController.text); // 내용으로 검색
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: _buildDocumentList(), // 문서 리스트 출력하는 위젯 호출
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
          if (result == true) {
            _fetchDocuments(); // 새 글 등록 후 문서 데이터 다시 가져오기
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDocumentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_filteredDocuments.isEmpty) {
      return const Center(child: Text('No documents found.'));
    }

    return ListView.builder(
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        Document document = _filteredDocuments[index];
        return ListTile(
          title: Text(document.title),
          subtitle: Text(document.content),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DocumentDetailScreen(document: document),
              ),
            );
          },
        );
      },
    );
  }
}
