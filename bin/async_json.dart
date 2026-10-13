import 'package:async_json/stats.dart';

/// 命令行小工具：异步读取本地 data/books.json 并汇总输出。
/// 用法: dart run 或 dart run bin/async_json.dart [数据目录]
Future<void> main(List<String> arguments) async {
  final dataDir = arguments.isNotEmpty ? arguments[0] : 'data';

  print('开始读取 $dataDir/books.json ...');
  try {
    // await：挂起当前函数等待异步结果，但不阻塞事件循环
    final books = await loadBooks(dataDir);

    print('图书总数: ${books.length}');

    print('各类目数量:');
    countByCategory(books).forEach((category, count) {
      print('  $category: $count 本');
    });

    print('借阅量 Top3:');
    final top = topByBorrow(books);
    for (var i = 0; i < top.length; i++) {
      final b = top[i];
      print('  ${i + 1}. 《${b.title}》(${b.category}) 借阅 ${b.borrowCount} 次');
    }
  } on Exception catch (e) {
    // 异常兜底：任何失败都给出用户可读提示，不裸抛堆栈
    print('出错了: $e');
  } finally {
    print('统计结束。');
  }
}
