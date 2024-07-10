import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import './../secret.dart';
import 'dart:io';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  String _errorMessage = '';
  File? _image;

  final List<String> _categories = ['역사', '개발', '엔터테인먼트', '음식', '일상', '예술'];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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

  Future<void> _submitPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$backendUrl/create_post'));
      request.fields['title'] = _titleController.text;
      request.fields['content'] = _contentController.text;
      request.fields['category_id'] =
          (_categories.indexOf(_selectedCategory!) + 1).toString();

      if (_image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', _image!.path));
      } else if (_imageUrlController.text.isNotEmpty) {
        request.fields['image_url'] = _imageUrlController.text;
      }

      final response = await request.send();

      print('Server Response: ${response.statusCode}');
      if (response.statusCode == 200) {
        Navigator.pop(
            context, true); // Return to the previous screen with success flag
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
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
        title: const Text('글 등록하기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _selectedCategory != null && !_isLoading ? _submitPost : null,
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
