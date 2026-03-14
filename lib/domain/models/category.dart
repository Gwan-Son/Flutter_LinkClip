import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  String name;

  @Index()
  int colorValue;

  DateTime createdAt = DateTime.now();

  Category({
    required this.name,
    required this.colorValue,
  });
}
