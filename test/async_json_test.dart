import 'dart:convert';

import 'package:async_json/async_json.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson 正常解析，数字字段兼容 int/double', () {
    final a = Book.fromJson(
        {'id': 'B1', 'title': 'A', 'category': 'C', 'borrowCount': 10});
    final b = Book.fromJson(
        {'id': 'B2', 'title': 'B', 'category': 'C', 'borrowCount': 3.0});
    expect(a.borrowCount, 10);
    expect(b.borrowCount, 3);
  });

  test('borrowCount 缺失时默认 0', () {
    final book =
        Book.fromJson({'id': 'B1', 'title': 'A', 'category': 'C'});
    expect(book.borrowCount, 0);
  });

  test('字符串字段缺失抛出 FormatException', () {
    expect(() => Book.fromJson({'id': 'B1', 'category': 'C'}),
        throwsFormatException);
  });

  test('toJson/fromJson roundtrip 一致', () {
    final original = Book(
        id: 'B001', title: 'Flutter实战', category: '移动开发', borrowCount: 128);
    final restored = Book.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);
    expect(restored.toJson(), original.toJson());
  });

  test('统计：类目计数与 Top N', () {
    final books = [
      Book(id: '1', title: 'a', category: 'X', borrowCount: 5),
      Book(id: '2', title: 'b', category: 'X', borrowCount: 9),
      Book(id: '3', title: 'c', category: 'Y', borrowCount: 7),
    ];
    expect(countByCategory(books), {'X': 2, 'Y': 1});
    final top = topByBorrow(books, 2);
    expect(top.map((b) => b.id).toList(), ['2', '3']);
  });

  test('loadBooks 文件缺失时给出可读异常', () async {
    expect(() => loadBooks('not_exist_dir'),
        throwsA(predicate((e) => e.toString().contains('数据文件缺失'))));
  });
}
