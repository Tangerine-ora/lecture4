/// 图书模型类：与统一数据集 books.json 字段一一对应（完整字段模型化）。
class Book {
  final String id;
  final String title;
  final String category;
  final String author;
  final int rating;
  final int borrowCount;
  final String month;

  Book({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.rating,
    required this.borrowCount,
    required this.month,
  });

  /// 从 JSON Map 构造 Book。
  /// - 数字字段用 `as num` 再 toInt，兼容 JSON 中 int/double 两种情况；
  /// - borrowCount 缺失时默认 0、rating 缺失时默认 0（缺失字段兜底）；
  /// - 字符串字段缺失或类型错误时抛出 FormatException，由上层捕获并给出可读提示。
  factory Book.fromJson(Map<String, dynamic> j) {
    String readString(String key) {
      final v = j[key];
      if (v is String) return v;
      throw FormatException('字段 "$key" 缺失或不是字符串（实际值: $v）');
    }

    int readInt(String key, {int defaultValue = 0}) {
      final v = j[key];
      if (v == null) return defaultValue; // 缺失字段默认值
      if (v is num) return v.toInt();
      throw FormatException('字段 "$key" 类型错误（实际值: $v）');
    }

    return Book(
      id: readString('id'),
      title: readString('title'),
      category: readString('category'),
      author: readString('author'),
      rating: readInt('rating'),
      borrowCount: readInt('borrowCount'),
      month: readString('month'),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'author': author,
        'rating': rating,
        'borrowCount': borrowCount,
        'month': month,
      };

  @override
  String toString() => 'Book($id, $title, $category, $author, $rating, $borrowCount, $month)';
}
