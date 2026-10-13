# 进度报告4（第6周·Dart语言基础三：异步、异常与包管理）

## 一、任务理解

本次作业要完成：复现课堂案例 `async_json`——一个异步读取本地 `data/books.json`、解析为 `Book` 模型类并汇总输出（总数、各类目数量、借阅量 Top3）的命令行小工具；同时完成自主实践任务：嵌套回调改写为顺序 await、三类异常（文件缺失、字段缺失、类型错误）均有可读提示、JSON 与模型类双向转换 roundtrip 验证、pubspec 依赖规范（全部 ^ 约束、提交锁定文件）。

验收标准：正常路径统计输出正确；文件缺失路径输出友好提示"数据文件缺失，请检查 data/books.json"而不崩溃；能解释 await 在案例中的作用；仓库 3 次以上规范提交。

## 二、环境与工具

- 开发环境：Windows 11，Dart SDK 3.13.3（stable），PowerShell，VS Code / TraeCode
- 运行目标：命令行（Dart VM），本次为纯 Dart 项目，不涉及 Web/模拟器/真机
- 依赖：path ^1.9.1（`dart pub add path` 命令式添加）；dev 依赖 test ^1.25.6、lints ^6.0.0
- AI 工具：TraeCode（Kimi-K3 模型）

## 三、过程记录

1. `dart create async_json` 创建命令行项目脚手架；
2. `dart pub add path` 添加 path 依赖（自动写入 ^1.9.1 约束），将统一数据集 books.json（id/title/category/author/rating/borrowCount/month 七字段，共 36 条）复制到 `data/` 目录 → 提交 `feat: dataset & deps ready`；
3. 编写 `lib/book.dart`（Book 模型，fromJson/toJson）、`lib/stats.dart`（loadBooks 异步读取+解析、countByCategory、topByBorrow）、`bin/async_json.dart`（main 中 async/await 串起整个流程）→ 提交 `feat: parse & stats from books.json`；
4. `dart run` 验证正常路径；把 `data/books.json` 临时改名再运行，验证文件缺失路径输出友好提示，随后恢复文件；
5. 在 books.json 中手工删掉一个对象的 borrowCount 字段做故意实验：修复前 fromJson 直接类型断言会抛 null 断言错误，修复后缺失字段默认 0，程序正常输出；补充三类异常的可读提示与单元测试（6 个用例全过）→ 提交 `feat: robust missing-field & file handling`；
6. 编写自主实践演示：`bin/callback_rewrite.dart`（嵌套回调 vs 顺序 await）、`bin/future_wait_demo.dart`（串行 vs Future.wait 并行计时 + 部分失败场景）并运行记录数据；
7. `dart analyze` 无问题、`dart test` 6/6 通过；填写本报告 → 提交 `docs: progress report 4`。

## 四、关键代码

**代码1：异步读取与异常兜底（lib/stats.dart，AI 生成，人工核对并运行验证）**

```dart
Future<List<Book>> loadBooks(String dataDir) async {
  final file = File(p.join(dataDir, 'books.json'));
  final String text;
  try {
    text = await file.readAsString();          // await 挂起等待文件读完，不阻塞事件循环
  } on FileSystemException {                   // 精确捕获文件类异常
    throw Exception('数据文件缺失，请检查 ${file.path}');  // 转为用户可读提示
  }
  final dynamic decoded;
  try {
    decoded = jsonDecode(text);                // 字符串 → Map/List（dynamic）
  } on FormatException catch (e) {
    throw Exception('JSON 格式错误，无法解析 ${file.path}: ${e.message}');
  }
  ...
}
```

逐行解释：`async` 标记函数为异步，返回值自动包成 `Future<List<Book>>`；`await file.readAsString()` 发起异步 IO 后立即让出事件循环，文件读完才继续；`on FileSystemException` 精确捕获文件缺失/无权限；内层 `try` 单独捕获 JSON 语法错误；两层都把技术异常转成用户可读提示，遵守"不裸抛"红线。

**代码2：模型类与缺失字段兜底（lib/book.dart，AI 生成，人工核对+单元测试验证）**

```dart
final rawCount = j['borrowCount'];
final int count;
if (rawCount == null) {
  count = 0;                        // 缺失字段默认 0（故意实验后的修复）
} else if (rawCount is num) {
  count = rawCount.toInt();         // JSON 数字可能是 int 或 double，as num 再 toInt 最稳
} else {
  throw FormatException('字段 "borrowCount" 类型错误（实际值: $rawCount）');
}
```

**代码3：串行 vs 并行计时（bin/future_wait_demo.dart，AI 生成，人工运行验证）**

```dart
var sw = Stopwatch()..start();
final r1 = await task('A', 1);      // 串行：一个接一个等，总计约 3 秒
final r2 = await task('B', 1);
final r3 = await task('C', 1);
sw = Stopwatch()..start();
final results = await Future.wait([task('A', 1), task('B', 1), task('C', 1)]); // 并行：同时发起，总计约 1 秒
```

