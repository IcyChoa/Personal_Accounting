import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/db.dart';
import '../models/category.dart';
import '../models/record.dart';
import 'category_edit.dart';

final bgColor = Color(0xFFEEE7CD);

class AccountingPage extends StatefulWidget {

  const AccountingPage({super.key});

  @override
  _AccountingPageState createState() => _AccountingPageState();
}

class _AccountingPageState extends State<AccountingPage> {
  bool _isExpense = true;

  void _toggleType(bool isExpense) {
    setState(() {
      _isExpense = (isExpense);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      color: bgColor,
      child: Padding(
        padding: EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 24),
        child: Column(
          children: [
            // Toggle selection with ChoiceChip and separator
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Color.fromRGBO(47, 41, 99, 0.4),
                        highlightColor: Color.fromRGBO(47, 41, 99, 0.2),
                      ),
                      child: ChoiceChip(
                        label: Text('Expense', style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: _isExpense ? bgColor : Color(0xFF2F2963),
                        )),
                        selected: _isExpense,
                        selectedColor: Color(0xFF2F2963),
                        backgroundColor: bgColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: bgColor),
                        onSelected: (_) => _toggleType(true),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  alignment: Alignment.center,
                  child: Container(
                    width: 3,
                    height: 40,
                    color: Color(0xFF2F2963),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Color.fromRGBO(47, 41, 99, 0.4),
                        highlightColor: Color.fromRGBO(47, 41, 99, 0.2),
                      ),
                      child: ChoiceChip(
                        label: Text('Income', style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: !_isExpense ? bgColor : Color(0xFF2F2963),
                        )),
                        selected: !_isExpense,
                        selectedColor: Color(0xFF2F2963),
                        backgroundColor: bgColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: bgColor),
                        onSelected: (_) => _toggleType(false),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: RecordFormView(isExpense: _isExpense),
            ),
          ],
        ),
      ),
    );
  }
}

/// accounting view for adding records
class RecordFormView extends StatefulWidget {
  final bool isExpense;
  const RecordFormView({super.key, required this.isExpense});
  @override
  _RecordFormViewState createState() => _RecordFormViewState();
}

class _RecordFormViewState extends State<RecordFormView> {
  Category? _selectedCategory;
  DateTime? _selectedDate;
  final _dateCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // set default date to today
    _selectedDate = DateTime.now();
    _dateCtrl.text = DateFormat.yMd().format(_selectedDate!);
  }

  Future<void> _pickDate() async{
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF2F2963), // header background
              onPrimary: Colors.white,    // header text color
              surface: bgColor,           // calendar background
              onSurface: Color(0xFF2F2963), // calendar text
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null){
      setState((){
        _selectedDate = date;
        _dateCtrl.text = DateFormat.yMd().format(date);
      });
    }
  }

  Future<void> _saveRecord() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a category', style: GoogleFonts.robotoSlab(color: bgColor)),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF533E2D),
      ));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a date', style: GoogleFonts.robotoSlab(color: bgColor)),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF533E2D),
      ));
    }
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid amount', style: GoogleFonts.robotoSlab(color: bgColor)),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF533E2D),
      ));
      return;
    }
    final note = _noteCtrl.text;
    final record = Record(
      isExpense: widget.isExpense,
      category: _selectedCategory!,
      date: _selectedDate!,
      amount: amount,
      note: note,
    );
    await addRecord(record);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Record added')));
    setState(() {
      // retain selected category and date, only clear amount and note for next entry
      _amountCtrl.clear();
      _noteCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Category>>(
              future: fetchCategories(widget.isExpense),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final categories = snapshot.data!;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...categories.map((c) {
                      final isSelected = c == _selectedCategory;
                      return ChoiceChip(
                        label: Text(c.name, style: GoogleFonts.robotoSlab(
                          color: isSelected ? bgColor : Color(0xFF2F2963),
                        )),
                        selected: isSelected,
                        selectedColor: Color(0xFF2F2963),
                        backgroundColor: bgColor,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey),
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = c),
                      );
                    }),
                    ActionChip(
                      avatar: Icon(Icons.edit, size: 20, color: Color(0xFF2F2963)),
                      label: Text('edit', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963))),
                      backgroundColor: bgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryEditPage(isExpense: widget.isExpense),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dateCtrl,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: InputDecoration(
                      labelText: "Date",
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      labelText: 'Amount',
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    decoration: InputDecoration(
                      labelText: 'Note',
                      prefixIcon: Icon(Icons.sticky_note_2),
                    ),
                  )
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2F2963),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _saveRecord,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: bgColor, size: 24),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
