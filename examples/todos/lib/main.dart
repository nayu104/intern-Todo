import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo_list.dart';
import 'todo.dart';

/// Some keys used for testing
final addTodoKey = UniqueKey();

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends HookConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final newTodoController = useTextEditingController();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                    decoration: const InputDecoration(
                        ),
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
                child: ProviderScope(
                  overrides: [
                    _currentTodo.overrideWithValue(todos[i]),
                  ],
                  child: const TodoItem(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


final _currentTodo = Provider<Todo>(
  dependencies: const [],
      (ref) => throw UnimplementedError(),
);

class TodoItem extends HookConsumerWidget {
  const TodoItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(_currentTodo);
    final itemFocusNode = useFocusNode();
    final itemIsFocused = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) {
          if (focused) {
            textEditingController.text = todo.description;
          } else {
            ref
                .read(todoListProvider.notifier)
                .edit(id: todo.id, description: textEditingController.text);
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          trailing: Checkbox(
            value: todo.completed,
            onChanged: (value) =>
                ref.read(todoListProvider.notifier).toggle(todo.id),
          ),
          title: itemIsFocused
              ? TextField(
            autofocus: true,
            focusNode: textFieldFocusNode,
            controller: textEditingController,
          )
          //　年月日を「2025年06月28日」のように0埋めして表示
              :Column(
            crossAxisAlignment: CrossAxisAlignment.start, //  左寄せ
            children: [
              Text(todo.description),
              SizedBox(height: 5),
              Row( //　Rowを使う理由：月日と時刻の間に横スペース（SizedBox）を設けたいため。
                children: [
              Text('${todo.createdAt.year}年'
                  '${todo.createdAt.month.toString().padLeft(2, '0')}月'
                  '${todo.createdAt.day.toString().padLeft(2, '0')}日',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(width: 5),
              Text('${todo.createdAt.hour.toString().padLeft(2, '0')}'
                  ':'
                  '${todo.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 13),
              ),
            ],
              ),
            ],
          ),

        ),
      ),
    );
  }
}

// TextField などが選択されているかどうかの判定に使う。編集モード or テキストモードの切り替え
bool useIsFocused(FocusNode node) {
  final isFocused = useState(node.hasFocus);

  useEffect(
    () {
      void listener() {
        isFocused.value = node.hasFocus;
      }

      node.addListener(listener);
      return () => node.removeListener(listener);
    },
    [node],
  );

  return isFocused.value;
}