## 五、检查点结果

- 正常路径：`dart run` 输出图书总数 36、六个类目（计算机技术/经济管理/科普百科/文学小说/艺术设计/历史哲学）各 6 本、Top3 为《万历十五年》91 次、《渲染管线十二讲》87 次、《茶马古道》87 次，与数据集手工核算一致。
- 异常路径：把 `data/books.json` 改名为 `books.json.bak` 后运行，输出"出错了: Exception: 数据文件缺失，请检查 data\books.json"，程序正常结束无崩溃堆栈；恢复文件后再次运行输出正确。
- await 作用解释：await 让 main 在等待文件 IO 完成时不阻塞事件循环，拿到结果（Future 解包成 String）后才继续执行解析，保证"读完再解析"的时序。

（截图证据见第八节）

## 六、问题与调试

**问题1（JSON 类型错误）**：最初 fromJson 写成 `borrowCount: j['borrowCount'] as int`，测试传入 `3.0`（double）时抛 `type 'double' is not a subtype of type 'int' in type cast`。定位：jsonDecode 对 JSON 数字按是否含小数点返回 int 或 double，类型断言写死 int 不稳。解决：改为 `as num`（或 `is num` 判断）后 `.toInt()`，并补了 int/double 两种输入的单元测试。

**问题2（异步时序/故意实验）**：手工删除一个对象的 borrowCount 字段后运行，修复前程序抛 null 类型断言错误并中断；在 fromJson 中加入"缺失默认 0"的分支后，该书记录按 0 次参与统计，程序完整输出。由此确认缺失字段必须先判 null 再转换。

**问题3（漏 await 风险）**：演示嵌套回调时若 main 不以 await 等待回调链结束，命令行会在打印最终结果前退出；通过在 main 末尾 `await Future.delayed(...)` 保底等待验证了这一时序问题。

## 七、AI 使用记录

| 用途 | 指令摘要 | 输出 | 本人验证方式 |
|---|---|---|---|
| 读取作业指南与报告模板 | 解析两份 docx 提取任务要求 | 任务清单与报告十节结构 | 对照原文件抽查关键要求 |
| 生成 Book 模型与解析统计代码 | 按指南字段实现 fromJson/toJson、loadBooks、统计函数 | book.dart / stats.dart | `dart analyze` 无警告；单元测试 6/6 |
| 生成异常兜底与故意实验 | 文件缺失/字段缺失/类型错误三类提示；Future.wait 计时 | stats.dart 异常分支、future_wait_demo.dart | 改名文件实测异常路径；计时数据 3040ms vs 1007ms |
| 生成本报告初稿 | 按十节模板填写 | progress.md 全文 | 逐节核对与实际操作、运行输出一致 |

## 八、证据截图

- 【图1】`dart run` 正常路径完整输出（总数、类目统计、Top3）——正常路径证据。
- 【图2】books.json 改名后 `dart run` 输出"数据文件缺失，请检查 data\books.json"——异常路径友好提示证据。
- 【图3】`dart test` 显示 6 个用例全部通过 + `dart analyze` 无问题——代码质量证据。
- 【图4】`dart run bin/future_wait_demo.dart` 输出串行约 3040ms、并行约 1007ms——故意实验计时证据。
- 【图5】`git log --oneline` 显示 4 次规范提交（feat×3 + docs×1）及 GitHub 仓库页面——Git 规范证据。

## 九、自评

- 案例复现 async_json：✅ 正常/异常两路径均正确输出（15/15）
- 检查点（两路截图、能解释 await）：✅（5/5）
- Git 规范：✅ 4 次语义化提交，pubspec.lock 已提交（5/5）
- 报告记录：✅ 本报告十节齐全（5/5）
- 自主实践1 嵌套回调改写：✅ bin/callback_rewrite.dart 两版对比
- 自主实践2 异常兜底：✅ 文件缺失/字段缺失/类型错误三类均可读提示
- 自主实践3 JSON 模型化+roundtrip：✅ toJson/fromJson 往返一致（单测覆盖）
- 自主实践4 pubspec 规范：✅ 全部 ^ 约束，无冗余依赖，lock 已提交
- 自主实践5 AI 使用标注：✅ 见第四、七节
- 选做2 Future.wait 并行实验：✅ 串行 3040ms vs 并行 1007ms，含部分失败行为记录

## 十、一句话收获与下一步计划

收获：await 不是"等死"而是"让出事件循环"，配合 try-catch 与模型化 JSON 解析就能写出健壮的异步小工具。

遗留问题：Stream 只练了 `await for` 消费，对 `StreamController` 生产端还不熟；Future.wait 部分失败时更优雅的 `FutureExtensions` 写法待研究。

下次预习：第 11 课网络请求将复用本课的 async/await + JSON 模型类模式，提前浏览 pub.dev 上 http/dio 包的用法。
