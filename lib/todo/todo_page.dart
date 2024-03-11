import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo/ThemeSwitch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _editingDocumentId = ''; // To track the document being edited

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProviderNotifier>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Todo Page'),
            backgroundColor: themeProvider.themeMode == ThemeMode.dark
                ? Colors.grey[700] // Dark theme background color
                : Colors.blue, // Light theme background color
          ),
          body: StreamBuilder(
            stream: getTodos(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No todos found.'),
                );
              }

              return Container(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? Colors.grey[900]
                    : Colors.white,
                child: ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: GestureDetector(
                        onTap: () {
                          _titleController.text = data['title'];
                          _descriptionController.text = data['description'];
                          _editingDocumentId = document.id;

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Todo Details'),
                              content: SingleChildScrollView(
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Title: ${data['title']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Description: ${data['description']}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly, // Adjust the alignment as needed
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _openEditDialog(
                                            data['title'], data['description']);
                                      },
                                      child: const Text('Edit'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _confirmDelete(
                                            data['title'], data['description']);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          child: Card(
                            child: ListTile(
                              title: Text(
                                data['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 20),
                              ),
                              subtitle: Text(
                                data['description'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 18),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height * 0.50,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add Todo',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                        ),
                        const SizedBox(height: 16.0),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                        ),
                        const SizedBox(height: 60.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () {
                                _addTodo();
                                Navigator.pop(context);
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _openEditDialog(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.50,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Todo',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 60.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _updateTodo();
                      Navigator.pop(context);
                    },
                    child: const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTodo() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        await _firestore.collection('todos').doc(_editingDocumentId).update({
          'uid': uid,
          'title': _titleController.text,
          'description': _descriptionController.text,
        });

        _titleController.clear();
        _descriptionController.clear();
        _editingDocumentId = '';

        _showMessage('Todo updated successfully');
      }
    } catch (e) {
      _showMessage('Error updating todo: $e');
    }
  }

  void _confirmDelete(String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to delete the following todo?'),
            const SizedBox(height: 8),
            Text('Title: $title',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Description: $description'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTodo();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTodo() async {
    try {
      await _firestore.collection('todos').doc(_editingDocumentId).delete();
      _showMessage('Todo deleted successfully');
      _editingDocumentId = '';
    } catch (e) {
      _showMessage('Error deleting todo: $e');
    }
  }

  void _addTodo() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        String uid = user.uid;

        await _firestore.collection('todos').add({
          'uid': uid,
          'title': _titleController.text,
          'description': _descriptionController.text,
        });

        _titleController.clear();
        _descriptionController.clear();

        _showMessage('Todo added successfully');
      }
    } catch (e) {
      _showMessage('Error adding todo: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Stream<QuerySnapshot> getTodos() {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      return _firestore
          .collection('todos')
          .where('uid', isEqualTo: uid)
          .snapshots();
    }

    return const Stream.empty();
  }
}
