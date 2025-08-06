import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';
import '../services/db.dart';
import '../models/settings.dart';

final Color bgColor = Color(0xFFEEE7CD);

class CategoryEditPage extends StatefulWidget {
  final bool isExpense;
  const CategoryEditPage({super.key, required this.isExpense});

  @override
  _CategoryEditPageState createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  late Box<Category> _box;
  late bool _isExpense;
  late Box<Settings> _settingsBox;
  late Settings _settings;

  @override
  void initState() {
    super.initState();
    _box = Hive.box<Category>('categories');
    _settingsBox = Hive.box<Settings>('settings');
    _settings = _settingsBox.get('settings')!;
    _isExpense = widget.isExpense;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_settings.categoryWarningShown) {
        _settings.categoryWarningShown = true;
        _settings.save();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: bgColor,
            title: Text('Reminder', style: GoogleFonts.robotoSlab(fontSize: 24, color: Color(0xFF2F2963))),
            content: Text(
              'Deleting a category will also delete all its records.',
              style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'I understand',
                  style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963)),
                ),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final entries = _box.toMap().entries
      .where((e) => e.value.isExpense == _isExpense)
      .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF533E2D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bgColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isExpense ? 'Expense Categories' : 'Income Categories',
          style: GoogleFonts.robotoSlab(fontSize: 20, fontWeight: FontWeight.bold, color: bgColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.swap_horiz, color: bgColor),
            tooltip: _isExpense ? 'Show Income' : 'Show Expense',
            onPressed: () => setState(() => _isExpense = !_isExpense),
          ),
        ],
      ),
      body: Container(
        color: bgColor,
        child: ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey),
          itemBuilder: (context, index) {
            final key = entries[index].key;
            final cat = entries[index].value;
            return ListTile(
              leading: IconButton(
                icon: Icon(Icons.clear, color: Colors.red),
                onPressed: () async {
                  await removeCategory(key);
                  setState(() {});
                },
              ),
              title: Text(
                cat.name,
                style: GoogleFonts.robotoSlab(fontSize: 16),
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit, color: Color(0xFF2F2963)),
                onPressed: () async {
                  final newName = await showDialog<String>(
                    context: context,
                    builder: (context) {
                      final ctrl = TextEditingController(text: cat.name);
                      return AlertDialog(
                        backgroundColor: bgColor,
                        title: Text('Rename Category', style: GoogleFonts.robotoSlab(fontSize: 24, color: Color(0xFF2F2963))),
                        content: TextField(controller: ctrl),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context),
                            child: Text('Cancel',
                                style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963))
                            ),
                          ),
                          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text('OK',
                              style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963))
                          ),),
                        ],
                      );
                    },
                  );
                  if (newName != null && newName.trim().isNotEmpty) {
                    await renameCategory(key, newName.trim());
                    setState(() {});
                  }
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2F2963),
        child: Icon(Icons.add, color: bgColor),
        onPressed: () async {
          final newName = await showDialog<String>(
            context: context,
            builder: (_) {
              final ctrl = TextEditingController();
              return AlertDialog(
                backgroundColor: bgColor,
                title: Text('New Category', style: GoogleFonts.robotoSlab(fontSize: 24, color: Color(0xFF2F2963))),
                content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Category name')),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963)))),
                  TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: Text('Add', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963)))),
                ],
              );
            },
          );
          if (newName != null && newName.trim().isNotEmpty) {
            await addCategory(Category(name: newName.trim(), isExpense: _isExpense));
            setState(() {});
          }
        },
      ),
    );
  }
}
