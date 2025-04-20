import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mini/lg_chatbox.dart';
import 'package:mini/mini_quiz.dart';
import 'package:mini/voice_assistant.dart';
import 'about.dart';
import 'settings_page.dart';
import 'lg_task.dart';
import 'tourist_place.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    // Keep orientation settings as they were
  ]).then((_) {
    runApp(MyApp());
  });
}

final _assistant = VoiceAssistant();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liquid Galaxy Explorer',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
          secondary: Colors.tealAccent,
        ),
        fontFamily: 'Poppins',
        textTheme: TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.indigo.shade800,
          iconTheme: IconThemeData(color: Colors.indigo.shade800),
          titleTextStyle: TextStyle(
            color: Colors.indigo.shade800,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          secondary: Colors.tealAccent,
        ),
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget _currentPage = LiquidGalaxyChatbot();
  String _title = 'Liquid Galaxy Bot';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDarkMode = false;

  void _updatePage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _title = title;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),

        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      drawer: _buildDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.indigo.shade50],
          ),
        ),
        child: SafeArea(child: _currentPage),
      ),

      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        // Add this SafeArea widget
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo.shade800, Colors.indigo.shade500],
            ),
          ),
          child: Column(
            children: [
              // Remove the existing DrawerHeader and replace with this
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('images/lg.jpg'),
                    fit: BoxFit.fitWidth,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                    onError: (exception, stackTrace) {
                      print('Image not found, using solid color');
                    },
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          Icons.public,
                          size: 30,
                          color: Colors.indigo.shade800,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Liquid Galaxy',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Explorer',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // _buildDrawerItem(
                    //   icon: Icons.search,
                    //   title: 'Search Place',
                    //   onTap: () => _updatePage(Search_Place(), 'Explore'),
                    // ),
                    _buildDrawerItem(
                      icon: Icons.bubble_chart_rounded,
                      title: 'Liquid Galaxy Bot',
                      onTap:
                          () => _updatePage(LiquidGalaxyChatbot(), 'Liquid Galaxy Bot'),
                    ),
                    // _buildDrawerItem(
                    //   icon: Icons.place,
                    //   title: 'Tourist Places',
                    //   onTap:
                    //       () => _updatePage(Tourist_Place(), 'Tourist Places'),
                    // ),
                    _buildDrawerItem(
                      icon: Icons.quiz,
                      title: 'Mini Quiz',
                      onTap: () => _updatePage(MiniQuiz(), 'Galaxy Quiz'),
                    ),
                    _buildDrawerItem(
                      icon: Icons.task,
                      title: 'LG Tasks',
                      onTap: () => _updatePage(LG_Task(), 'LG Tasks'),
                    ),
                    Divider(color: Colors.white30),
                    _buildDrawerItem(
                      icon: Icons.info,
                      title: 'About',
                      onTap: () => _updatePage(About(), 'About'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
      dense: true,
    );
  }

  void _promptUser(BuildContext context) async {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ask the Assistant"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter your question"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final input = _controller.text.trim();
                if (input.isNotEmpty) {
                  final result = await _assistant.askGemini(input);
                  print("🧠 Assistant: $result");
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: Text("Ask"),
            ),
          ],
        );
      },
    );
  }
}

// Quiz Card Widget
class QuizCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onSelect;
  final int selectedIndex;
  final int correctIndex;
  final bool isAnswered;

  QuizCard({
    required this.question,
    required this.options,
    required this.onSelect,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isAnswered,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ...options.asMap().entries.map((entry) {
              int idx = entry.key;
              String option = entry.value;

              Color bgColor = Colors.white;
              Color borderColor = Colors.grey.shade300;
              Color textColor = Colors.black87;
              IconData? trailingIcon;

              if (isAnswered) {
                if (idx == correctIndex) {
                  bgColor = Colors.green.shade50;
                  borderColor = Colors.green;
                  textColor = Colors.green.shade800;
                  trailingIcon = Icons.check_circle;
                } else if (idx == selectedIndex) {
                  bgColor = Colors.red.shade50;
                  borderColor = Colors.red;
                  textColor = Colors.red.shade800;
                  trailingIcon = Icons.cancel;
                }
              }

              return GestureDetector(
                onTap: () {
                  if (!isAnswered) onSelect(idx);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            color: textColor,
                            fontWeight:
                                idx == selectedIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, color: textColor),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
