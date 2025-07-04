import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo.dart';
import 'todo_list.dart';

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

final currentTodo = Provider<Todo>(
  dependencies: const [],
  (ref) => throw UnimplementedError(),
);
