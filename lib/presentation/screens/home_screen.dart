import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 우리가 만든 컴포넌트와 프로바이더들을 모두 불러옵니다.
import '../../domain/providers/category_provider.dart';
import '../../domain/providers/link_provider.dart';
import '../common/category_chip.dart';
import '../common/link_card_view.dart';
import '../../domain/models/category.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 상태 구독하기: 상태가 변하면 이 build 함수가 자동으로 다시 실행되며 UI가 새로고침됩니다.
    final categories = ref.watch(categoryProvider);
    final links = ref.watch(linkListProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'LinkClip',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 나중에 설정/카테고리 관리 화면으로 이동
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 2. 상단 카테고리 필터 영역
          _buildCategoryFilter(ref, categories, selectedCategory),

          // 3. 본문 링크 리스트 영역
          Expanded(
            child: links.isEmpty
                ? const Center(child: Text('저장된 링크가 없습니다.'))
                : ListView.builder(
                    itemCount: links.length,
                    itemBuilder: (context, index) {
                      final link = links[index];
                      return LinkCardView(link: link);
                    },
                  ),
          ),
        ],
      ),
      // 4. 새로운 링크 우하단 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 나중에 '링크 추가 화면'으로 이동 (Phase 5-2)
          print('링크 추가 버튼 눌림!');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 상단 카테고리 필터 리스트를 그리는 별도 함수
  Widget _buildCategoryFilter(
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
          // 스프레드 연산자(...)를 써서 List 변환 결과를 자식으로 펼쳐 넣습(flatMap 효과)니다.
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
