import 'package:hooks_riverpod/hooks_riverpod.dart'; //state,Notifierが使える
import 'package:uuid/uuid.dart';
import 'todo.dart';

const _uuid = Uuid();

class TodoList extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => [];

  void add(String title) {
    //スプレッド演算子.state（＝すでにあるTo doのリスト）をそのままキープしたまま、新しいTo doを1個追加して、新しいリストとして更新する
    state = [
      ...state,
      Todo(
        todoId: _uuid.v4(),
        title: title,
        isCompleted: false,
        createdAt: DateTime.now(),
      ),
    ];
  }

  //チェック切り替え
  void toggle(String todoId) {
    state = [
      for (final todo in state)
        if (todo.todoId == todoId)
          todo.copyWith(isCompleted: !todo.isCompleted)
        else
          todo,
    ];
  }

  //title（内容）だけを編集
  void edit({required String id, required String title}) {
    state = [
      for (final todo in state)
        if (todo.todoId == id)
          todo.copyWith(title: title, isCompleted: todo.isCompleted)
        else
          todo,
    ];
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.todoId != target.todoId).toList();
  }
}
