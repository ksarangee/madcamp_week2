import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../widgets/trend_custom_button.dart';
import '../widgets/interest_custom_button.dart';
import '../widgets/todaytext_custom_button.dart';
import '../widgets/randomtext_custom_button.dart';
import '../secret.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/document.dart';
import '../screens/document_detail_screen.dart';
import '../screens/interest_posts_screen.dart';
import '../screens/trend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Document? fixedDocument;
  Document? randomDocument;
  String fixedDocumentTitle = 'Loading...';
  String randomDocumentTitle = 'Loading...';
  final List<Map<String, String>> quotes = [
    {'quote': '"우리는 그 어떤 것에 대해서\n1억 분의 1도 모른다."', 'author': '- 토마스 에디슨'},
    {'quote': '"쓸데 없는 지식에서도\n큰 기쁨을 얻을 수 있다."', 'author': '- 버트런드 러셀'},
    {'quote': '"아는 것이 힘이다."', 'author': '- 프랜시스 베이컨'},
  ];

  int currentQuoteIndex = 0;
  bool isVisible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startQuoteAnimation();
    _loadFixedDocumentTitle();
    _loadRandomDocumentTitle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startQuoteAnimation() {
    _timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          isVisible = false;
        });

        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              currentQuoteIndex = (currentQuoteIndex + 1) % quotes.length;
              isVisible = true;
            });
          }
        });
      }
    });
  }

  Future<void> _loadFixedDocumentTitle() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().split(' ')[0];
    final lastFetchDate = prefs.getString('lastFetchDate');

    if (lastFetchDate != today || !prefs.containsKey('fixedDocumentId')) {
      try {
        final response = await http.get(Uri.parse('$backendUrl/posts'));

        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            var randomIndex =
                DateTime.now().millisecondsSinceEpoch % data.length;
            Map<String, dynamic> fixedDocumentData = data[randomIndex];
            fixedDocument = Document.fromJson(fixedDocumentData);
            setState(() {
              fixedDocumentTitle = fixedDocument!.title;
            });
            prefs.setString('fixedDocumentId', fixedDocument!.id.toString());
            prefs.setString('fixedDocumentTitle', fixedDocumentTitle);
            prefs.setString('lastFetchDate', today);
          } else {
            throw Exception('No documents available');
          }
        } else {
          throw Exception('Failed to load documents');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      setState(() {
        fixedDocumentTitle =
            prefs.getString('fixedDocumentTitle') ?? 'No Title';
      });
    }
  }

  Future<void> _loadRandomDocumentTitle() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/posts'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          var randomIndex = DateTime.now().millisecondsSinceEpoch % data.length;
          Map<String, dynamic> randomDocumentData = data[randomIndex];
          setState(() {
            randomDocument = Document.fromJson(randomDocumentData);
            randomDocumentTitle = randomDocument!.title;
          });
        } else {
          throw Exception('No documents available');
        }
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchFixedDocument() async {
    final prefs = await SharedPreferences.getInstance();
    final fixedDocumentId = prefs.getString('fixedDocumentId');

    if (fixedDocumentId != null) {
      try {
        final response =
            await http.get(Uri.parse('$backendUrl/posts/$fixedDocumentId'));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          fixedDocument = Document.fromJson(data);
          setState(() {
            fixedDocumentTitle = fixedDocument!.title;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DocumentDetailScreen(document: fixedDocument!),
            ),
          );
        } else {
          throw Exception('Failed to load fixed document');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No fixed document ID saved');
    }
  }

  Future<void> _fetchRandomDocument() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/posts'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          var randomIndex = DateTime.now().millisecondsSinceEpoch % data.length;
          Map<String, dynamic> randomDocumentData = data[randomIndex];
          setState(() {
            randomDocument = Document.fromJson(randomDocumentData);
            randomDocumentTitle = randomDocument!.title;
          });
        } else {
          throw Exception('No documents available');
        }
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color(0xFFFFF6E9),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    child: AnimatedOpacity(
                      opacity: isVisible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 500),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            quotes[currentQuoteIndex]['quote']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            quotes[currentQuoteIndex]['author']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        TrendCustomButton(
                          text: 'Trending\nPosts',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrendScreen(),
                              ),
                            );
                          },
                        ),
                        InterestCustomButton(
                          text: 'My\nInterests',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InterestPostsScreen(),
                              ),
                            );
                          },
                        ),
                        TodaytextCustomButton(
                          text: 'Today\'s Text \n $fixedDocumentTitle',
                          onPressed: () => _fetchFixedDocument(),
                        ),
                        RandomtextCustomButton(
                          text: randomDocumentTitle,
                          onPressed: () {
                            if (randomDocument != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentDetailScreen(
                                    document: randomDocument!,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: Icons.refresh,
                          iconOnPressed: _fetchRandomDocument,
                        ),
                      ],
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
}
