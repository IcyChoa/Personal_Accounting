import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/db.dart';
import '../pages/accounting_page.dart';
import 'dart:math';

class AnalysisPage extends StatefulWidget{
  const AnalysisPage({super.key});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  double _minX = 0.0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
          child: Column(
            children: [
              Text(
                'Trend',
                style: GoogleFonts.robotoSlab(
                  color: Color(0xFF2F2963),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: Color(0xFF546de5)),
                      SizedBox(width: 4),
                      Text('Income', style: GoogleFonts.robotoSlab(fontSize: 14, color: Color(0xFF2F2963))),
                    ],
                  ),
                  SizedBox(width: 16),
                  Row(
                    children: [
                      Container(width: 10, height: 10, color: Color(0xFFc44569)),
                      SizedBox(width: 4),
                      Text('Expense', style: GoogleFonts.robotoSlab(fontSize: 14, color: Color(0xFF2F2963))),
                    ],
                  ),
                ],
              ),
              FutureBuilder<Map<String, dynamic>>(
                future: fetchChartData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final raw = snapshot.data!;
                  // extract data
                  final incomeSpots = List<FlSpot>.from(raw['income']);
                  final expenseSpots = List<FlSpot>.from(raw['expense']);
                  final months = List<DateTime>.from(raw['months']);
                  if (incomeSpots.isEmpty) return Center(child: Text('No sufficient data to display'));
                  final count = incomeSpots.length;

                  // compute statistics
                  final avgInc = incomeSpots.map((s) => s.y).fold(0.0, (a, b) => a + b) / count;
                  final avgExp = expenseSpots.map((s) => s.y).fold(0.0, (a, b) => a + b) / count;
                  double stdDev(List<double> data, double m) => sqrt(data.map((x) => pow(x - m, 2)).fold(0.0, (a, b) => a + b) / data.length);
                  final sdInc = stdDev(incomeSpots.map((s) => s.y).toList(), avgInc);
                  final sdExp = stdDev(expenseSpots.map((s) => s.y).toList(), avgExp);
                  final totInc = incomeSpots.map((s) => s.y).fold(0.0, (a, b) => a + b);
                  final totExp = expenseSpots.map((s) => s.y).fold(0.0, (a, b) => a + b);
                  final window = count < 9 ? count : 9;
                  
                  // compute y axis bounds and update _minX
                  final allYs = [...incomeSpots.map((s) => s.y), ...expenseSpots.map((s) => s.y)];
                  final minDataY = allYs.reduce((a, b) => a < b ? a : b);
                  final maxDataY = allYs.reduce((a, b) => a > b ? a : b);
                  var paddingY = (maxDataY - minDataY) * 0.1;
                  if (paddingY == 0) paddingY = maxDataY * 0.1;
                  if (paddingY == 0) paddingY = 1.0;
                  final minY = minDataY - paddingY;
                  final maxY = maxDataY + paddingY;
                   // ensure _minX within valid range
                   final maxMinX = (count - window);
                   if (!_initialized) {
                     _minX = maxMinX.toDouble();
                     _initialized = true;
                   }
                   _minX = _minX.clamp(0.0, maxMinX.toDouble());
                   return Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: LayoutBuilder(
                          builder: (ctx, constraints) {
                            final chartWidth = constraints.maxWidth;
                            return GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  final deltaUnits = -details.delta.dx / chartWidth * window;
                                  _minX = (_minX + deltaUnits).clamp(0.0, maxMinX.toDouble());
                                });
                              },
                              child: LineChart(
                               LineChartData(
                                clipData: FlClipData(top: false, right: true, bottom: false, left: true),
                                minX: _minX,
                                maxX: _minX + window - 1,
                                minY: minY,
                                maxY: maxY,
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    left: BorderSide(color: Color(0xFF2F2963)),
                                    bottom: BorderSide(color: Color(0xFF2F2963)),
                                    top: BorderSide(color: Colors.transparent),
                                    right: BorderSide(color: Colors.transparent),
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                       interval: 1,
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final idx = value.toInt();
                                        if (idx < 0 || idx >= months.length) return SizedBox.shrink();
                                        final d = months[idx];
                                        return Text('${d.month}/${d.year.toString().substring(2)}',
                                            style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963), fontSize: 12));
                                      },
                                      reservedSize: 30,
                                      minIncluded: false,
                                      maxIncluded: false,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) =>
                                          Text('${(value / 1000)}K',
                                              style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963), fontSize: 12)),
                                      reservedSize: 35,
                                      minIncluded: false,
                                      maxIncluded: false,
                                    ),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(spots: incomeSpots, isCurved: false, color: Color(0xFF546de5), barWidth: 2),
                                  LineChartBarData(spots: expenseSpots, isCurved: false, color: Color(0xFFc44569), barWidth: 2),
                                ],
                                extraLinesData: ExtraLinesData(
                                  horizontalLines: [
                                    HorizontalLine(
                                      y: avgInc,
                                      color: Color(0xFF546de5),
                                      strokeWidth: 1,
                                      dashArray: [4, 4],
                                      label: HorizontalLineLabel(
                                        show: true,
                                        alignment: Alignment.topRight,
                                        labelResolver: (_) => 'Avg Inc ${avgInc.toStringAsFixed(0)}',
                                        style: GoogleFonts.robotoSlab(color: Color(0xFF546de5), fontSize: 10),
                                      ),
                                    ),
                                    HorizontalLine(
                                      y: avgExp,
                                      color: Color(0xFFc44569),
                                      strokeWidth: 1,
                                      dashArray: [4, 4],
                                      label: HorizontalLineLabel(
                                        show: true,
                                        alignment: Alignment.bottomRight,
                                        labelResolver: (_) => 'Avg Exp ${avgExp.toStringAsFixed(0)}',
                                        style: GoogleFonts.robotoSlab(color: Color(0xFFc44569), fontSize: 10),
                                      ),
                                    ),
                                  ]
                                )
                              ),
                              )
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8),
                      Divider(color: Color(0xFF2F2963), thickness: 1),
                      SizedBox(height: 8),
                      Text('Statistics', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963), fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(color: Color(0xFF2F2963), width: 1),
                          verticalInside: BorderSide(color: Colors.transparent),
                          top: BorderSide.none,
                          bottom: BorderSide.none,
                          left: BorderSide.none,
                          right: BorderSide.none,
                        ),
                        columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                        children: [
                          TableRow(children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Avg Income', avgInc)),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Std Dev Income', sdInc)),
                          ]),
                          TableRow(children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Avg Expense', avgExp)),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Std Dev Expense', sdExp)),
                          ]),
                          TableRow(children: [
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Total Balance', totInc - totExp)),
                            Padding(padding: EdgeInsets.symmetric(vertical: 8), child: buildStatTile('Avg Balance', avgInc - avgExp)),
                          ]),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ]
          ),
        ),
      ),
    );
  }

  Widget buildStatTile(String title, double value) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963), fontSize: 14)),
          Text(value != null ? value.toStringAsFixed(2) : '-', style: GoogleFonts.robotoSlab(color: Color(0xFF2F2963), fontSize: 14)),
        ],
      ),
    );
  }
}