import 'dart:async';

/// 自主实践任务（故意实验/选做2）：3 个 1 秒延时任务
/// 串行 await vs Future.wait 并行 计时对比，并记录“部分失败”场景的行为。

Future<String> task(String name, int seconds, {bool fail = false}) async {
  await Future.delayed(Duration(seconds: seconds));
  if (fail) throw Exception('$name 失败');
  return '$name 完成(${seconds}s)';
}

Future<void> main() async {
  // 1. 串行：三个任务依次等待，总耗时约 3 秒
  var sw = Stopwatch()..start();
  final r1 = await task('A', 1);
  final r2 = await task('B', 1);
  final r3 = await task('C', 1);
  print('串行结果: [$r1, $r2, $r3]，耗时 ${sw.elapsed.inMilliseconds}ms');

  // 2. 并行：三个任务同时发起，总耗时约 1 秒
  sw = Stopwatch()..start();
  final results = await Future.wait([task('A', 1), task('B', 1), task('C', 1)]);
  print('并行结果: $results，耗时 ${sw.elapsed.inMilliseconds}ms');

  // 3. 部分失败：Future.wait 只要有一个失败就整体抛异常（先到先得）
  try {
    await Future.wait([
      task('A', 1),
      task('B', 1, fail: true),
      task('C', 3),
    ]);
  } catch (e) {
    print('部分失败场景: Future.wait 整体抛出 -> $e');
  }

  // 4. 想拿到每个任务的成败：用 Future.wait 的 eagerError:false 思路不可行，
  //    改为每个 Future 自己 catchError 包一层，收集所有结果。
  final settled = await Future.wait([
    task('A', 1).then((v) => 'OK: $v').catchError((Object e) => 'ERR: $e'),
    task('B', 1, fail: true).then((v) => 'OK: $v').catchError((Object e) => 'ERR: $e'),
    task('C', 1).then((v) => 'OK: $v').catchError((Object e) => 'ERR: $e'),
  ]);
  print('逐个兜底后的并行结果: $settled');
}
