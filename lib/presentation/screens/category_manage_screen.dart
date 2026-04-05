import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/category_provider.dart';
import '../../domain/providers/link_provider.dart';
import '../../domain/models/category.dart';
import '../common/category_icons.dart';

class CategoryManageScreen extends ConsumerStatefulWidget {
  const CategoryManageScreen({super.key});

  @override
  ConsumerState<CategoryManageScreen> createState() =>
      _CategoryManageScreenState();
}

class _CategoryManageScreenState extends ConsumerState<CategoryManageScreen> {
  void _openEditScreen(Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.9,
          child: CategoryEditScreen(category: category),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final linksAsync = ref.watch(recentLinksProvider);
    final links = linksAsync.value ?? []; // To count links per category

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade50,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '카테고리 관리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                '저장된 카테고리가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                // 개수 카운트
                final linkCount = links
                    .where((link) => link.category.value?.id == category.id)
                    .length;

                return Dismissible(
                  key: ValueKey(category.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(
                      CupertinoIcons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // 삭제 전 한 번 더 묻기
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('카테고리 삭제'),
                        content: Text(
                          linkCount > 0
                              ? '이 카테고리에는 $linkCount개의 링크가 있습니다. 삭제하면 링크들은 \'전체\' 카테고리로 이동합니다.\n\n정말 삭제하시겠습니까?'
                              : '카테고리를 삭제하시겠습니까?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text(
                              '취소',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              '삭제',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    ref
                        .read(categoryProvider.notifier)
                        .deleteCategory(category.id);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onTap: () => _openEditScreen(category),
                      leading: SizedBox(
                        width: 28,
                        height: 28,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Color(category.colorValue),
                              radius: 14,
                            ),
                            Icon(
                              CategoryIcons.icons[category.iconIndex ?? 0],
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$linkCount개의 링크',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// MARK: - 변경된 카테고리 수정 모달 스크린 (CategoryEditView.swift 재현)

class CategoryEditScreen extends ConsumerStatefulWidget {
  final Category category;

  const CategoryEditScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends ConsumerState<CategoryEditScreen> {
  late TextEditingController _nameController;

  final List<Color> _colors = [
    const Color(0xFFFF6B6B),
    const Color(0xFF4ECDC4),
    const Color(0xFF45B7D1),
    const Color(0xFF96CEB4),
    const Color(0xFFFFEAA7),
    const Color(0xFFDDA0DD),
    const Color(0xFF98D8C8),
    const Color(0xFFF7DC6F),
    const Color(0xFFBB8FCE),
    const Color(0xFF85C1E9),
    const Color(0xFFF8C471),
    const Color(0xFF82E0AA),
  ];
  late Color _selectedColor;
  late int _selectedIconIndex;

  bool _showColorPalette = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedColor = Color(widget.category.colorValue);
    _selectedIconIndex = widget.category.iconIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Check for duplicates (excluding itself)
    final categories = ref.read(categoryProvider);
    final isDuplicate = categories.any(
      (c) =>
          c.id != widget.category.id &&
          c.name.toLowerCase() == name.toLowerCase(),
    );

    if (isDuplicate) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('중복된 카테고리 이름'),
          content: const Text('이미 존재하는 카테고리 이름입니다.\n다른 이름을 입력해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
      return;
    }

    ref
        .read(categoryProvider.notifier)
        .updateCategory(
          widget.category.id,
          name,
          _selectedColor.value,
          iconIndex: _selectedIconIndex,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '카테고리 수정',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소', style: TextStyle(fontSize: 16)),
        ),
        leadingWidth: 70,
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isEmpty) return;
              _updateCategory();
            },
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _nameController.text.trim().isEmpty
                    ? Colors.grey
                    : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 이름 입력
            const Text(
              '카테고리 이름',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              onChanged: (val) {
                setState(() {}); // Update Save button state
              },
              decoration: InputDecoration(
                hintText: '카테고리 이름을 입력하세요',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // 현재 아이콘 (미리보기)
            const Text(
              '현재 아이콘',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _selectedColor,
                    child: Icon(
                      CategoryIcons.icons[_selectedIconIndex],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '미리보기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '색상과 아이콘의 조합',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 아이콘 선택
            const Text(
              '아이콘 선택',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 60,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: CategoryIcons.icons.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIconIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIconIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: Icon(
                      CategoryIcons.icons[index],
                      size: 20,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 색상 선택 (아코디언 형태)
            GestureDetector(
              onTap: () {
                setState(() {
                  _showColorPalette = !_showColorPalette;
                });
              },
              child: Container(
                color: Colors.transparent, // 터치 영역 확보
                child: Row(
                  children: [
                    const Text(
                      '색상 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _showColorPalette
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ),

            if (_showColorPalette) ...[
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 50,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : Border.all(
                                color: Colors.grey.withOpacity(0.3),
                                width: 1,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
