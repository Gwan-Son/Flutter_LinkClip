import 'package:isar/isar.dart';
import 'category.dart';

part 'link_item.g.dart';

@collection
class LinkItem {
  Id id = Isar.autoIncrement;

  // 원본 URL
  String url;

  // 사이트 제목
  String? title;

  // 사이트 설명
  String? description;

  // 사이트 썸네일 이미지 URL
  String? imageUrl;

  // 사용자가 직접 작성한 메모
  String? memo;

  // 즐겨찾기
  bool isPinned;

  DateTime createdAt = DateTime.now();

  final category = IsarLink<Category>();

  LinkItem({
    required this.url,
    this.title,
    this.description,
    this.imageUrl,
    this.memo,
    this.isPinned = false,
  });
}
