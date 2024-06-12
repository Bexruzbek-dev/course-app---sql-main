// add_course.dart

import 'package:course_app/model/model.dart';
import 'package:flutter/material.dart';
import '../../services/services.dart';

class AddCoursePage extends StatefulWidget {
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _imageUrl = '';
  double _price = 0.0;
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yangi Kurs Qo\'shish'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Kurs nomi'),
                onSaved: (value) {
                  _title = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, kurs nomini kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Tavsif'),
                onSaved: (value) {
                  _description = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, tavsif kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Rasm URL'),
                onSaved: (value) {
                  _imageUrl = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, rasm URL kiriting';
                  }
                  // Basic URL validation
                  if (!Uri.parse(value).isAbsolute) {
                    return 'Iltimos, to\'g\'ri URL kiriting';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Narx'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _price = double.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Iltimos, narx kiriting';
                  }
                  // Validate if the input is a valid double
                  if (double.tryParse(value) == null) {
                    return 'Iltimos, to\'g\'ri raqam kiriting';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCourse,
                child: Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newCourse = Course(
        title: _title,
        description: _description,
        imageUrl: _imageUrl,
        price: _price,
        id: '',
      );

      try {
        // Show a loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        await _courseService.addCourse(newCourse);

        // Close the loading indicator
        Navigator.of(context).pop();

        // Go back to the previous screen with a success response
        Navigator.pop(context, true);
      } catch (e) {
        // Close the loading indicator
        Navigator.of(context).pop();

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kursni qo\'shishda xatolik yuz berdi: $e')),
        );
      }
    }
  }
}

// course_list.dart
