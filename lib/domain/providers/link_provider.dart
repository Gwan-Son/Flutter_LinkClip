import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../data/isar_database.dart';
import '../../main.dart';
import '../models/category.dart';
import '../models/link_item.dart';

import '../models/sort_option.dart';

// 1. 현재 선택된 카테고리를 관리하는 단순한 StateProvider
// null이면 '전체 보기' 상태
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

// 정렬 방식을 관리하는 Provider (기본값: 최신순)
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.latest);

// 다중 선택 모드 진입 여부를 관리하는 Provider
final multiSelectionModeProvider = StateProvider<bool>((ref) => false);

// 다중 선택된 링크의 ID 목록을 관리하는 Provider
final selectedLinksProvider = StateProvider<Set<int>>((ref) => <int>{});

// 2. 링크 목록을 관리하는 Notifier
class LinkListNotifier extends Notifier<List<LinkItem>> {
  @override
  List<LinkItem> build() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final sortOption = ref.watch(sortOptionProvider);

    _loadLinks(selectedCategory, sortOption);
    return [];
  }

  // 내부 함수: DB에서 링크 데이터 가져오기
  Future<void> _loadLinks(Category? category, SortOption sortOption) async {
    final db = ref.read(databaseProvider);

    List<LinkItem> links = [];
    if (category == null) {
      // 선택된 카테고리가 없으면 모든 링크 가져오기 (DB에서 기본적으로 최신순으로 반대로 주기도 함)
      // 정렬을 Provider에서 통제하기 위해 DB 레벨의 반전을 냅두거나, 여기서 덮어씌웁니다.
      links = await db.getAllLinks();
    } else {
      links = await db.getLinksByCategory(category);
    }

    // Isar id(자동 증가)를 기준으로 정렬
    // 사실 IsarDatabase에서 이미 list.reversed를 해주는 경우가 있다면
    // 기준을 명확하게 다시 잡기 위해 id로 정렬합니다.
    if (sortOption == SortOption.latest) {
      links.sort((a, b) => b.id.compareTo(a.id)); // 내림차순 (최신순)
    } else {
      links.sort((a, b) => a.id.compareTo(b.id)); // 오름차순 (과거순)
    }

    state = links;
  }

  Future<void> addLink({
    required String url,
    String? title,
    String? description,
    String? imageUrl,
    String? memo,
    Category? category,
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
    final currentSortOption = ref.read(sortOptionProvider);
    _loadLinks(currentCategory, currentSortOption);
  }

  // 링크 삭제
  Future<void> deleteLink(int id) async {
    final db = ref.read(databaseProvider);
    await db.deleteLink(id);

    // 삭제 후 리스트 갱신
    final currentCategory = ref.read(selectedCategoryProvider);
    final currentSortOption = ref.read(sortOptionProvider);
    _loadLinks(currentCategory, currentSortOption);
  }
}

// 4. UI에 노출할 Provider
final linkListProvider = NotifierProvider<LinkListNotifier, List<LinkItem>>(
  () {
    return LinkListNotifier();
  },
);

// 5. 최근 저장된 모든 링크를 카테고리 필터 상관없이 실시간으로 가져오는 Provider
final recentLinksProvider = StreamProvider<List<LinkItem>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.isar.linkItems
      .where()
      .watch(fireImmediately: true)
      .map((links) => links.reversed.toList());
});
