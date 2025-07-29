import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_accounting/pages/accounting_page.dart';

void main(){
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
    //HistoryPage(),
    //AnalysisPage(),
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
              child: Text(
                'Maybe put some logo, balance, or user info here',
                style: GoogleFonts.robotoSlab(
                  fontSize: 18,
                  color: Colors.white70,
                )
              )
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
