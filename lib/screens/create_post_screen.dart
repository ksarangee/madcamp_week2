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
        title: const Text('Create Post'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _selectedCategory != null && !_isLoading ? _submitPost : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            // 추가된 부분
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  dropdownColor: Colors.white,
                  items: _categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                TextField(
                  controller: _imageUrlController,
                  decoration:
                      const InputDecoration(labelText: 'Image URL (optional)'),
                ),
                if (_image != null) Image.file(_image!),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                if (_isLoading) const CircularProgressIndicator(),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage,
                      style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
