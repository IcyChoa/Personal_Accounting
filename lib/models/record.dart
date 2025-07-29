import 'package:hive/hive.dart';
import 'category.dart';

part 'record.g.dart';

@HiveType(typeId: 1)
class Record extends HiveObject {
  @HiveField(0)
  bool isExpense;

  @HiveField(1)
  Category category;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  double amount;

  @HiveField(4)
  String person;

  @HiveField(5)
  String note;

  Record({
    required this.isExpense,
    required this.category,
    required this.date,
    required this.amount,
    required this.person,
    required this.note,
  });
}