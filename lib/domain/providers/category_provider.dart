import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/isar_database.dart';
import '../../main.dart';
import '../models/category.dart';

class CategoryNotifier extends Notifier<List<Category>> {
  // 1. 초기 상태 설정: 앱이 켜질 때 DB에서 모든 카테고리를 가져와 초기 상태로 설정
  @override
  List<Category> build() {
    _loadCategories();
    return [];
  }

  // 내부 함수: DB에서 데이터 가져오기
  Future<void> _loadCategories() async {
    // ref.read()를 통해 main.dart에서 주입했던 databaseProvider를 가져옴.
    final db = ref.read(databaseProvider);
    final categories = await db.getAllCategories();

    // state 값을 갱신하면, 이 상태를 구독하고 있는 모든 UI 위젯들이 자동으로 다시 그려짐.
    state = categories;
  }

  // 2. 카테고리 추가 기능
  Future<void> addCategory(String name, int colorValue) async {
    final db = ref.read(databaseProvider);

    final newCategory = Category(name: name, colorValue: colorValue);
    await db.saveCategory(newCategory);

    _loadCategories();
  }

  // TODO:- 카테고리 삭제 로직 추가 예정
}

// 3. UI에서 사용할 수 있도록 NotifierProvider로 감싸서 노출.
final categoryProvider = NotifierProvider<CategoryNotifier, List<Category>>(
  () {
    return CategoryNotifier();
  },
);
