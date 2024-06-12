import 'package:course_app/database_local/base.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CourseListScreen(),
    );
  }
}

class CourseListScreen extends StatefulWidget {
  @override
  _CourseListScreenState createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late Future<List<Map<String, dynamic>>> _courses;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _refreshCourses();
  }

  void _refreshCourses() {
    setState(() {
      _courses = DatabaseHelper.instance.getAllCourses();
    });
  }

  void _addCourse() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCourseDialog(onSave: (course) {
          DatabaseHelper.instance.insertCourse(course);
          _refreshCourses();
        });
      },
    );
  }

  void _toggleView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _buyCourse(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Purchase'),
          content: Text('Are you sure you want to buy ${course['title']}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Buy'),
              onPressed: () {
                DatabaseHelper.instance.markCourseAsBought(course['id']);
                _refreshCourses();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addToFavorites(Map<String, dynamic> course) {
    DatabaseHelper.instance.markCourseAsFavorite(course['id']);
    _refreshCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: _toggleView,
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavoriteCoursesScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BoughtCoursesScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _courses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No courses found.'));
          }

          final courses = snapshot.data!;
          return _isGridView
              ? _buildGridView(courses)
              : _buildListView(courses);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> courses) {
    return ListView.builder(
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return ListTile(
          leading: _buildCourseImage(course['imageUrl']),
          title: Text(course['title']),
          subtitle: Text(course['description']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () => _addToFavorites(course),
              ),
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () => _buyCourse(course),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> courses) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseImage(course['imageUrl']),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  course['title'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(course['description']),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Price: \$${course['price']}'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite),
                    onPressed: () => _addToFavorites(course),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () => _buyCourse(course),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCourseImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 100,
        width: 100,
        color: Colors.grey,
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
    return Image.network(
      imageUrl,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          width: 100,
          color: Colors.grey,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
        );
      },
    );
  }
}

class AddCourseDialog extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSave;

  AddCourseDialog({required this.onSave});

  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _imageUrl = '';
  double _price = 0.0;
  final _imageController = TextEditingController();

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) {
                  setState(() {
                    _imageUrl = value;
                  });
                },
                onSaved: (value) => _imageUrl = value!,
              ),
              const SizedBox(height: 10),
              _buildImagePreview(),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave({
                'title': _title,
                'description': _description,
                'imageUrl': _imageUrl,
                'price': _price,
                'isBought': 0,
                'isFavorite': 0,
              });
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_imageUrl.isEmpty) {
      return Container(
        height: 100,
        width: 100,
        color: Colors.grey,
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
    return Image.network(
      _imageUrl,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          width: 100,
          color: Colors.grey,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
        );
      },
    );
  }
}

class BoughtCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bought Courses'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getBoughtCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bought courses found.'));
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: _buildCourseImage(course['imageUrl']),
                title: Text(course['title']),
                subtitle: Text(course['description']),
                trailing: Text('Price: \$${course['price']}'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 100,
        width: 100,
        color: Colors.grey,
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
    return Image.network(
      imageUrl,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          width: 100,
          color: Colors.grey,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
        );
      },
    );
  }
}

class FavoriteCoursesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Courses'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.getFavoriteCourses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite courses found.'));
          }

          final courses = snapshot.data!;
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                leading: _buildCourseImage(course['imageUrl']),
                title: Text(course['title']),
                subtitle: Text(course['description']),
                trailing: Text('Price: \$${course['price']}'),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        height: 100,
        width: 100,
        color: Colors.grey,
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
    return Image.network(
      imageUrl,
      height: 100,
      width: 100,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 100,
          width: 100,
          color: Colors.grey,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.white),
        );
      },
    );
  }
}
