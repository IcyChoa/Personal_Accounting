import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  bool categoryWarningShown;

  Settings({this.categoryWarningShown = false});
}

