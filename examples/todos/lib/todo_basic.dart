import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo_provider.dart';
import 'todo_item.dart';
import 'app_keys.dart';

class TodoBasic extends HookConsumerWidget {
  const TodoBasic({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          children: [
            Expanded(
                child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: addTodoKey,
                    controller: newTodoController,
                    decoration: const InputDecoration(),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      final newTodo = newTodoController.text;
                      ref.read(todoListProvider.notifier).add(newTodo);
                      newTodoController.clear();
                    },
                    child: Icon(Icons.add, color: Colors.black))
                // ここに他のボタンなどを追加したい場合は続けて書く
              ],
            )),
            const SizedBox(height: 20),
            for (var i = 0; i < todos.length; i++) ...[
              if (i > 0) const Divider(height: 0),
              Dismissible(
                key: ValueKey(todos[i].id),
                onDismissed: (_) {
                  ref.read(todoListProvider.notifier).remove(todos[i]);
                },
                //（引数）で渡す代わりに、Provider（currentTodo）を使ってTodoItemにデータを渡している
                child: ProviderScope(
                  overrides: [
                    currentTodo.overrideWithValue(todos[i]),
                  ],
                  child: const TodoItem(), //実際の表示・UIはTodoItemが担当
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
