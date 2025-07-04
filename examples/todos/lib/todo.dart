import 'package:flutter/foundation.dart' show immutable;
import 'package:riverpod/riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'date_time_timestamp_converter.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String description,
    @Default(false) bool completed,
    @DateTimeTimestampConverter() required DateTime createdAt,
  }) = _Todo;


//JSON → クラス
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}
