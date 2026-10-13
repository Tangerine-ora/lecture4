import 'dart:convert';

import 'package:async_json/async_json.dart';
import 'package:test/test.dart';

void main() {
  Map<String, dynamic> fullJson() => {
        'id': 'B1',
        'title': 'A',
        'category': 'C',
        'author': 'X',
        'rating': 5,
        'borrowCount': 10,
        'month': '1月',
      };

  test('fromJson 正常解析，数字字段兼容 int/double', () {
    final a = Book.fromJson(fullJson());
    final b = Book.fromJson({...fullJson(), 'id': 'B2', 'borrowCount': 3.0});
    expect(a.borrowCount, 10);
    expect(b.borrowCount, 3);
  });

  test('borrowCount 缺失时默认 0', () {
    final book = Book.fromJson({...fullJson()}..remove('borrowCount'));
    expect(book.borrowCount, 0);
  });

  test('字符串字段缺失抛出 FormatException', () {
    expect(() => Book.fromJson({...fullJson()}..remove('title')),
        throwsFormatException);
  });

  test('toJson/fromJson roundtrip 一致', () {
    final original = Book.fromJson(fullJson());
    final restored = Book.fromJson(
        jsonDecode(jsonEncode(original.toJson())) as Map<String, dynamic>);
    expect(restored.toJson(), original.toJson());
  });

  test('统计：类目计数与 Top N', () {
    Book mk(String id, String cat, int n) => Book(
        id: id,
        title: 't$id',
        category: cat,
        author: 'a',
        rating: 5,
        borrowCount: n,
        month: '1月');
    final books = [mk('1', 'X', 5), mk('2', 'X', 9), mk('3', 'Y', 7)];
    expect(countByCategory(books), {'X': 2, 'Y': 1});
    final top = topByBorrow(books, 2);
    expect(top.map((b) => b.id).toList(), ['2', '3']);
  });

  test('loadBooks 文件缺失时给出可读异常', () async {
    expect(() => loadBooks('not_exist_dir'),
        throwsA(predicate((e) => e.toString().contains('数据文件缺失'))));
  });
}
