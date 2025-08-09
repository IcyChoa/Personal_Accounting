import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/accounting_page.dart';
import 'package:intl/intl.dart';
import '../widgets/MonthPicker.dart';
import '../services/db.dart';
import '../models/record.dart';
import 'category_records.dart';

final List<Color> chartColors = [
  Color(0xFFf19066),
  Color(0xFF546de5),
  Color(0xFF574b90),
  Color(0xFFe15f41),
  Color(0xFFc44569),
  Color(0xFF596275),
  Color(0xFF3dc1d3),
  Color(0xFFe66767),
  Color(0xFF303952),
  Color(0xFF786fa6),
  Color(0xFFcf6a87),
];

class HistoryPage extends StatefulWidget{
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>{
  bool _isExpense = true;
  DateTime _selectedMonth = DateTime.now();
  double totalExpense = 0.0;
  double totalIncome = 0.0;
  double balance = 0.0;
  late Future<List<Record>> _recordsFuture;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _recordsFuture = fetchRecords(isExpense: _isExpense, month: _selectedMonth);
    _updateTotals();
  }

  Future<void> _updateTotals() async {
    final te = await totalAmount(isExpense: true, month: _selectedMonth);
    final ti = await totalAmount(isExpense: false, month: _selectedMonth);
    setState(() {
      totalExpense = te;
      totalIncome = ti;
      balance = ti - te;
    });
  }

  void _toggleType(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _recordsFuture = fetchRecords(isExpense: _isExpense, month: _selectedMonth);
      _touchedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 24),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                Center(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 36),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () async {
                      final result = await showDialog<DateTime>(
                        context: context,
                        builder: (_) => MonthPicker(
                          initialMonth: _selectedMonth,
                          dialogBackgroundColor: bgColor,
                          selectedMonthColor: Color(0xFF2F2963),
                          unselectedMonthColor: bgColor,
                          headerIconColor: Color(0xFF2F2963),
                          monthTextStyle: TextStyle(color: Color(0xFF2F2963)),
                          okTextStyle: TextStyle(color: Color(0xFF2F2963)),
                          cancelTextStyle: TextStyle(color: Color(0xFF2F2963)),
                          yearTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(color: Color(0xFF2F2963)),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _selectedMonth = result;
                          _recordsFuture = fetchRecords(isExpense: _isExpense, month: _selectedMonth);
                          _touchedIndex = null;
                        });
                        _updateTotals();
                      }
                    },
                    child: Text(
                      DateFormat.yMMM().format(_selectedMonth),
                      style: GoogleFonts.robotoSlab(fontSize: 16, color: Color(0xFF2F2963)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Divider(
                  thickness: 1,
                  color: Color(0xFF2F2963),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isExpense ? 'Expense' : 'Income',
                              style: GoogleFonts.robotoSlab(fontSize: 12, color: Color(0xFF2F2963)),
                            ),
                            Text(
                              '\$${(_isExpense ? totalExpense : totalIncome).toStringAsFixed(2)}',
                              style: GoogleFonts.robotoSlab(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2F2963)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance',
                              style: GoogleFonts.robotoSlab(fontSize: 12, color: Color(0xFF2F2963)),
                            ),
                            Text(
                              '\$${balance.toStringAsFixed(2)}',
                              style: GoogleFonts.robotoSlab(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2F2963)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                FutureBuilder<List<Record>>(
                  future: _recordsFuture,
                  builder: (context, snapshot) {
                    final records = snapshot.data ?? [];
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (records.isEmpty) {
                      return Center(
                        child: Text('No data', style: GoogleFonts.robotoSlab(fontSize: 14, color: Color(0xFF2F2963))),
                      );
                    }
                    final dataMap = <String, double>{};
                    for (var r in records) {
                      dataMap.update(r.category.name, (v) => v + r.amount, ifAbsent: () => r.amount);
                    }
                    final total = dataMap.values.fold(0.0, (a, b) => a + b);
                    final sections = dataMap.entries.map((e) {
                      final idx = dataMap.keys.toList().indexOf(e.key);
                      // guard out-of-range
                      final validIndex = idx >= 0 ? idx : null;
                      final isTouched = validIndex == _touchedIndex;
                      final double radius = isTouched ? 80 : 60;
                      return PieChartSectionData(
                        value: e.value,
                        color: chartColors[idx % chartColors.length],
                        radius: radius,
                        title: '${e.key}\n\$${e.value.toStringAsFixed(2)}',
                        titleStyle: GoogleFonts.robotoSlab(
                          fontSize: isTouched ? 14 : 12,
                          color: Colors.white,
                        ),
                      );
                    }).toList();
                    return Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                sectionsSpace: 2,
                                centerSpaceRadius: 90,
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      return;
                                    }
                                    final idx = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    // tap down highlights slice immediately
                                    if (event is FlTapDownEvent) {
                                      setState(() => _touchedIndex = idx);
                                    }
                                    // long press end triggers navigation
                                    else if (event is FlLongPressStart) {
                                      final category = dataMap.keys.toList()[idx];
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CategoryRecordsPage(
                                            category: category,
                                            month: _selectedMonth,
                                            isExpense: _isExpense,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              duration: Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                            ),
                          ),
                          if (_touchedIndex != null && _touchedIndex! >= 0 && _touchedIndex! < dataMap.length) ...{
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${((dataMap.values.toList()[_touchedIndex!] / total) * 100).toStringAsFixed(1)}%',
                                  style: GoogleFonts.robotoSlab(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2F2963)),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  dataMap.keys.toList()[_touchedIndex!],
                                  style: GoogleFonts.robotoSlab(fontSize: 14, color: Color(0xFF2F2963)),
                                ),
                              ],
                            ),
                          }
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}