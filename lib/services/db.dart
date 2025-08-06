import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../models/record.dart';
import '../models/settings.dart';

Future<void> initDatabase() async{
  await Hive.initFlutter();
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(RecordAdapter());
  Hive.registerAdapter(SettingsAdapter());
  await Hive.openBox<Category>('categories');
  final catBox = Hive.box<Category>('categories');
  if (catBox.isEmpty) {
    catBox.add(Category(name: 'Food', isExpense: true));
    catBox.add(Category(name: 'Transport', isExpense: true));
    catBox.add(Category(name: 'General', isExpense: true));
    catBox.add(Category(name: 'Entertainment', isExpense: true));
    catBox.add(Category(name: 'Rent', isExpense: true));


    catBox.add(Category(name: 'Salary', isExpense: false));
    catBox.add(Category(name: 'Allowance', isExpense: false));
    catBox.add(Category(name: 'Bonus', isExpense: false));
    catBox.add(Category(name: 'Other', isExpense: false));
  }
  await Hive.openBox<Record>('records');
  // open typed settings box and set default
  final settingsBox = await Hive.openBox<Settings>('settings');
  if (settingsBox.isEmpty) {
    await settingsBox.put('settings', Settings());
  }
}

/// categories operations

Future<List<Category>> fetchCategories(bool isExpense) async {
  final box = Hive.box<Category>('categories');
  return box.values.where((c) => c.isExpense == isExpense).toList();
}

Future<void> addCategory(Category category) async {
  final box = Hive.box<Category>('categories');
  await box.add(category);
}

Future<void> removeCategory(int key) async {
  final catBox = Hive.box<Category>('categories');
  final category = catBox.get(key);
  if (category != null) {
    // delete all records using this category
    final recBox = Hive.box<Record>('records');
    final toRemove = recBox.values.where((r) =>
      r.category.isExpense == category.isExpense &&
      r.category.name == category.name
    ).toList();
    for (var rec in toRemove) {
      await rec.delete();
    }
    // now delete the category
    await catBox.delete(key);
  }
}

/// rename category and update existing records
Future<void> renameCategory(int key, String newName) async {
  final catBox = Hive.box<Category>('categories');
  final category = catBox.get(key);
  if (category != null) {
    final oldName = category.name;
    category.name = newName;
    await catBox.put(key, category);
    // update records that use this category
    final recBox = Hive.box<Record>('records');
    for (var rec in recBox.values) {
      if (rec.category.isExpense == category.isExpense && rec.category.name == oldName) {
        rec.category.name = newName;
        await rec.save();
      }
    }
  }
}

/// records operations

Future<void> addRecord(Record record) async {
  final box = Hive.box<Record>('records');
  await box.add(record);
}

Future<void> removeRecord(int key) async {
  final box = Hive.box<Record>('records');
  await box.delete(key);
}

Future<double> totalAmount({required bool isExpense, required DateTime month}) async {
  final box = Hive.box<Record>('records');
  final records = box.values.where((r) =>
    r.isExpense == isExpense &&
    r.date.year == month.year &&
    r.date.month == month.month);
  return records.fold<double>(0.0, (sum, r) => sum + r.amount);
}

Future<List<Record>> fetchRecords({required bool isExpense, required DateTime month}) async {
  final box = Hive.box<Record>('records');
  return box.values.where((r) =>
    r.isExpense == isExpense &&
    r.date.year == month.year &&
    r.date.month == month.month)
    .toList();
}
