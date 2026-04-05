import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/category_provider.dart';
import '../common/category_icons.dart';

class CategoryAddScreen extends ConsumerStatefulWidget {
  const CategoryAddScreen({super.key});

  @override
  ConsumerState<CategoryAddScreen> createState() => _CategoryAddScreenState();
}

class _CategoryAddScreenState extends ConsumerState<CategoryAddScreen> {
  final TextEditingController _nameController = TextEditingController();

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

  int _selectedIconIndex = 0;

  bool _showColorPalette = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    // Check for duplicates
    final categories = ref.read(categoryProvider);
    final isDuplicate = categories.any(
      (c) => c.name.toLowerCase() == name.toLowerCase(),
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
        .addCategory(
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
          '새 카테고리',
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
              _saveCategory();
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
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: Icon(
                      CategoryIcons.icons[index],
                      size: 20,
                      color: isSelected ? Colors.blue : Colors.black87,
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
              // ColorPaletteView 구현부 대체
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
                        // _showColorPalette = false; // 선택 즉시 팔레트 닫을 경우 주석 해제
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
