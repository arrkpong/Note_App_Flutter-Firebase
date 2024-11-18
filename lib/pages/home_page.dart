//lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../../models/note.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? selectedCategory;
  List<String> filterCategory = ['Work', 'Personal', 'Study', 'Other'];

  final logger = Logger();

  Query _noteQuery() {
    final user = FirebaseAuth.instance.currentUser;
    CollectionReference notesRef =
        _firestore.collection('users').doc(user!.uid).collection('notes');

    if (selectedCategory != null && selectedCategory != 'All') {
      return notesRef.where('category', isEqualTo: selectedCategory);
    } else {
      return notesRef;
    }
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [...filterCategory, 'All'].map((category) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedCategory = category == 'All' ? null : category;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: category == selectedCategory ||
                    (category == 'All' && selectedCategory == null)
                ? Colors.amber
                : null,
          ),
          child: Text(category),
        );
      }).toList(),
    );
  }

  void _addNote() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String content = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCategoryButtonsDialog(setState), // Updated method name
                  TextField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: 'Content'),
                    onChanged: (value) {
                      content = value;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    await _firestore
                        .collection('users')
                        .doc(user!.uid)
                        .collection('notes')
                        .add({
                      'title': title,
                      'content': content,
                      'category': selectedCategory ?? '',
                    });
                    Navigator.pop(
                      context,
                      Note(
                        title: title,
                        content: content,
                        category: selectedCategory ?? '',
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {}
  }

  Widget _buildCategoryButtonsDialog(Function setState) {
    // Renamed method
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [...filterCategory, 'All'].map((category) {
        return ElevatedButton(
          onPressed: () {
            setState(() {
              selectedCategory = category == 'All' ? null : category;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: category == selectedCategory ||
                    (category == 'All' && selectedCategory == null)
                ? Colors.amber
                : null,
          ),
          child: Text(category),
        );
      }).toList(),
    );
  }

  void _removeNote(String noteId) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }

  void _showNoteDetails(String title, String content, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Content: $content'),
              const SizedBox(height: 8),
              Text('Category: $category'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(String noteId, String currentTitle, String currentContent,
      String category) async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = currentTitle;
        String content = currentContent;

        return AlertDialog(
          title: const Text('Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                items: [...filterCategory, 'All'].map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    category = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: TextEditingController(text: title),
                onChanged: (value) {
                  title = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Content'),
                controller: TextEditingController(text: content),
                onChanged: (value) {
                  content = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                await _firestore
                    .collection('users')
                    .doc(user!.uid)
                    .collection('notes')
                    .doc(noteId)
                    .update({
                  'title': title,
                  'content': content,
                  'category': category,
                });
                Navigator.pop(context,
                    Note(title: title, content: content, category: category));
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Note App')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _confirmLogout();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCategoryButtons(),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _noteQuery().snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final title = doc['title'];
                    final content = doc['content'];
                    final category = doc['category'];
                    final noteId = doc.id;

                    return _buildNoteItem(title, content, category, noteId);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNote();
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNoteItem(
      String title, String content, String category, String noteId) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => _showNoteDetails(title, content, category),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Title: $title',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              Text(
                'Category: $category',
              ),
              const Divider(),
              Text(
                'Content: $content',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _confirmDelete(context, noteId);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editNote(noteId, title, content, category);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String noteId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeNote(noteId);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
