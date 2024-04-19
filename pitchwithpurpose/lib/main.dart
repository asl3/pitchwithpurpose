import 'package:flutter/material.dart';
import 'package:animated_background/animated_background.dart';
import 'fileupload.dart';
import 'simplerecorder.dart';
import 'mynotes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 33, 139, 232),
          brightness: Brightness.light,
        ),
        fontFamily: 'Yantramanav',
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontWeight: FontWeight.w400),
          bodyText2: TextStyle(fontWeight: FontWeight.w400),
          headline6: TextStyle(fontWeight: FontWeight.bold),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Notes Net'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_sharp), // Adjust size as needed
            SizedBox(width: 10),  // Space between icon and text
            Text(widget.title),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Notes Upload'),
            Tab(text: 'Recorder'),
            Tab(text: 'My Notes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FileUploadTab(),
          SimpleRecorder(),
          MyPdfsWidget(),
        ],
      ),
    );
  }
}
