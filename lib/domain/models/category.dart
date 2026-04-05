import 'package:isar/isar.dart';
import 'link_item.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  String name;

  @Index()
  int colorValue;

  int? iconIndex; // 선택된 아이콘의 인덱스 저장

  DateTime createdAt = DateTime.now();

  Category({
    required this.name,
    required this.colorValue,
    this.iconIndex,
  });

  @Backlink(to: 'category')
  final links = IsarLinks<LinkItem>();
}
