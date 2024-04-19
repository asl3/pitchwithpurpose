import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_background/animated_background.dart';
import 'pdfviewer.dart';

class MyPdfsWidget extends StatefulWidget {
  const MyPdfsWidget({Key? key}) : super(key: key);

  @override
  State<MyPdfsWidget> createState() => _MyPdfsWidgetState();
}

class _MyPdfsWidgetState extends State<MyPdfsWidget> with TickerProviderStateMixin {
  List<String> _pdfPaths = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPdfs();
  }

  Future<void> _loadSavedPdfs() async {
    final prefs = await SharedPreferences.getInstance();
    _pdfPaths = prefs.getStringList('pdfPaths') ?? [];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            baseColor: Colors.blue,
            spawnMinSpeed: 10,
            spawnMaxSpeed: 30,
            spawnMinRadius: 5,
            spawnMaxRadius: 10,
            particleCount: 50,
          ),
        ),
        vsync: this,
        child: ListView.builder(
          itemCount: _pdfPaths.length,
          itemBuilder: (context, index) {
            String path = _pdfPaths[index];
            return ListTile(
              title: Text(path.split('/').last),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => PdfViewerScreen(pdfPath: path),
                ));
              },
            );
          },
        ),
      ),
    );
  }
}