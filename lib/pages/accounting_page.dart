import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      color: bgColor, // set your desired background color here
      child: Padding(
        padding: EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleType(true),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _isExpense ? Color(0xFF2F2963) : bgColor,
                        border: Border(
                          top: BorderSide(color: bgColor),
                          bottom: BorderSide(color: bgColor),
                          left: BorderSide(color: bgColor),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0))
                      ),
                      child: Text(
                        'Expense',
                        style: GoogleFonts.robotoSlab(
                          fontSize: 18,
                          color: _isExpense ? bgColor : Color(0xFF2F2963),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: VerticalDivider(
                    color: Color(0xFF2F2963),
                    thickness: 3,
                    width: 32,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _toggleType(false),
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_isExpense ? Color(0xFF2F2963) : bgColor,
                        border: Border(
                          top: BorderSide(color: bgColor),
                          bottom: BorderSide(color: bgColor),
                          left: BorderSide(color: bgColor),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Text(
                        'Income',
                        style: GoogleFonts.robotoSlab(
                          fontSize: 16,
                          color: !_isExpense ? bgColor : Color(0xFF2F2963),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isExpense ? ExpenseView() : IncomeView(),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseView extends StatelessWidget {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '当前是支出视图',
        style: GoogleFonts.robotoSlab(fontSize: 18),
      ),
    );
  }
}

class IncomeView extends StatelessWidget {
  const IncomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '当前是收入视图',
        style: GoogleFonts.robotoSlab(fontSize: 18),
      ),
    );
  }
}