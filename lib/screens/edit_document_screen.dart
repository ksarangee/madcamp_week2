import 'package:flutter/material.dart';
import '../models/document.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import './../secret.dart';
import 'dart:io';

class EditDocumentScreen extends StatefulWidget {
  final Document document;

  const EditDocumentScreen({Key? key, required this.document})
      : super(key: key);

  @override
  _EditDocumentScreenState createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _imageUrlController;
  String? _selectedCategory;
  bool _isLoading = false;
  String _errorMessage = '';
  File? _image;

  final List<String> _categories = ['역사', '개발', '엔터테인먼트', '음식', '일상', '예술'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.document.title);
    _contentController = TextEditingController(text: widget.document.content);
    _imageUrlController =
        TextEditingController(text: widget.document.imageUrl ?? '');
    _selectedCategory =
        _categories[widget.document.categoryId]; // 기존 카테고리를 초기값으로 설정
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        print('Picked image path: ${_image!.path}');
      });
    }
  }

  void _showImageUrlDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image URL'),
          content: TextField(
            controller: _imageUrlController,
            decoration: InputDecoration(hintText: "Image URL (선택)"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveDocument() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 카테고리 ID를 디버깅합니다.
      int categoryId = _selectedCategory != null
          ? _categories.indexOf(_selectedCategory!) + 1
          : widget.document.categoryId;
      print('Selected Category: $_selectedCategory');
      print('Category ID: $categoryId');

      var request = http.MultipartRequest(
          'PUT', Uri.parse('$backendUrl/edit_post/${widget.document.id}'));
      request.fields['title'] = _titleController.text;
      request.fields['content'] = _contentController.text;
      request.fields['category_id'] = categoryId.toString();

      if (_image != null) {
        print('Adding image to request: ${_image!.path}');
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      } else if (_imageUrlController.text.isNotEmpty) {
        print('Adding image URL to request: ${_imageUrlController.text}');
        request.fields['image_url'] = _imageUrlController.text;
      }

      // Ensure total_views and today_views are included and not null
      request.fields['today_views'] =
          (widget.document.todayViews ?? 0).toString();

      final response = await request.send();

      print('Server Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final updatedDocument = Document.fromJson(jsonDecode(responseData));

        Navigator.pop(context, updatedDocument); // 성공 시 한 번만 pop 호출
      } else {
        setState(() {
          _errorMessage = 'Failed to update document';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update document. Please try again.')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating document: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('글 수정하기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _selectedCategory != null && !_isLoading ? _saveDocument : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            hint: Align(
                              alignment: Alignment.center,
                              child: const Text('분야 선택'),
                            ),
                            dropdownColor: Colors.white,
                            items: _categories
                                .map((category) => DropdownMenuItem(
                                      value: category,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(category),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: '제목',
                        labelStyle: TextStyle(fontSize: 18),
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: '내용을 적어주세요!',
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      maxLines: 25,
                      keyboardType: TextInputType.multiline,
                    ),
                    if (_image != null) Image.file(_image!),
                    if (_isLoading) const CircularProgressIndicator(),
                    if (_errorMessage.isNotEmpty)
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 15,
              bottom: 4,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.link),
                    onPressed: _showImageUrlDialog,
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: _pickImage,
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
