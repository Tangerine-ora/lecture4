import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'book.dart';

/// 异步读取并解析 data/books.json，返回图书列表。
/// 文件缺失、JSON 格式错误、字段错误分别抛出带可读信息的异常。
Future<List<Book>> loadBooks(String dataDir) async {
  final file = File(p.join(dataDir, 'books.json'));

  final String text;
  try {
    text = await file.readAsString();
  } on FileSystemException {
    throw Exception('数据文件缺失，请检查 ${file.path}');
  }

  final dynamic decoded;
  try {
    decoded = jsonDecode(text);
  } on FormatException catch (e) {
    throw Exception('JSON 格式错误，无法解析 ${file.path}: ${e.message}');
  }

  if (decoded is! List) {
    throw Exception('JSON 顶层结构应为数组，实际是 ${decoded.runtimeType}');
  }

  final books = <Book>[];
  for (var i = 0; i < decoded.length; i++) {
    final item = decoded[i];
    if (item is! Map<String, dynamic>) {
      throw Exception('第 ${i + 1} 条记录不是 JSON 对象');
    }
    try {
      books.add(Book.fromJson(item));
    } on FormatException catch (e) {
      throw Exception('第 ${i + 1} 条记录解析失败: ${e.message}');
    }
  }
  return books;
}

/// 按类目统计图书数量。
Map<String, int> countByCategory(List<Book> books) {
  final counts = <String, int>{};
  for (final b in books) {
    counts[b.category] = (counts[b.category] ?? 0) + 1;
  }
  return counts;
}

/// 借阅量 Top N（默认 3）。
List<Book> topByBorrow(List<Book> books, [int n = 3]) {
  final sorted = [...books]..sort((a, b) => b.borrowCount.compareTo(a.borrowCount));
  return sorted.take(n).toList();
}
