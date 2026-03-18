import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/isar_database.dart';
import '../../main.dart';
import '../models/category.dart';
import '../models/link_item.dart';

// 1. 현재 선택된 카테고리를 관리하는 단순한 StateProvider
// null이면 '전체 보기' 상태
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

// 2. 링크 목록을 관리하는 Notifier
class LinkListNotifier extends Notifier<List<LinkItem>> {
  @override
  List<LinkItem> build() {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    _loadLinks(selectedCategory);
    return [];
  }

  // 내부 함수: DB에서 링크 데이터 가져오기
  Future<void> _loadLinks(Category? category) async {
    final db = ref.read(databaseProvider);
    // IsarDatabase 인스턴스를 통해 DB에 직접 접근함.

    List<LinkItem> links = [];
    if (category == null) {
      // 선택된 카테고리가 없으면 모든 링크 가져오기
      links = await db.getAllLinks();
    } else {
      links = await db.getLinksByCategory(category);
    }

    state = links;
  }

  Future<void> addLink({
    required String url,
    String? title,
    String? description,
    String? imageUrl,
    String? memo,
    required Category category,
  }) async {
    final db = ref.read(databaseProvider);

    final newLink = LinkItem(
      url: url,
      title: title,
      description: description,
      imageUrl: imageUrl,
      memo: memo,
    );

    await db.saveLink(newLink, category: category);

    final currentCategory = ref.read(selectedCategoryProvider);
    _loadLinks(currentCategory);
  }
}

// 4. UI에 노출할 Provider
final linkListProvider = NotifierProvider<LinkListNotifier, List<LinkItem>>(
  () {
    return LinkListNotifier();
  },
);
