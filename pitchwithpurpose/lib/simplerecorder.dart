import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:animated_background/animated_background.dart';

class SimpleRecorder extends StatefulWidget {
  const SimpleRecorder({super.key});

  @override
  State<SimpleRecorder> createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> with TickerProviderStateMixin {
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mRecorderIsInited = false;
  List<String> recordings = [];

  @override
  void initState() {
    super.initState();
    openTheRecorder();
    loadRecordings();
  }

  @override
  void dispose() {
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder!.openRecorder();
    _mRecorderIsInited = true;
  }

  Future<void> record() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String filePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _mRecorder!.startRecorder(toFile: filePath);
    setState(() {});
  }

  Future<void> stopRecorder() async {
    final path = await _mRecorder!.stopRecorder();
    setState(() {
      recordings.add(path!);
    });
    _showRenameDialog(path!);
    saveRecordings();
  }

  Future<void> saveRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recordings', recordings);
  }

  Future<void> loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    recordings = prefs.getStringList('recordings') ?? [];
    setState(() {});
  }

  void _showRenameDialog(String path) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Name your recording'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter a name"),
        ),
        actions: [
          TextButton(
            child: Text('Save'),
            onPressed: () {
              String newName = '${path.substring(0, path.lastIndexOf('/'))}/${controller.text}.aac';
              File(path).rename(newName);
              setState(() {
                recordings.remove(path);
                recordings.add(newName);
              });
              Navigator.of(context).pop();
              saveRecordings();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        String path = recordings[index];
        String fileName = path.split('/').last;
        return ListTile(
          title: Text(fileName),
          onTap: () {
            // Play the recording
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lecture Recorder'),
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: ElevatedButton.icon(
                onPressed: _mRecorder!.isRecording ? stopRecorder : record,
                icon: Icon(_mRecorder!.isRecording ? Icons.stop : Icons.mic_none, size: 24),
                label: Text(_mRecorder!.isRecording ? 'Stop Recording' : 'Start Recording'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: _mRecorder!.isRecording ? Colors.red : Colors.green,
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(fontSize: 16),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            Expanded(
              child: _buildRecordingsList(),
            ),
          ],
        ),
      ),
    );
  }
}