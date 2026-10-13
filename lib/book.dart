/// 图书模型类：与统一数据集 books.json 字段一一对应。
class Book {
  final String id;
  final String title;
  final String category;
  final int borrowCount;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.borrowCount,
  });

  /// 从 JSON Map 构造 Book。
  /// - 数字字段用 `as num` 再 toInt，兼容 JSON 中 int/double 两种情况；
  /// - borrowCount 缺失时默认 0（缺失字段兜底）；
  /// - 字符串字段缺失或类型错误时抛出 FormatException，由上层捕获并给出可读提示。
  factory Book.fromJson(Map<String, dynamic> j) {
    String readString(String key) {
      final v = j[key];
      if (v is String) return v;
      throw FormatException('字段 "$key" 缺失或不是字符串（实际值: $v）');
    }

    final rawCount = j['borrowCount'];
    final int count;
    if (rawCount == null) {
      count = 0; // 缺失字段默认 0
    } else if (rawCount is num) {
      count = rawCount.toInt();
    } else {
      throw FormatException('字段 "borrowCount" 类型错误（实际值: $rawCount）');
    }

    return Book(
      id: readString('id'),
      title: readString('title'),
      category: readString('category'),
      borrowCount: count,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'borrowCount': borrowCount,
      };

  @override
  String toString() => 'Book($id, $title, $category, $borrowCount)';
}
