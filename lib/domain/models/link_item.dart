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

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    if (difference.inDays >= 365) return '${difference.inDays ~/ 365}년 전';
    if (difference.inDays >= 30) return '${difference.inDays ~/ 30}개월 전';
    if (difference.inDays > 0) return '${difference.inDays}일 전';
    if (difference.inHours > 0) return '${difference.inHours}시간 전';
    if (difference.inMinutes > 0) return '${difference.inMinutes}분 전';
    return '방금 전';
  }

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
