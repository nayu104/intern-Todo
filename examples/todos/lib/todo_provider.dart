import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'todo.dart';
import 'todo_list.dart';
import 'todo_firestore_repository.dart';

final todoListProvider = NotifierProvider<TodoList, List<Todo>>(TodoList.new);

final todoFirestoreRepositoryProvider =
    Provider((ref) => TodoFirestoreRepository());

final currentTodo = Provider<Todo>(
  // これがあるとprops（引数）でデータを渡す「バケツリレー」をしなくてよくなる
// ProviderScopeでoverrideして使う（ここは仮置き。実際の値はoverrideで注入）
  dependencies: const [],
  (ref) => throw UnimplementedError(), //override して使う（つまり 仮置き）
);
