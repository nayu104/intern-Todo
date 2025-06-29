import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo_list.dart';
import 'todo.dart';

/// Some keys used for testing
final addTodoKey = UniqueKey();
final activeFilterKey = UniqueKey();
final completedFilterKey = UniqueKey();
final allFilterKey = UniqueKey();

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

enum TodoListFilter {
  all,
  active,
  completed,
}

final todoListFilter = StateProvider((_) => TodoListFilter.all);

final uncompletedTodosCount = Provider<int>((ref) {
  return ref.watch(todoListProvider).where((todo) => !todo.completed).length;
});

final filteredTodos = Provider<List<Todo>>((ref) {
  final filter = ref.watch(todoListFilter);
  final todos = ref.watch(todoListProvider);

  switch (filter) {
    case TodoListFilter.completed:
      return todos.where((todo) => todo.completed).toList();
    case TodoListFilter.active:
      return todos.where((todo) => !todo.completed).toList();
    case TodoListFilter.all:
      return todos;
  }
});

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
    final todos = ref.watch(filteredTodos);
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

          // 年月日を「2025年06月28日」のように0埋めして表示
          //TODO: 条件分岐を「.padLeft(2, '0')」に書き換える & 年月日の文字を小さくする。
          //TODO: 提案「descriptionと年月日をColumnで並べて、年月日だけstyleを変更する」
          //TODO: 「時間」と「日」の間に空白を置く
              : Text('${todo.description}\n'
              '${todo.createdAt.year}年'
              '${todo.createdAt.month < 10 ? '0${todo.createdAt.month}' : todo.createdAt.month}月'
              '${todo.createdAt.day < 10 ? '0${todo.createdAt.day}' : todo.createdAt.day}日'
              '${todo.createdAt.hour < 10 ? '0${todo.createdAt.hour}' : todo.createdAt.hour}'
              ':'
              '${todo.createdAt.minute < 10 ? '0${todo.createdAt.minute}' : todo.createdAt.minute}'
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
