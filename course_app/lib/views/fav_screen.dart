import 'package:flutter/material.dart';
import 'package:course_app/services/services.dart';

class FavoritesPage extends StatelessWidget {
  final CourseService _courseService = CourseService();

  @override
  Widget build(BuildContext context) {
    final favoriteCourses = _courseService.getFavoriteCourses();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sevimli Kurslar'),
      ),
      body: favoriteCourses.isEmpty
          ? Center(child: Text('Sevimli kurslar yo\'q'))
          : ListView.builder(
              itemCount: favoriteCourses.length,
              itemBuilder: (context, index) {
                final course = favoriteCourses[index];
                return ListTile(
                  leading: Image.network(
                    course.imageUrl,
                    fit: BoxFit.cover,
                    height: 50,
                    width: 50,
                  ),
                  title: Text(course.title),
                  subtitle: Text(course.description),
                );
              },
            ),
    );
  }
}
