import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceRecorderTab extends StatefulWidget {
  const VoiceRecorderTab({Key? key}) : super(key: key);

  @override
  State<VoiceRecorderTab> createState() => _VoiceRecorderTabState();
}

class _VoiceRecorderTabState extends State<VoiceRecorderTab> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  List<String> _recordings = [];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
  // This opens the audio session and requests the microphone permission
  var status = await Permission.microphone.request();
  if (status != PermissionStatus.granted) {
    throw Exception('Microphone permission not granted');
  }

  await _recorder.openRecorder();
  // It is important to wait until the recorder is fully initialized
  // bool isRecorderInitialized = await _recorder._isInited;
  // if (!isRecorderInitialized) {
  //   throw Exception('Recorder could not be initialized');
  // }
}

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder.startRecorder(toFile: tempPath);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordings.add(path!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            onPressed: () {
              if (_isRecording) {
                _stopRecording();
              } else {
                _startRecording();
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recordings.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('Recording ${index + 1}'),
                subtitle: Text(_recordings[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _renameRecording(index);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _renameRecording(int index) async {
    String newName = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Rename Recording'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (newName.isNotEmpty) {
      setState(() {
        _recordings[index] = newName;
      });
    }
  }
}