import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sficon/flutter_sficon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkclip_flutter/presentation/common/link_list_tile.dart';
import 'package:linkclip_flutter/presentation/screens/add_link_screen.dart';
import 'package:linkclip_flutter/presentation/screens/category_manage_screen.dart';

import '../../domain/providers/category_provider.dart';
import '../../domain/providers/link_provider.dart';
import '../common/category_chip.dart';
import '../common/link_card_view.dart';
import '../../domain/models/category.dart';
import '../../domain/models/sort_option.dart';
import 'package:share_plus/share_plus.dart';
import 'category_add_screen.dart';
import 'setting_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final links = ref.watch(linkListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final isSelectionMode = ref.watch(multiSelectionModeProvider);
    final selectedLinks = ref.watch(selectedLinksProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isSelectionMode ? '${selectedLinks.length}개 선택됨' : 'LinkClip',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: isSelectionMode
            ? [
                // 전체 선택 / 전체 취소 버튼
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  onPressed: () {
                    final isAllSelected =
                        links.isNotEmpty &&
                        selectedLinks.length == links.length;
                    if (isAllSelected) {
                      ref.read(selectedLinksProvider.notifier).state = {};
                    } else {
                      final allIds = links.map((link) => link.id).toSet();
                      ref.read(selectedLinksProvider.notifier).state = allIds;
                    }
                  },
                  child: Text(
                    (links.isNotEmpty && selectedLinks.length == links.length)
                        ? '전체 취소'
                        : '전체 선택',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 공유 기능을 위한 임시 공유 아이콘
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.share, color: Colors.white),
                  onPressed: () {
                    if (selectedLinks.isEmpty) return;

                    // 선택된 아이디들에 해당하는 원본 LinkItem 추출
                    final selectedItems = links
                        .where((link) => selectedLinks.contains(link.id))
                        .toList();

                    // 공유할 텍스트 형태로 조립
                    final StringBuffer sb = StringBuffer();
                    for (final item in selectedItems) {
                      sb.writeln('[${item.title ?? "제목 없음"}]');
                      sb.writeln(item.url);
                      sb.writeln(); // 한 줄 띄기
                    }

                    // share_plus 패키지를 통해 네이티브 공유 시트 호출
                    Share.share(sb.toString().trim());

                    // 공유 창이 뜬 후엔 자연스럽게 다중 선택 모드 해제
                    ref.read(multiSelectionModeProvider.notifier).state = false;
                    ref.read(selectedLinksProvider.notifier).state = {};
                  },
                ),
                // 일괄 삭제 아이콘
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.trash, color: Colors.white),
                  onPressed: () async {
                    if (selectedLinks.isEmpty) return;

                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext ctx) {
                        return CupertinoAlertDialog(
                          title: const Text('삭제하시겠습니까?'),
                          content: Text(
                            '선택한 ${selectedLinks.length}개의 링크가 영구적으로 삭제됩니다.',
                          ),
                          actions: <CupertinoDialogAction>[
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              child: const Text('취소'),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              onPressed: () async {
                                Navigator.pop(ctx);
                                // 각각의 선택된 ID를 삭제
                                final notifier = ref.read(
                                  linkListProvider.notifier,
                                );
                                for (final id in selectedLinks) {
                                  await notifier.deleteLink(id);
                                }

                                // 삭제 완료 후 다중 선택 모드 종료 및 초기화
                                ref
                                        .read(
                                          multiSelectionModeProvider.notifier,
                                        )
                                        .state =
                                    false;
                                ref.read(selectedLinksProvider.notifier).state =
                                    {};
                              },
                              child: const Text('삭제'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ]
            : [
                IconButton(
                  icon: const SFIcon(
                    SFIcons.sf_tag,
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const CategoryManageScreen(),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                // TODO: - 설정 아이콘 눌렀을 때 설정 화면으로 이동
                IconButton(
                  icon: const SFIcon(
                    SFIcons.sf_gear,
                    color: Colors.black,
                    fontSize: 22,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const SettingScreen(),
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
              ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            child: Column(
              children: [
                // MARK: - 최근 저장한 링크 제목 및 링크 추가 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '최근 저장한 링크에요.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AddLinkScreen(),
                            ),
                          );
                        },
                        child: Row(
                          spacing: 5,
                          children: [
                            Text(
                              '링크 추가',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            SFIcon(
                              SFIcons.sf_chevron_right,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // MARK: - 최근 저장한 링크 리스트
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    height: 196,
                    child: ref
                        .watch(recentLinksProvider)
                        .when(
                          data: (recentLinks) => recentLinks.isEmpty
                              ? const Center(
                                  child: Text(
                                    '저장된 링크가 없습니다.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recentLinks.length > 5
                                      ? 5
                                      : recentLinks.length,
                                  itemBuilder: (context, index) {
                                    final link = recentLinks[index];
                                    return SizedBox(
                                      width: 210,
                                      child: LinkCardView(link: link),
                                    );
                                  },
                                ),
                          loading: () => const Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.white,
                            ),
                          ),
                          error: (e, st) => const Center(
                            child: Text(
                              '에러 발생',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            tileColor: Colors.white,
            title: const Text(
              '태그',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MAKR: - 카테고리 추가 버튼
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: const CategoryAddScreen(),
                      ),
                    );
                  },
                  icon: SFIcon(
                    SFIcons.sf_plus_circle,
                    fontSize: 22,
                  ),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 4,
                ),
                // MARK: - 정렬 버튼
                IconButton(
                  onPressed: () {
                    final currentSortOption = ref.read(sortOptionProvider);
                    showCupertinoModalPopup(
                      context: context,
                      builder: (BuildContext ctx) => CupertinoActionSheet(
                        title: const Text('정렬 방식 선택'),
                        actions: <CupertinoActionSheetAction>[
                          CupertinoActionSheetAction(
                            onPressed: () {
                              ref.read(sortOptionProvider.notifier).state =
                                  SortOption.latest;
                              Navigator.pop(ctx);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('최신순'),
                                if (currentSortOption == SortOption.latest)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          CupertinoActionSheetAction(
                            onPressed: () {
                              ref.read(sortOptionProvider.notifier).state =
                                  SortOption.oldest;
                              Navigator.pop(ctx);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('과거순'),
                                if (currentSortOption == SortOption.oldest)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: Icon(
                                      CupertinoIcons.checkmark_alt,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(ctx);
                          },
                          child: const Text('취소'),
                        ),
                      ),
                    );
                  },
                  icon: SFIcon(
                    SFIcons.sf_arrow_up_arrow_down_circle,
                    fontSize: 22,
                  ),
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Colors.white,
                    shape: CircleBorder(
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // MAKR: - 카테고리 필터
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCategoryFilter(
              context,
              ref,
              categories,
              selectedCategory,
            ),
          ),
          // MAKR: - 링크 리스트
          Expanded(
            child: links.isEmpty
                ? const Center(child: Text('저장된 링크가 없습니다.'))
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final link = links[index];
                      return LinkListTile(link: link);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                      );
                    },
                  ),
          ),
        ],
      ),
      // MARK: - 링크 다중 선택 플로팅 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 다중 선택 모드 토글
          final notifier = ref.read(multiSelectionModeProvider.notifier);
          notifier.state = !notifier.state;
          // 취소 시 선택된 항목 초기화
          if (!notifier.state) {
            ref.read(selectedLinksProvider.notifier).state = {};
          }
        },
        backgroundColor: isSelectionMode ? Colors.redAccent : Colors.blueAccent,
        shape: const CircleBorder(),
        child: SFIcon(
          isSelectionMode ? SFIcons.sf_xmark : SFIcons.sf_checkmark_circle,
          color: Colors.white,
          fontSize: 22,
        ),
      ),
    );
  }

  // 상단 카테고리 필터 리스트를 그리는 별도 함수
  Widget _buildCategoryFilter(
    BuildContext context,
    WidgetRef ref,
    List<Category> categories,
    Category? selectedCategory,
  ) {
    return Container(
      color: Colors.white,
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // '전체' 보기 칩
          CategoryChip(
            category: null,
            isSelected: selectedCategory == null,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
          ),

          // 사용자가 만든 카테고리 칩들
          ...categories.map((category) {
            return CategoryChip(
              category: category,
              // '현재 선택된 카테고리'와 '이 칩의 카테고리'가 같은지(id비교)로 선택 여부 판단
              isSelected: selectedCategory?.id == category.id,
              onTap: () {
                // 특정 카테고리 칩을 누르면 그 카테고리로 상태 갱신
                ref.read(selectedCategoryProvider.notifier).state = category;
              },
            );
          }),
        ],
      ),
    );
  }
}
