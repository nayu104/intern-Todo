import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../todo_provider.dart';
import '../../use_is_focused.dart';
import '../../todo_firestore_repository.dart';

class TodoItemFirestore extends HookConsumerWidget {
  final void Function() onReload;
  const TodoItemFirestore({super.key, required this.onReload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todo = ref.watch(currentTodo);
    final itemFocusNode = useFocusNode();
    final itemIsFocused = useIsFocused(itemFocusNode);

    final textEditingController = useTextEditingController();
    final textFieldFocusNode = useFocusNode();

    return Material(
      child: Focus(
        focusNode: itemFocusNode,
        onFocusChange: (focused) async {
          if (focused) {
            textEditingController.text = todo.title;
          } else {
            await ref.read(todoFirestoreRepositoryProvider).updateTitle(
                  todo.todoId,
                  textEditingController.text,
                );
            onReload();
          }
        },
        child: ListTile(
          onTap: () {
            itemFocusNode.requestFocus();
            textFieldFocusNode.requestFocus();
          },
          trailing: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) async {
                await ref
                    .read(todoFirestoreRepositoryProvider)
                    .updateIsCompleted(todo.todoId, value!);
                onReload();
              }),
          title: itemIsFocused
              ? TextField(
                  autofocus: true,
                  focusNode: textFieldFocusNode,
                  controller: textEditingController,
                )
              //　年月日を「2025年06月28日」のように0埋めして表示
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start, //  左寄せ
                  children: [
                    Text(todo.title),
                    SizedBox(height: 5),
                    Row(
                      //　Rowを使う理由：月日と時刻の間に横スペース（SizedBox）を設けたいため。
                      children: [
                        Text(
                          '${todo.createdAt.year}年'
                          '${todo.createdAt.month.toString().padLeft(2, '0')}月'
                          '${todo.createdAt.day.toString().padLeft(2, '0')}日',
                          style: TextStyle(fontSize: 13),
                        ),
                        SizedBox(width: 5),
                        Text(
                          '${todo.createdAt.hour.toString().padLeft(2, '0')}'
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
