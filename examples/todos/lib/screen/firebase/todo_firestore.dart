import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../todo_provider.dart';
import 'todo_item_firestore.dart';
import '../../app_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../todo_firestore_repository.dart';
import '../../todo.dart';

class TodoFirestore extends HookConsumerWidget {
  const TodoFirestore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTodoController = useTextEditingController();
    final todosFuture = useState(TodoFirestoreRepository().fetchTodos());

    void reloadTodos() {
      todosFuture.value = TodoFirestoreRepository().fetchTodos();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Firestore'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: FutureBuilder<List<Todo>>(
          future: todosFuture.value,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // データ取得中はローディング表示
              return const Center(child: CircularProgressIndicator());
            }
            final todos = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              children: [
                // 入力欄と追加ボタン
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: addTodoKey,
                        controller: newTodoController,
                        decoration: const InputDecoration(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newTodo = newTodoController.text;
                        if (newTodo.isNotEmpty) {
                          await TodoFirestoreRepository().addTodo(newTodo);
                          newTodoController.clear();
                          reloadTodos(); // 追加後に再取得
                        }
                      },
                      child: const Icon(Icons.add, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Firestoreのデータでリストを作る
                for (var i = 0; i < todos.length; i++) ...[
                  if (i > 0) const Divider(height: 0),
                  Dismissible(
                    key: ValueKey(todos[i].todoId),
                    onDismissed: (_) async {
                      await TodoFirestoreRepository()
                          .deleteTodo(todos[i].todoId);
                      reloadTodos(); // 削除後に再取得
                    },
                    child: ProviderScope(
                      overrides: [
                        currentTodo.overrideWithValue(todos[i]),
                      ],
                      child: TodoItemFirestore(onReload: reloadTodos),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
