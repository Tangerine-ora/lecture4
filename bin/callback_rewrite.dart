import 'dart:async';

/// 自主实践任务1：嵌套回调版 → 顺序 await 版改写对比。
/// 场景：依次完成 登录 → 拉取用户资料 → 拉取借阅列表，每步模拟 100ms 耗时。

Future<String> login(String user) =>
    Future.delayed(const Duration(milliseconds: 100), () => 'token-of-$user');

Future<String> fetchProfile(String token) =>
    Future.delayed(const Duration(milliseconds: 100), () => 'profile($token)');

Future<String> fetchBorrows(String profile) =>
    Future.delayed(const Duration(milliseconds: 100), () => 'borrows-of-$profile');

/// 改写前：嵌套回调（回调地狱），错误要在每一层单独传递。
void runNestedCallbacks() {
  login('hu-kuang').then((token) {
    fetchProfile(token).then((profile) {
      fetchBorrows(profile).then((borrows) {
        print('[callback] 最终结果: $borrows');
      }).catchError((e) => print('[callback] 第3步出错: $e'));
    }).catchError((e) => print('[callback] 第2步出错: $e'));
  }).catchError((e) => print('[callback] 第1步出错: $e'));
}

/// 改写后：顺序 await，线性可读，一处 try-catch 兜底。
Future<void> runSequentialAwait() async {
  try {
    final token = await login('hu-kuang');
    final profile = await fetchProfile(token);
    final borrows = await fetchBorrows(profile);
    print('[await]    最终结果: $borrows');
  } catch (e) {
    print('[await]    出错了: $e');
  }
}

Future<void> main() async {
  runNestedCallbacks();
  await runSequentialAwait();
  // 等嵌套回调链跑完再退出，避免 main 提前结束
  await Future.delayed(const Duration(milliseconds: 400));
}
