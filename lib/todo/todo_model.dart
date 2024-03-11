
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String title;
  final String description;

  Todo({required this.title, required this.description});
}

class TodoService {
  final CollectionReference todosCollection =
      FirebaseFirestore.instance.collection('todos');

  Future<void> addTodo(String userId, Todo todo) async {
    await todosCollection.doc(userId).collection('userTodos').add({
      'title': todo.title,
      'description': todo.description,
    });
  }

  Stream<List<Todo>> getUserTodos(String userId) {
    return todosCollection
        .doc(userId)
        .collection('userTodos')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Todo(
          title: data['title'],
          description: data['description'],
        );
      }).toList();
    });
  }
}
