import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/record.dart';
import '../services/db.dart';
import '../pages/accounting_page.dart';
import '../models/category.dart';

const Color appBarColor = Color(0xFF533E2D);

class CategoryRecordsPage extends StatefulWidget {
  final String category;
  final DateTime month;
  final bool isExpense;

  const CategoryRecordsPage({super.key, required this.category, required this.month, required this.isExpense});

  @override
  _CategoryRecordsPageState createState() => _CategoryRecordsPageState();
}

class _CategoryRecordsPageState extends State<CategoryRecordsPage> {
  late Future<List<Record>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchRecords(isExpense: widget.isExpense, month: widget.month);
  }

  @override
  Widget build(BuildContext context) {
    final title = '${widget.category} in ${DateFormat.yMMM().format(widget.month)}';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: bgColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: GoogleFonts.robotoSlab(fontSize: 20, fontWeight: FontWeight.bold, color: bgColor)),
      ),
      body: Container(
        color: bgColor,
        child: FutureBuilder<List<Record>>(
          future: _recordsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(child: CircularProgressIndicator());
            }
            final all = snapshot.data ?? [];
            final records = all.where((r) => r.category.name == widget.category).toList();
            if (records.isEmpty) {
              return Center(child: Text('No records', style: GoogleFonts.robotoSlab(fontSize: 16, color: appBarColor)));
            }
            return ListView.separated(
              itemCount: records.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey),
              itemBuilder: (context, index) {
                final r = records[index];
                return Dismissible(
                  key: ValueKey(r.key),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // delete
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Delete Record?'),
                          content: Text('Are you sure you want to delete this record?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await removeRecord(r.key as int);
                        setState(() { _recordsFuture = fetchRecords(isExpense: widget.isExpense, month: widget.month); });
                      }
                      return ok;
                    } else {
                      // edit
                      final edited = await _showEditDialog(r);
                      if (edited == true) {
                        setState(() {
                          _recordsFuture = fetchRecords(isExpense: widget.isExpense, month: widget.month);
                        });
                      }
                      return false;
                    }
                  },
                  child: ListTile(
                    title: Text(
                      DateFormat.yMMMd().format(r.date),
                      style: GoogleFonts.robotoSlab(fontSize: 16),
                    ),
                    subtitle: r.note.isNotEmpty
                        ? Text(r.note, style: GoogleFonts.robotoSlab(fontSize: 14, color: Colors.grey))
                        : null,
                    trailing: Text(
                      '\$${r.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.robotoSlab(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2F2963)),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _showEditDialog(Record record) async {
    final expenseCats = await fetchCategories(true);
    final incomeCats = await fetchCategories(false);
    bool tempIsExpense = record.isExpense;
    List<Category> tempCats = tempIsExpense ? expenseCats : incomeCats;
    Category tempCategory = tempCats.firstWhere((c) => c.name == record.category.name, orElse: () => tempCats.first);
    final amountCtrl = TextEditingController(text: record.amount.toString());
    final noteCtrl = TextEditingController(text: record.note);
    DateTime tempDate = record.date;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: bgColor,
          title: Text('Edit Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Color.fromRGBO(47, 41, 99, 0.4),
                        highlightColor: Color.fromRGBO(47, 41, 99, 0.2),
                      ),
                      child: ChoiceChip(
                        label: Text('Expense', style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: tempIsExpense ? bgColor : Color(0xFF2F2963),
                        )),
                        selected: tempIsExpense,
                        selectedColor: Color(0xFF2F2963),
                        backgroundColor: bgColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: bgColor),
                        onSelected: (sel) {
                          setState(() {
                            tempIsExpense = true;
                            tempCats = expenseCats;
                            tempCategory = tempCats.first;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Color.fromRGBO(47, 41, 99, 0.4),
                        highlightColor: Color.fromRGBO(47, 41, 99, 0.2),
                      ),
                      child: ChoiceChip(
                        label: Text('Income', style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: !tempIsExpense ? bgColor : Color(0xFF2F2963),
                        )),
                        selected: !tempIsExpense,
                        selectedColor: Color(0xFF2F2963),
                        backgroundColor: bgColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: BorderSide(color: bgColor),
                        onSelected: (sel) {
                          setState(() {
                            tempIsExpense = false;
                            tempCats = incomeCats;
                            tempCategory = tempCats.first;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // category dropdown
              DropdownButton<Category>(
                value: tempCategory,
                items: tempCats.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => tempCategory = val);
                },
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount'),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: noteCtrl,
                decoration: InputDecoration(labelText: 'Note'),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: Color(0xFF2F2963),    // header background
                                  onPrimary: Colors.white,       // header text
                                  surface: bgColor,              // calendar background
                                  onSurface: Color(0xFF2F2963),  // calendar text
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) setState(() => tempDate = picked);
                      },
                      child: Text(
                        DateFormat.yMMMd().format(tempDate),
                        style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false),
                child:
                Text('Cancel', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963)))),
            TextButton(
              onPressed: () {
                final newAmt = double.tryParse(amountCtrl.text) ?? record.amount;
                record.isExpense = tempIsExpense;
                record.category = tempCategory;
                record.amount = newAmt;
                record.note = noteCtrl.text;
                record.date = tempDate;
                record.save();
                Navigator.pop(context, true);
              },
              child: Text('Save', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963))),
            ),
          ],
        ),
      ),
    );
  }
}
