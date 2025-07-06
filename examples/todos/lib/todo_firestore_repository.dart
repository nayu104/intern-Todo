import 'package:cloud_firestore/cloud_firestore.dart';
import 'todo.dart';

class TodoFirestoreRepository {
  final _collection = FirebaseFirestore.instance.collection('todos');

  Future<void> addTodo(String title) async {
    final docRef = _collection.doc(); // doc() に何も渡さなければ、ランダムな ID が自動生成される
    final todo = Todo(
      todoId: docRef.id,
      title: title,
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    await docRef.set(todo.toJson());
  }

  Future<void> deleteTodo(String todoId) async {
    await _collection.doc(todoId).delete();
  }

  //クラウドに保存されているTodoを全部取り出す関数
  Future<List<Todo>> fetchTodos() async {
    final snapshot = await _collection.get();
    return snapshot.docs.map((doc) => Todo.fromJson(doc.data())).toList();
  }

//checkマークを更新
  Future<void> updateIsCompleted(String todoId, bool isCompleted) async {
    await _collection.doc(todoId).update({'isCompleted': isCompleted});
  }

//todoの内容を更新
  Future<void> updateTitle(String todoId, String newTitle) async {
    await _collection.doc(todoId).update({'title': newTitle});
  }
}
