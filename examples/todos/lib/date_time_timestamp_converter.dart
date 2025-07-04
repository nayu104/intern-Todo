
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// ! ここで export を書いておくと、自動生成したファイル側で import しなくても
// Timestamp を利用できる
export 'package:cloud_firestore/cloud_firestore.dart';

class DateTimeTimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const DateTimeTimestampConverter();

  // Firestore から受け取った Timestamp を Flutter が扱える DateTime に変換する関数
  @override
  DateTime fromJson(Timestamp json) {
    return json.toDate();
  }

  // Flutter 側の DateTime を Firestore に保存できる Timestamp に変換する関数
  @override
  Timestamp toJson(DateTime object) {
    return Timestamp.fromDate(object);
  }
}