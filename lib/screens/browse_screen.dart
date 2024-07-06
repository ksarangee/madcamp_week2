import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({Key? key}) : super(key: key);

  @override
  BrowseScreenState createState() => BrowseScreenState();
}

class BrowseScreenState extends State<BrowseScreen> {
  static const String serverUrl = 'http://real-server';
  static const String serverPort = '80';
  static const String endpoint = '/posts';

  List<Document> _allDocuments = []; // 모든 문서를 저장할 리스트
  List<Document> _filteredDocuments = []; // 필터링된 문서를 저장할 리스트
  bool _isLoading = true;
  String _errorMessage = '';

  TextEditingController _searchController =
      TextEditingController(); //검색어 입력을 관리하는 컨트롤러
  bool _searchByTitle = true; // 제목으로 검색할지 여부를 나타내는 변수

  @override
  void initState() {
    super.initState();
    _fetchDocuments(); //문서 데이터를 서버에서 가져오는 메소드 호출
  }

  Future<void> _fetchDocuments() async {
    try {
      final response =
          await http.get(Uri.parse('$serverUrl:$serverPort$endpoint'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allDocuments = data.map((doc) => Document.fromJson(doc)).toList();
          _filteredDocuments = _allDocuments; //초기에는 모든 문서를 보여줌
          _isLoading = false; //데이터 로딩 완료
        });
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e'; //데이터 로딩 실패 시 에러 메시지 저장
        _isLoading = false; //데이터 로딩 완료
      });
    }
  }

  // 검색어를 기준으로 문서를 필터링하는 메소드
  void _filterDocuments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDocuments = _allDocuments; //검색어 없으면 모든 문서 보여줌
      } else {
        _filteredDocuments = _allDocuments.where((doc) {
          if (_searchByTitle) {
            //제목으로 검색할 경우
            return doc.title?.toLowerCase().contains(query.toLowerCase()) ??
                false;
          } else {
            //내용으로 검색할 경우
            return doc.content?.toLowerCase().contains(query.toLowerCase()) ??
                false;
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
            // Padding의 child로 Column을 사용
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: Icon(Icons.search),
                  ),
                  onChanged: _filterDocuments, //검색어 입력 변화 감지
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('제목'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _searchByTitle
                          ? Colors.brown[300]
                          : Colors.yellow[200],
                    ),
                    onPressed: () {
                      setState(() {
                        _searchByTitle = true;
                        _filterDocuments(_searchController.text); //제목으로 검색
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    child: Text('내용'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_searchByTitle
                          ? Colors.brown[300]
                          : Colors.yellow[200],
                    ),
                    onPressed: () {
                      setState(() {
                        _searchByTitle = false;
                        _filterDocuments(_searchController.text); //내용으로 검색
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: _buildDocumentList(), //문서 리스트 출력하는 위젯 호출
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 결과에 따라 문서 리스트를 생성하는 메소드
  Widget _buildDocumentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage)); //데이터 로딩 에러 메시지 출력
    } else if (_filteredDocuments.isEmpty) {
      return const Center(child: Text('No documents found')); //검색 결과 없음 메시지 출력
    } else {
      //검색 결과에 맞는 문서 리스트 출력
      return ListView.builder(
        itemCount: _filteredDocuments.length,
        itemBuilder: (context, index) {
          final document = _filteredDocuments[index];
          return ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(document.title ?? '',
                    style: const TextStyle(fontSize: 18.0)),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    Text('Created: ${document.createdAt}',
                        style: const TextStyle(fontSize: 14.0)),
                    Text('  Updated: ${document.updatedAt}',
                        style: const TextStyle(fontSize: 14.0)),
                  ],
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      DocumentDetailScreen(document: document), //문서 상세 화면으로 이동
                ),
              );
            },
          );
        },
      );
    }
  }
}

class Document {
  final int id;
  //final String userId;
  final int categoryId; // category_id 추가
  final String? title;
  final String? content;
  final String createdAt;
  final String updatedAt;

  Document({
    required this.id,
    //required this.userId,
    required this.categoryId,
    this.title,
    this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      //userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class DocumentDetailScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailScreen({Key? key, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title ?? ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(document.content ?? '',
                style: const TextStyle(fontSize: 18.0)),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text('Created at: ${document.createdAt}'),
                const Spacer(),
                Text('Updated at: ${document.updatedAt}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
