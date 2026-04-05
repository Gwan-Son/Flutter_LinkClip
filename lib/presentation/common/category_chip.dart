import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../domain/models/category.dart';
import 'category_icons.dart';

class CategoryChip extends StatelessWidget {
  final Category? category; // null이면 '전체 보기'를 의미합니다.
  final bool isSelected; // 현재 선택된 상태인지 여부
  final VoidCallback onTap; // 눌렸을 때 실행할 함수

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 카테고리 정보 추출 (null이면 전체 탭으로 간주)
    final label = category?.name ?? '전체';

    // 카테고리에 색상이 지정되어 있으면 그 색상을, 없으면 회색을 기본으로 씁니다.
    // '전체' 탭은 기본 짙은 회색으로 둡니다.
    final color = category != null
        ? Color(category!.colorValue)
        : Colors.grey.shade800;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // 선택/해제 시 부드러운 애니메이션 효과
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // 선택되었을 때는 카테고리 색상으로 채우고, 아닐 때는 테두리만 그립니다.
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20), // 둥근 캡슐 모양
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Icon(
                    CategoryIcons.icons[category!.iconIndex ?? 0],
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  // 텍스트 색상도 배경색에 대비 되게 설정
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
