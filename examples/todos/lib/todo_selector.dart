import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_basic.dart';
import 'todo_firestore.dart';

class TodoSelector extends ConsumerWidget {
  const TodoSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child:
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TodoBasic()));
            },
            child: Text("ベーシック"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TodoFirestore()));
            },
            child: Text("from firestore"),
          ),
        ],
      ),
      ),
    );
  }
}
