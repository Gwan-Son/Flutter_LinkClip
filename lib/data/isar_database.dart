import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/category.dart';
import '../domain/models/link_item.dart';

class IsarDatabase {
  late Isar isar;

  // DB 초기화
  Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [CategorySchema, LinkItemSchema],
      directory: dir.path,
    );
  }

  // 카테고리 저장
  Future<void> saveCategory(Category newCategory) async {
    await isar.writeTxn(() async {
      await isar.categorys.put(newCategory);
    });
  }

  // 모든 카테고리 불러오기
  Future<List<Category>> getAllCategories() async {
    return await isar.categorys.where().findAll();
  }

  // 새로운 링크 저장
  Future<void> saveLink(LinkItem newLink, {required Category category}) async {
    await isar.writeTxn(() async {
      // 링크 원본 저장
      await isar.linkItems.put(newLink);
      // 링크와 카테고리 사이의 관계 맺어주기 및 저장
      newLink.category.value = category;
      await newLink.category.save();
    });
  }

  // 모든 링크 불러오기
  Future<List<LinkItem>> getAllLinks() async {
    return await isar.linkItems.where().findAll();
  }

  // 특정 카테고리에 속한 링크들만 불러오기
  Future<List<LinkItem>> getLinksByCategory(Category category) async {
    // 카테고리에 연결된 링크 데이터를 메모리로 로드
    await category.links.load();

    // 로드된 링크들을 List 형태로 반환
    return category.links.toList();
  }
}
