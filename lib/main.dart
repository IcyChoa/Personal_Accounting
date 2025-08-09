import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_accounting/pages/accounting_page.dart';
import 'package:personal_accounting/pages/history_page.dart';
import 'package:personal_accounting/pages/analysis_page.dart';
import '../services/db.dart';
import 'package:intl/intl.dart';

/// color palette: https://coolors.co/2f2963-533e2d-a27035-b88b4a-eee7cd

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Accounting',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        // add more locales if needed
      ],
      home: HomePage(title: 'Personal Accounting'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    AccountingPage(),
    HistoryPage(),
    AnalysisPage(),
  ];

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xFF533E2D),
        leading: IconButton(
            icon: Icon(Icons.menu, color: bgColor),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(widget.title, style: GoogleFonts.robotoSlab(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: bgColor
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings,
              color: bgColor),
            onPressed: () {}
          )
        ]
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFFA27035)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/AppIcon.png', width: 50, height: 50),
                      SizedBox(width: 8),
                      Text(
                        'Personal Accounting',
                        style: GoogleFonts.robotoSlab(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  FutureBuilder<List<double>>(
                    future: Future.wait([
                      totalAmount(isExpense: false, month: DateTime.now()),
                      totalAmount(isExpense: true, month: DateTime.now()),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                          height: 24,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }
                      final income = snapshot.data![0];
                      final expense = snapshot.data![1];
                      final formatter = NumberFormat.simpleCurrency();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Income: ${formatter.format(income)}',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Expense: ${formatter.format(expense)}',
                            style: GoogleFonts.robotoSlab(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Text(
                    '"many a little makes a mickle"',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_balance_wallet, color: Color(0xFF242331)),
              title: Text('Accounting',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                  color: Color(0xFF242331)
                )
              ),
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              } // Navigate to Accounting Page
            ),
            ListTile(
                leading: Icon(Icons.history, color: Color(0xFF242331)),
                title: Text('History',
                    style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        color: Color(0xFF242331)
                    )
                ),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                } // Navigate to History Page
            ),
            ListTile(
                leading: Icon(Icons.analytics_outlined, color: Color(0xFF242331)),
                title: Text('Analysis',
                    style: GoogleFonts.robotoSlab(
                        fontSize: 18,
                        color: Color(0xFF242331)
                    )
                ),
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                } // Navigate to Analysis Page
            ),
          ]
        )
      ),
      body: _pages[_selectedIndex]
    );
  }
}
