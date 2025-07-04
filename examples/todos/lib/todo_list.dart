import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'todo.dart';

const _uuid = Uuid();

class TodoList extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => [];

  void add(String description) {
    //スプレッド演算子.state（＝すでにあるTo doのリスト）をそのままキープしたまま、新しいTo doを1個追加して、新しいリストとして更新する
    state = [
      ...state,
      Todo(
        id: _uuid.v4(),
        description: description,
        createdAt: DateTime.now(),
      ),
    ];
  }

  //チェック切り替え
  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(completed: !todo.completed) else todo,
    ];
  }

  //description（内容）だけを編集
  void edit({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id) todo.copyWith(description: description) else todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
  }
}
